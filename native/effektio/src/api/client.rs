use anyhow::{bail, Context, Result};
use derive_builder::Builder;
use effektio_core::{
    mocks::{gen_mock_faqs, gen_mock_news},
    models::{Faq, News},
    RestoreToken,
};
use futures::{
    channel::mpsc::{channel, Receiver, Sender},
    stream, Stream, StreamExt,
};
use matrix_sdk::{
    config::SyncSettings,
    media::{MediaFormat, MediaRequest},
    room::Room as MatrixRoom,
    ruma::{
        events::{
            room::message::{MessageType, OriginalSyncRoomMessageEvent, TextMessageEventContent},
            AnyStrippedStateEvent,
        },
        OwnedUserId, RoomId,
    },
    Client as MatrixClient, LoopCtrl,
};
use parking_lot::{Mutex, RwLock};
use serde_json::Value;
use std::{sync::Arc, time::Duration};

use super::{api, Account, Conversation, Group, Room, RUNTIME};

#[derive(Default, Clone, Debug)]
pub struct Invitation {
    event_id: String,
    timestamp: u64,
    room_id: String,
    sender: String,
}

impl Invitation {
    pub fn get_event_id(&self) -> String {
        self.event_id.clone()
    }

    pub fn get_timestamp(&self) -> u64 {
        self.timestamp
    }

    pub fn get_room_id(&self) -> String {
        self.room_id.clone()
    }

    pub fn get_sender(&self) -> String {
        self.sender.clone()
    }
}

#[derive(Default, Builder, Debug)]
pub struct ClientState {
    #[builder(default)]
    pub is_guest: bool,
    #[builder(default)]
    pub has_first_synced: bool,
    #[builder(default)]
    pub is_syncing: bool,
    #[builder(default)]
    pub should_stop_syncing: bool,
    #[builder(default)]
    pub invitations: Vec<Invitation>,
}

#[derive(Clone)]
pub struct Client {
    client: MatrixClient,
    state: Arc<RwLock<ClientState>>,
}

impl std::ops::Deref for Client {
    type Target = MatrixClient;
    fn deref(&self) -> &MatrixClient {
        &self.client
    }
}

static PURPOSE_FIELD: &str = "m.room.purpose";
static PURPOSE_FIELD_DEV: &str = "org.matrix.msc3088.room.purpose";
static PURPOSE_VALUE: &str = "org.effektio";

async fn devide_groups_from_common(client: MatrixClient) -> (Vec<Group>, Vec<Conversation>) {
    let (groups, convos, _) = stream::iter(client.clone().rooms().into_iter())
        .fold(
            (Vec::new(), Vec::new(), client),
            async move |(mut groups, mut conversations, client), room| {
                let is_effektio_group = {
                    #[allow(clippy::match_like_matches_macro)]
                    if let Ok(Some(_)) = room
                        .get_state_event(PURPOSE_FIELD.into(), PURPOSE_VALUE)
                        .await
                    {
                        true
                    } else if let Ok(Some(_)) = room
                        .get_state_event(PURPOSE_FIELD_DEV.into(), PURPOSE_VALUE)
                        .await
                    {
                        true
                    } else {
                        false
                    }
                };

                if is_effektio_group {
                    groups.push(Group {
                        inner: Room {
                            room,
                            client: client.clone(),
                        },
                    });
                } else {
                    conversations.push(Conversation {
                        inner: Room {
                            room,
                            client: client.clone(),
                        },
                    });
                }

                (groups, conversations, client)
            },
        )
        .await;
    (groups, convos)
}

impl Client {
    pub(crate) fn new(client: MatrixClient, state: ClientState) -> Self {
        Client {
            client,
            state: Arc::new(RwLock::new(state)),
        }
    }

    pub(crate) fn start_sync(&self) {
        let client = self.client.clone();
        let state = self.state.clone();
        let sync_settings = SyncSettings::new().timeout(Duration::from_secs(5));

        RUNTIME.spawn(async move {
            let state = state.clone();
            let user_id = client.user_id().expect("No User ID found");

            // past events
            client
                .sync_with_callback(sync_settings, move |response| {
                    println!("start_sync");
                    let state = state.clone();
                    let user_id = user_id.clone();

                    async move {
                        if !state.read().has_first_synced {
                            state.write().has_first_synced = true;
                            println!("start_sync: {}", response.rooms.invite.len());
                            for (room_id, room) in response.rooms.invite {
                                println!("start_sync");
                                for event in room.invite_state.events {
                                    if let Ok(AnyStrippedStateEvent::RoomMember(member)) =
                                        event.deserialize()
                                    {
                                        if member.state_key == user_id.as_str() {
                                            println!("event: {:?}", event);
                                            println!("member: {:?}", member);
                                            let v: Value =
                                                serde_json::from_str(event.json().get()).unwrap();
                                            println!("event id: {}", v["event_id"]);
                                            println!("timestamp: {}", v["origin_server_ts"]);
                                            println!("room id: {:?}", room_id);
                                            println!("sender: {:?}", member.sender);
                                            println!("state key: {:?}", member.state_key);
                                            state.write().invitations.push(Invitation {
                                                event_id: v["event_id"]
                                                    .as_str()
                                                    .unwrap()
                                                    .to_owned(),
                                                timestamp: v["origin_server_ts"].as_u64().unwrap(),
                                                room_id: room_id.to_string(),
                                                sender: member.sender.to_string(),
                                            });
                                        }
                                    }
                                }
                            }
                            // the lock is unlocked here when `s` goes out of scope.
                        }
                        if state.read().should_stop_syncing {
                            state.write().is_syncing = false;
                            return LoopCtrl::Break;
                        } else if !state.read().is_syncing {
                            state.write().is_syncing = true;
                        }
                        LoopCtrl::Continue
                    }
                })
                .await;
            // current events
            client
                .register_event_handler(
                    |ev: OriginalSyncRoomMessageEvent, room: MatrixRoom| async move {
                        if let MatrixRoom::Joined(room) = room {
                            let msg_body = match ev.content.msgtype {
                                MessageType::Text(TextMessageEventContent { body, .. }) => body,
                                _ => return,
                            };
                        }
                    },
                )
                .await;
        });
    }

    /// Indication whether we've received a first sync response since
    /// establishing the client (in memory)
    pub fn has_first_synced(&self) -> bool {
        self.state.read().has_first_synced
    }

    /// Indication whether we are currently syncing
    pub fn is_syncing(&self) -> bool {
        self.state.read().is_syncing
    }

    /// Is this a guest account?
    pub fn is_guest(&self) -> bool {
        self.state.read().is_guest
    }

    pub async fn restore_token(&self) -> Result<String> {
        let session = self.client.session().context("Missing session")?.clone();
        let homeurl = self.client.homeserver().await;
        Ok(serde_json::to_string(&RestoreToken {
            session,
            homeurl,
            is_guest: self.state.read().is_guest,
        })?)
    }

    pub async fn conversations(&self) -> Result<Vec<Conversation>> {
        let c = self.client.clone();
        RUNTIME
            .spawn(async move {
                let (_, conversations) = devide_groups_from_common(c).await;
                Ok(conversations)
            })
            .await?
    }

    pub async fn groups(&self) -> Result<Vec<Group>> {
        let c = self.client.clone();
        RUNTIME
            .spawn(async move {
                let (groups, _) = devide_groups_from_common(c).await;
                Ok(groups)
            })
            .await?
    }

    pub async fn latest_news(&self) -> Result<Vec<News>> {
        Ok(gen_mock_news())
    }

    pub async fn faqs(&self) -> Result<Vec<Faq>> {
        Ok(gen_mock_faqs())
    }

    // pub async fn get_mxcuri_media(&self, uri: String) -> Result<Vec<u8>> {
    //     let l = self.client.clone();
    //     RUNTIME.spawn(async move {
    //         let user_id = l.user_id().await.expect("No User ID found");
    //         Ok(user_id.as_str().to_string())
    //     }).await?
    // }

    pub async fn user_id(&self) -> Result<OwnedUserId> {
        let l = self.client.clone();
        RUNTIME
            .spawn(async move {
                let user_id = l.user_id().context("No User ID found")?;
                Ok(user_id.to_owned())
            })
            .await?
    }

    pub async fn room(&self, room_name: String) -> Result<Room> {
        let room_id = RoomId::parse(room_name)?;
        let l = self.client.clone();
        RUNTIME
            .spawn(async move {
                if let Some(room) = l.get_room(&room_id) {
                    return Ok(Room {
                        room,
                        client: l.clone(),
                    });
                }
                bail!("Room not found")
            })
            .await?
    }

    pub async fn account(&self) -> Result<Account> {
        let user_id = self.client.user_id().unwrap();
        Ok(Account::new(
            self.client.account(),
            user_id.as_str().to_owned(),
        ))
    }

    pub async fn display_name(&self) -> Result<String> {
        let l = self.client.clone();
        RUNTIME
            .spawn(async move {
                let display_name = l
                    .account()
                    .get_display_name()
                    .await?
                    .context("No User ID found")?;
                Ok(display_name.as_str().to_string())
            })
            .await?
    }

    pub async fn device_id(&self) -> Result<String> {
        let l = self.client.clone();
        RUNTIME
            .spawn(async move {
                let device_id = l.device_id().context("No Device ID found")?;
                Ok(device_id.as_str().to_string())
            })
            .await?
    }

    pub async fn avatar(&self) -> Result<api::FfiBuffer<u8>> {
        self.account().await?.avatar().await
    }
}

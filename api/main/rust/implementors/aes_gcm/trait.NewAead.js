(function() {var implementors = {};
implementors["aes_gcm"] = [{"text":"impl&lt;Aes, NonceSize&gt; <a class=\"trait\" href=\"aes_gcm/trait.NewAead.html\" title=\"trait aes_gcm::NewAead\">NewAead</a> for <a class=\"struct\" href=\"aes_gcm/struct.AesGcm.html\" title=\"struct aes_gcm::AesGcm\">AesGcm</a>&lt;Aes, NonceSize&gt; <span class=\"where fmt-newline\">where<br>&nbsp;&nbsp;&nbsp;&nbsp;Aes: <a class=\"trait\" href=\"cipher/block/trait.NewBlockCipher.html\" title=\"trait cipher::block::NewBlockCipher\">NewBlockCipher</a> + <a class=\"trait\" href=\"cipher/block/trait.BlockCipher.html\" title=\"trait cipher::block::BlockCipher\">BlockCipher</a>&lt;BlockSize = <a class=\"type\" href=\"typenum/generated/consts/type.U16.html\" title=\"type typenum::generated::consts::U16\">U16</a>&gt; + <a class=\"trait\" href=\"cipher/block/trait.BlockEncrypt.html\" title=\"trait cipher::block::BlockEncrypt\">BlockEncrypt</a>,<br>&nbsp;&nbsp;&nbsp;&nbsp;Aes::<a class=\"associatedtype\" href=\"cipher/block/trait.BlockCipher.html#associatedtype.ParBlocks\" title=\"type cipher::block::BlockCipher::ParBlocks\">ParBlocks</a>: <a class=\"trait\" href=\"generic_array/trait.ArrayLength.html\" title=\"trait generic_array::ArrayLength\">ArrayLength</a>&lt;<a class=\"type\" href=\"cipher/block/type.Block.html\" title=\"type cipher::block::Block\">Block</a>&lt;Aes&gt;&gt;,<br>&nbsp;&nbsp;&nbsp;&nbsp;NonceSize: <a class=\"trait\" href=\"generic_array/trait.ArrayLength.html\" title=\"trait generic_array::ArrayLength\">ArrayLength</a>&lt;<a class=\"primitive\" href=\"https://doc.rust-lang.org/nightly/std/primitive.u8.html\">u8</a>&gt;,&nbsp;</span>","synthetic":false,"types":["aes_gcm::AesGcm"]}];
if (window.register_implementors) {window.register_implementors(implementors);} else {window.pending_implementors = implementors;}})()
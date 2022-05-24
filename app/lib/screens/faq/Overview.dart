// ignore_for_file: prefer_const_constructors

import 'package:effektio/common/store/separatedThemes.dart';
import 'package:effektio/common/widget/FaqListItem.dart';
<<<<<<< HEAD
import 'package:effektio/screens/EditorScreen/Editor.dart';
=======

>>>>>>> a3294cdc35b5cd197063abbd534652b1f9343557
import 'package:effektio_flutter_sdk/effektio_flutter_sdk_ffi.dart';
import 'package:flutter/material.dart';

class FaqOverviewScreen extends StatefulWidget {
  const FaqOverviewScreen({Key? key, required this.client}) : super(key: key);
  final Client client;

  @override
  _FaOverviewqScreenState createState() => _FaOverviewqScreenState();
}

class _FaOverviewqScreenState extends State<FaqOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FfiListFaq>(
      future: widget.client.faqs(),
      builder: (BuildContext context, AsyncSnapshot<FfiListFaq> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
<<<<<<< HEAD
            color: AppColors.backgroundColor,
=======
            color: AppCommonTheme.backgroundColor,
>>>>>>> a3294cdc35b5cd197063abbd534652b1f9343557
            child: Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
<<<<<<< HEAD
                  color: AppColors.primaryColor,
=======
                  color: AppCommonTheme.primaryColor,
>>>>>>> a3294cdc35b5cd197063abbd534652b1f9343557
                ),
              ),
            ),
          );
        } else {
<<<<<<< HEAD
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.faqBackgroundColor,
              title: Text(
                'Faq',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Container(
                    margin: const EdgeInsets.only(bottom: 10, right: 10),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HtmlEditorExample(
                          title: 'Create FAQ',
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            body: Container(
              color: AppColors.faqBackgroundColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.requireData.length,
                itemBuilder: (BuildContext context, int index) {
                  return FaqListItem(
                    client: widget.client,
                    faq: snapshot.requireData[index],
                  );
                },
              ),
            ),
=======
          //final items = snapshot.requireData.toList();
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.requireData.length,
            itemBuilder: (BuildContext context, int index) {
              return FaqListItem(
                client: widget.client,
                faq: snapshot.requireData[index],
              );
            },
>>>>>>> a3294cdc35b5cd197063abbd534652b1f9343557
          );
        }
      },
    );
  }
}

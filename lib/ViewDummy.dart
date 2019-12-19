import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klippit/base_module.dart';
import 'package:image_picker/image_picker.dart';
import 'assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewDummy extends StatefulWidget {
  @override
  _ViewDummyState createState() => _ViewDummyState();
}

class _ViewDummyState extends State<ViewDummy> {
  var username = TextEditingController();
  var earned = TextEditingController();
  int avatarPosition = -1;
  var image;
  bool useAvatar = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<BaseModel> dummies = List();
  bool hasLoaded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadDummies();
  }

  loadDummies() async {
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(IS_DUMMY, isEqualTo: true)
        .getDocuments();
    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      dummies.add(model);
      hasLoaded = true;
      setState(() {});
    }
    hasLoaded = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        title: Text(
          "View Dummies",
          style: textStyle(false, 20, white),
        ),
      ),
      body: page(),
    );
  }

  page() {
    if (!hasLoaded) return loadingLayout();

    return ListView.separated(
      itemCount: dummies.length,
      itemBuilder: (ctx, index) {
        BaseModel model = dummies[index];
        return InkWell(
          onTap: () {
            bool disabled = model.getBoolean(DISABLED);
            showListDialog(
                context,
                [
                  "${disabled ? "Enable" : "Disable"} Dummy",
                  "Delete Dummy",
                ],
                usePosition: false, onClicked: (position) {
              if (position == "Enable Dummies") {
                model
                  ..put(DISABLED, false)
                  ..updateItems();

                return;
              }

              if (position == "Disable Dummies") {
                model
                  ..put(DISABLED, true)
                  ..updateItems();

                return;
              }

              if (position == "Delete Dummy") {
                showMessage(context, Icons.warning, Colors.red, "Delete Dummy?",
                    "Are you sure you want to delete this dumy user data?",
                    clickYesText: "Yes",
                    cancellable: false,
                    clickNoText: "No", onClicked: (_) async {
                  if (_) {
                    model.deleteItem();
                    dummies.removeAt(index);
                    setState(() {});
                  }
                }, delayInMilli: 900);
                return;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    imageHolder(
                      50,
                      model.getBoolean(USE_AVATAR)
                          ? avatars[model.getInt(AVATAR_POSITION)]
                          : model.getImage(),
                      local: model.getBoolean(USE_AVATAR),
                    ),
                    addSpaceWidth(10),
                    Text(
                      model.getString(USERNAME),
                      style: textStyle(true, 17, black),
                    ),
                  ],
                ),
                Text(
                  "\$1",
                  //"\$${model.getInt(AMOUNT_EARNED)}",
                  style: textStyle(true, 17, black),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (ctx, index) {
        return addLine(0.5, light_grey, 15, 0, 15, 0);
      },
    );
  }
}

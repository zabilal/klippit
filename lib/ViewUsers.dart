import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klippit/base_module.dart';
import 'package:image_picker/image_picker.dart';
import 'assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewUsers extends StatefulWidget {
  @override
  _ViewUsersState createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  var username = TextEditingController();
  var earned = TextEditingController();
  int avatarPosition = -1;
  var image;
  bool useAvatar = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<BaseModel> appUsers = List();
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
        //.where(IS_DUMMY, isEqualTo: false)
        .getDocuments();
    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      if (model.getBoolean(IS_DUMMY)) continue;
      appUsers.add(model);
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
          "View Users",
          style: textStyle(false, 20, white),
        ),
      ),
      body: page(),
    );
  }

  page() {
    if (!hasLoaded) return loadingLayout();

    return Column(
      children: <Widget>[
        Container(
          color: red,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(8),
          child: Text(
            "Klippit has a total of ${appUsers.length} Users",
            style: textStyle(false, 16, white),
          ),
        ),
        Flexible(
          child: ListView.separated(
            itemCount: appUsers.length,
            itemBuilder: (ctx, index) {
              BaseModel model = appUsers[index];
              return InkWell(
                onLongPress: () {
                  showMessage(
                      context,
                      Icons.warning,
                      Colors.red,
                      "Delete User?",
                      "Are you sure you want to delete this users data?",
                      clickYesText: "Yes",
                      cancellable: false,
                      clickNoText: "No", onClicked: (_) async {
                    if (_) {
                      model.deleteItem();
                      appUsers.removeAt(index);
                      setState(() {});
                    }
                  }, delayInMilli: 900);
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                model.getFullName(),
                                style: textStyle(true, 17, black),
                              ),
                              addSpace(5),
                              Text(
                                model.getEmail(),
                                style: textStyle(false, 15, black),
                              ),
                              addSpace(5),
                              Text(
                                model.getString(PHONE_NO),
                                style: textStyle(false, 15, black),
                              ),
                              addSpace(5),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        //"\$1",
                        "\$${model.getInt(AMOUNT_EARNED)}",
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
          ),
        ),
      ],
    );
  }
}

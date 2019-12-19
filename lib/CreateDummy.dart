import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klippit/base_module.dart';
import 'package:image_picker/image_picker.dart';
import 'assets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateDummy extends StatefulWidget {
  @override
  _CreateDummyState createState() => _CreateDummyState();
}

class _CreateDummyState extends State<CreateDummy> {
  var username = TextEditingController();
  var earned = TextEditingController();
  int avatarPosition = -1;
  var image;
  bool useAvatar = false;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        title: Text(
          "Create Dummy",
          style: textStyle(false, 20, white),
        ),
      ),
      body: page(),
    );
  }

  page() {
    return ListView(
      padding: EdgeInsets.all(15),
      children: <Widget>[
        imageHolder(80, image ?? "", strokeColor: bgColor, local: useAvatar,
            onImageTap: () {
          showListDialog(
            context,
            [
              "Use Avatar",
              "Add Photo",
            ],
            onClicked: (position) async {
              if (position == 0) {
                Future.delayed(Duration(milliseconds: 10), () async {
                  var p = await popUpWidget(
                      context,
                      AvatarLayout(
                        avatarPosition: avatarPosition,
                      ));
                  if (p != null) {
                    setState(() {
                      useAvatar = true;
                      avatarPosition = p[0];
                      image = p[1];
                    });
                  }
                });
                return;
              }

              if (position == 1) {
                showListDialog(
                  context,
                  [
                    "Pick from camera",
                    "Pick from gallery",
                  ],
                  onClicked: (position) async {
                    if (position == 0) {
                      var file = await pickImageAndCrop(ImageSource.camera,
                          canCrop: true, useCircle: true);
                      if (file == null) return;
                      setState(() {
                        useAvatar = false;
                        image = file;
                      });
                      return;
                    }

                    if (position == 1) {
                      var file = await pickImageAndCrop(ImageSource.gallery,
                          canCrop: true, useCircle: true);
                      print(file);
                      if (file == null) return;
                      setState(() {
                        useAvatar = false;
                        image = file;
                      });
                      return;
                    }
                  },
                  useTint: false,
                  delayInMilli: 10,
                );

                return;
              }
            },
            useTint: false,
            delayInMilli: 10,
          );
        }),
        inputItem("USERNAME", username, Icons.person, () {},
            hint: "Enter username"),
        inputItem(
          "AMOUNT",
          earned,
          Icons.attach_money,
          () {},
          hint: "Enter amount earned",
          inputType: TextInputType.number,
        ),
        addSpace(10),
        RaisedButton(
          onPressed: createDumAcct,
          padding: EdgeInsets.all(15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text("Create User")),
        )
      ],
    );
  }

  createDumAcct() async {
    if (image == null) {
      toast(scaffoldKey, "Please select either an image or avatar!");
      return;
    }
    if (username.text.isEmpty) {
      toast(scaffoldKey, "Please enter fullname!");
      return;
    }
    if (earned.text.isEmpty) {
      toast(scaffoldKey, "Please enter amount earned!");
      return;
    }

    showProgress(true, context, msg: "CREATING DUMMY USER...");

    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(USERNAME, isEqualTo: username.text.trim())
        .limit(1)
        .getDocuments();
    if (shots.documents.length > 0) {
      showProgress(false, context);
      showMessage(
          context,
          Icons.warning,
          Colors.red,
          "Username Error!",
          "The username choosen already exists in our record, please "
              "choose a unique username and try again.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }

    BaseModel model = BaseModel();
    model.put(USER_ID, getRandomId());
    model.put(USERNAME, username.text);
    model.put(AMOUNT_EARNED, int.parse(earned.text));
    model.put(USE_AVATAR, useAvatar);
    model.put(AVATAR_POSITION, avatarPosition);
    model.put(IS_DUMMY, true);
    model.saveItem(USER_BASE, false, document: model.getUId(), onComplete: () {
      if (!(image is File)) {
        showProgress(false, context);
        showMessage(context, Icons.check, dark_green1, "Dummy Created!",
            "Dummy user has been successfully created!", clickYesText: "Ok",
            onClicked: (_) {
          username.clear();
          earned.clear();
          image = "";
          setState(() {});
        }, cancellable: true, delayInMilli: 900);
        return;
      }
      uploadFile(image, (url, error) {
        if (error != null) {
          showProgress(false, context);
          showMessage(context, Icons.warning, Colors.red, "Upload Error!",
              error.toString(), clickYesText: "Try Again", cancellable: false,
              onClicked: (_) async {
            model.deleteItem();
          }, delayInMilli: 1000);
          return;
        }

        print(url);
        model.put(IMAGE, url);
        model.updateItems();
        showMessage(context, Icons.check, dark_green1, "Dummy Created!",
            "Dummy user has been successfully created!", clickYesText: "Ok",
            onClicked: (_) {
          showProgress(false, context);
          username.clear();
          earned.clear();
          image = "";
          setState(() {});
        }, cancellable: true, delayInMilli: 1000);
        return;
      });
    });
  }
}

class AvatarLayout extends StatelessWidget {
  //final Function(int p,String img) onTap;
  final int avatarPosition;

  const AvatarLayout({Key key, /*this.onTap,*/ this.avatarPosition = -1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Material(
        color: black.withOpacity(.4),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 45, 25, 25),
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              decoration: BoxDecoration(
                  color: white, borderRadius: BorderRadius.circular(15)),
              //alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Container(
                    width: double.infinity,
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        addSpaceWidth(15),
                        Image.asset(
                          ic_launcher,
                          height: 20,
                          width: 20,
                        ),
                        addSpaceWidth(10),
                        new Flexible(
                          flex: 1,
                          child: new Text(
                            APP_NAME,
                            style: textStyle(false, 11, black.withOpacity(.1)),
                          ),
                        ),
                        addSpaceWidth(15),
                      ],
                    ),
                  ),
                  addSpace(5),
                  avatarPage(context)
                ],
              ),
              //child: avatarPage(),
            ),
          ),
        ),
      ),
    );
  }

  avatarPage(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (c, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context, [index, avatars[index]]);
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Image.asset(
                  avatars[index],
                  height: 60,
                  width: 60,
                  fit: BoxFit.fitHeight,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  //border: Border.all(color: black.withOpacity(.1))
                ),
              ),
              if (avatarPosition == index)
                Container(
                  height: 70,
                  width: 70,
                  padding: EdgeInsets.all(10),
                  child: Icon(
                    Icons.check,
                    color: white,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: black.withOpacity(.5),
                      border: Border.all(color: black.withOpacity(.1))),
                ),
            ],
          ),
        );
      },
      itemCount: avatars.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
    );
  }
}

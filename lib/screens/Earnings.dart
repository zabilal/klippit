import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/screens/InfoDialog.dart';
import 'package:share/share.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Earnings extends StatefulWidget {
  @override
  _EarningsState createState() => _EarningsState();
}

class _EarningsState extends State<Earnings> {
  bool hasLoaded = false;
  List<BaseModel> referredList = List();
  var controller = ScrollController();
  double padding = 50;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadReferrals();
    controller.addListener(() {
      if (controller != null && controller.position.pixels == 0) {
        setState(() {
          padding = 50;
        });
      } else {
        setState(() {
          padding = 20;
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  loadReferrals() async {
    for (String userID in userModel.getList(REFERRALS)) {
      try {
        var users = await Firestore.instance
            .collection(USER_BASE)
            .document(userID)
            .get();
        //print(users.data);
        if (users.exists) {
          BaseModel model = BaseModel(doc: users);
          if (userModel.getString(INVITED_BY) == userID)
            model.put(SHOW_INVITED, true);
          referredList.add(model);
        }
        hasLoaded = true;
        if (mounted) setState(() {});
      } on PlatformException catch (e) {
        print("Error $e");
      }
    }
    hasLoaded = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //return Sliver
    return Scaffold(
      //backgroundColor: white,
      backgroundColor: bgColor,
      //appBar: appBar(),
      //body: page2(),
      body: page(),
    );
  }

  appBar() {
    /*   return AppBar(
      backgroundColor: white,
      elevation: .5,
      title: Text(
        "Your Earnings",
        style: textStyle(true, 18, textColor),
      ),
      iconTheme: IconThemeData(color: textColor),
    );*/
    return Container(
      color: white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BackButton(),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        "Your Earnings",
                        style: textStyle(true, 25, black),
                      ),
                      addSpaceWidth(10),
                      GestureDetector(onTap: (){
                        pushAndResult(context, InfoDialog());
                      },
                        child: Image.asset(
                          information,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "\$",
                        style: textStyle(true, 25, black),
                      ),
                      Text(
                        "${userModel.getInt(AMOUNT_EARNED)}",
                        style: textStyle(true, 40, black),
                      ),
                      /*Text(
                        "150",
                        style: textStyle(true, 40, black),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    child: addLine(4, btnColor.withOpacity(.2), 5, 10, 0, 10)),
                Flexible(child: addLine(4, Colors.yellow, 0, 10, 5, 10)),
              ],
            )
          ],
        ),
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        appBar(),
        pageTop(),
        addSpace(10),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: GestureDetector(
            onTap: () async {
              await Share.share(
                "Hey when you sign up for Klippit we both earn \$1."
                " Use my referal code ${userModel.getDocId().substring(0, 8).toUpperCase()}",
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Invite friends, earn money ",
                  textAlign: TextAlign.start,
                  style: textStyle(true, 18, white),
                ),
                Icon(
                  Icons.add_circle,
                  size: 40,
                  color: white,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  pageTop() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(15),
        color: white,
        child: LayoutBuilder(builder: (context, box) {
          if (!hasLoaded) return loadingLayout();
          if (referredList.isEmpty) return Container();
          /*if (referredList.isEmpty)
            return emptyLayout(Icons.account_balance_wallet, "No Invite",
                "You have no earnings yet", clickText: "Invite friends",
                click: () async {
              await Share.share(
                "Hey when you sign up for Klippit we both earn \$1."
                "Register on Klippit with referal code ${userModel.getDocId().substring(0, 8).toUpperCase()}",
              );
            }, isIcon: true);*/
          return ListView(
            padding: EdgeInsets.all(0),
            children: List.generate(referredList.length, (index) {
              BaseModel model = referredList[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
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
                              if (model.getBoolean(SHOW_INVITED)) ...[
                                addSpace(4),
                                Text(
                                  "Invited you",
                                  style: textStyle(
                                      false, 12, black.withOpacity(.6)),
                                ),
                              ]
                            ],
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
                  addLine(1, light_grey, 0, 10, 0, 10),
                  if (index == referredList.length - 1)
                    Text(
                      "(These friends signed up with your reward code)",
                      textAlign: TextAlign.center,
                      style: textStyle(false, 12, black.withOpacity(.6)),
                    )
                ],
              );
            }),
          );
        }),
      ),
    );
  }
}

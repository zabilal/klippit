import 'dart:async';

import 'package:klippit/navigationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:klippit/base_module.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Login.dart';
import 'assets.dart';
import 'SignUp.dart';
import 'backbone/NotifyEngine.dart';
import 'backbone/UsersEngine.dart';
import 'main.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:device_info/device_info.dart';

class PreLaunch extends StatefulWidget {
  @override
  _PreLaunchState createState() => _PreLaunchState();
}

class _PreLaunchState extends State<PreLaunch> {
  var scrollController = ScrollController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;
  bool scrollPressedDown = false;
  bool enableInfinity = true;
  int realPage = 10000;
  double counter = 0;
  String iosType = "";
  IosDeviceInfo iosInfo;
  bool scrollStarted = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setDeviceType();
    initKickOffScroll();
    scrollController.addListener(autoScrollListener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController?.removeListener(autoScrollListener);
    scrollController?.dispose();
    timer?.cancel();
    super.dispose();
  }

  initKickOffScroll() {
    Future.delayed(Duration(milliseconds: 15), () {
      if (scrollController == null || scrollController.positions.isEmpty) {
        initKickOffScroll();
        print("Not initialized");
        return;
      }
      print("initialized");
      scrollController.animateTo(
        15,
        duration: new Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    });
  }

  setDeviceType() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    /*IosDeviceInfo*/ iosInfo = await deviceInfo.iosInfo;
    iosType = iosInfo.utsname.machine;
    if (mounted) {
      setState(() {});
    }
  }

  autoScrollListener() {
    if (scrollPressedDown) return;
    counter = scrollController.position.pixels + 25;

    if (scrollController != null && !scrollController.position.outOfRange) {
      scrollController.animateTo(
        counter,
        duration: new Duration(milliseconds: 3000),
        curve: Curves.linear,
      );
    }

    setState(() {});
  }

  int _getRealIndex(int position, int base, int length) {
    final int offset = position - base;
    return _remainder(offset, length);
  }

  int _remainder(int input, int source) {
    final int result = input % source;
    return result < 0 ? source + result : result;
  }

  @override
  Widget build(BuildContext context) {
    //print(60 * MediaQuery.of(context).size.aspectRatio);
    ScreenUtil.instance = ScreenUtil.getInstance()..init(context);

    //Handle the notification
//    BaseModel bm = BaseModel();
//    bm.put(TITLE, "You've just earned \$1!");
//    bm.put(
//        MESSAGE,
//        "👏💸 ${userModel.getFullName()}"
//        " signed up for Klippit using your ref code."
//        "Keep going!");
//    bm.put(TOKEN_ID,
//        "d6WLVbp1ETI:APA91bGQtQbwNfhkNdaqJgSgz9VZF3F4c0Aw0umkOGGzpteQzoT9zE-EHQ6auLnwxp7bcQbDlLvC7A0ZuHjhbj_zDVCvkCqzVjuqfEcIjufOgaUotNnBUqVhISv5IR3xiXpDRSuHXn7M");
//    //"fi5-GeBbOFc:APA91bG2QNDXse8ua6xrL4-wZgodbwZqO3k2ddvKKYPmFpPWSE8O_spQWlaNddHnsGkn1jZgxmaCeA_zwI77hD3r3TX-1zI_cdktxLf895hWPj-Z0Qu6FX0_RrBNNnWF3mVomJt-U5EC");
//    NotifyEngine(context, bm, HandleType.outgoingNotification,
//        notificationType: NotifyType.referral00);

    //print(ScreenUtil.getInstance().setWidth(250));
    return Scaffold(
      backgroundColor: bgColor,
      body: page(),
    );
  }

  page() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        bgImageV(),
        pBody(),
        //topIconV()
        //randUsersV(), topIconV(), bottomV()
      ],
    );
  }

  pBody() {
    return Column(
      children: <Widget>[
        topIconV(),
        Flexible(
          child: GestureDetector(
            onTap: () {
              setState(() {
                scrollPressedDown = true;
              });

              Future.delayed(Duration(milliseconds: 5), () {
                scrollController.animateTo(
                  1,
                  duration: new Duration(milliseconds: 50),
                  curve: Curves.linear,
                );
                setState(() {
                  scrollPressedDown = false;
                });
              });
            },
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1.1),
              itemBuilder: (c, index) {
                return randUsersItem1(index);
              },
              itemCount: enableInfinity ? null : earnedUsers.length,
              //reverse: reverseScroll,
              //padding: EdgeInsets.only(top: 10, bottom: 10),
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        bottomV()
      ],
    );
  }

  randUsersItem1(int index) {
    final int p = _getRealIndex(
        index /*+ widget.initialPage*/, realPage, earnedUsers.length);

    BaseModel model = earnedUsers[p];
    bool isCenter = (p).isEven;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (isCenter) addSpaceWidth(18),
        /*IgnorePointer(
          child: AvatarBuilder(
            imageUrl: model.getImage(),
            avatarSize: MediaQuery.of(context).size.width * .2,
            canClick: false,
          ),
        ),*/
        AbsorbPointer(
          absorbing: false,
          child: imageHolder(
            //byChike ? 90 : 60,
            ScreenUtil.getInstance().setWidth(250),
            model.getBoolean(USE_AVATAR)
                ? avatars[model.getInt(AVATAR_POSITION)]
                : model.getImage(),
            local: model.getBoolean(USE_AVATAR),
          ),
        ),
        addSpace(2),
        Text(
          model.getString(USERNAME),
          style: textStyle(false, 12, Colors.black.withOpacity(.6)),
        ),
        /*addSpace(2),
        Text(
          "earned",
          style: textStyle(true, 12, black),
        ),
        Text(" \$${model.getInt(AMOUNT_EARNED)}",
            style: textStyle(true, 15, black)),*/
        addSpace(2),
        Text("Earned \$${model.getInt(AMOUNT_EARNED)}",
            style: TextStyle(fontSize: 12, color: Colors.white, shadows: [
              Shadow(color: Colors.black.withOpacity(.6), blurRadius: 5)
            ])),
      ],
    );
  }

  bgImageV() {
    return Container(
      //width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          image:
              DecorationImage(image: AssetImage(Backdrop), fit: BoxFit.cover)),
    );
  }

  topIconV() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          //height: 50,
          child: Image.asset(
            logo_bg,
            height: ScreenUtil.getInstance().setWidth(260), //90,
            alignment: Alignment.center,
            //width: MediaQuery.of(context).size.width * .6,
            //alignment: Alignment.topCenter,
          ),
        ),
      ),
    );
  }

  bottomV() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text("Join now,",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: (MediaQuery.of(context).size.width / 2) * .1,
                    fontWeight: FontWeight.bold)),
            addSpace(5),
            Text("Invite Friends and Earn",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: (MediaQuery.of(context).size.width / 2) * .1,
                    fontWeight: FontWeight.bold)),
            addSpace(5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(money_bag,
                      height: ScreenUtil.getInstance().setWidth(80), //20,
                      width: ScreenUtil.getInstance().setWidth(80) //20,
                      ),
                );
              }),
            ),
            addSpace(5),
            RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: Center(
                  child: Text(
                "Sign Up",
                style: textStyle(true, 20, textColor),
              )),
              onPressed: () {
                goToWidget(context, SignUp());
              },
            ),
            addSpace(10),
            GestureDetector(
              onTap: () {
                goToWidget(context, Login());
              },
              child: Text("Already have an account? Sign In",
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
            addSpace(10),
          ],
        ),
      ),
    );
  }
}

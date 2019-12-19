import 'dart:async';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:klippit/backbone/basemodel.dart';
import 'package:klippit/base_module.dart';
import 'package:klippit/navigationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/screens/Terms.dart';
import 'package:dotted_border/dotted_border.dart';
import 'CreateDummy.dart';
import 'PreLaunch.dart';
import 'ViewDummy.dart';
import 'ViewUsers.dart';
import 'main.dart';
import 'screens/HowitWorks.dart';
import 'screens/AboutKlippit.dart';
import 'screens/Earnings.dart';
import 'screens/NeedHelp.dart';
import 'screens/PrivacyPolicy.dart';
import 'screens/VerifiedInfluencers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

var _firebaseMessaging = FirebaseMessaging();

class MainHome extends StatefulWidget {
  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  bool reverseScroll = false;
  var scrollController = ScrollController();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  Timer timer;
  bool enableInfinity = true;
  int realPage = 10000;
  double counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createBasicListeners();
    setupPush();
    scrollController.addListener(autoScrollListener);
    Future.delayed(Duration(milliseconds: 15), () {
      scrollController.animateTo(
        1,
        duration: new Duration(milliseconds: 50),
        curve: Curves.linear,
      );
    });
  }

  createFirebaseDynamicLink(onLinkCreated) async {
    print("url......");
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://klippitapp.com',
      link: Uri.parse(
          // 'https://klippitapp.com/invitedBy?p1=${userModel.getFullName()}&p2=${userModel.getUId()}'),
          // 'https://klippitapp.com/invitedBy?p=${userModel.getString(REWARD_CODE)}'),
          'https://klippitapp.com/invitedBy?p=${userModel.getRewardCode()}'),
      androidParameters: AndroidParameters(
        packageName: 'com.klippit',
        minimumVersion: 16,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.fluidangle.klippitApp',
        minimumVersion: '1.0.1',
        appStoreId: '1479612085',
      ),
    );
    parameters.buildShortLink().then((ur) {
      onLinkCreated(ur.shortUrl.toString());
    }).catchError(onError);
  }

  bool hasStarted = false;
  List<StreamSubscription> subscriptions = List();

  createBasicListeners() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print(user.uid);
    if (user != null) {
      var sub = Firestore.instance
          .collection(USER_BASE)
          .document(user.uid)
          .snapshots()
          .listen((shot) async {
        if (!shot.exists) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) {
            return PreLaunch();
          }));
          return;
        }
        userModel = BaseModel(doc: shot);
        //isAdmin = userModel.isMaugost() || userModel.getBoolean(IS_ADMIN);
        isAdmin = userModel.isMaugost() ||
            userModel.getEmail() == "chibuike.nwoke@gmail.com" ||
            userModel.getBoolean(IS_ADMIN);
        hasStarted = true;
        if (!hasStarted) {
          setupPush();
          scrollController.addListener(autoScrollListener);
          Future.delayed(Duration(milliseconds: 15), () {
            scrollController.animateTo(
              1,
              duration: new Duration(milliseconds: 50),
              curve: Curves.linear,
            );
          });
        }
        if (mounted) setState(() {});
      });
      subscriptions.add(sub);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    scrollController?.removeListener(autoScrollListener);
    scrollController?.dispose();
    timer?.cancel();
    for (StreamSubscription sub in subscriptions) sub?.cancel();
    super.dispose();
  }

  setupPush() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: ${message['data']}");
        BaseModel bm = BaseModel(items: message['data']);
        print(bm.items);
        //NotifyEngine(context, bm, HandleType.incomingNotification);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: ${message['data']}");
        BaseModel bm = BaseModel(items: message['data']);
        print(bm.items);
        //NotifyEngine(context, bm, HandleType.incomingNotification);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: ${message['data']}");
        BaseModel bm = BaseModel(items: message['data']);
        print(bm.items);
        //NotifyEngine(context, bm, HandleType.incomingNotification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.setAutoInitEnabled(true);
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.getToken().then((String token) async {
      userModel.put(PUSH_NOTIFICATION_TOKEN, token);
      userModel.updateItems();
    });
  }

  bool drawerVisible = false;
  autoScrollListener() {
    /*counter = counter < scrollController.position.maxScrollExtent
        ? scrollController.position.pixels + 100
        : scrollController.position.maxScrollExtent;*/
    if (drawerVisible) {
      return;
    }
    setState(() {
      counter = scrollController.position.pixels + 25;
      //counter = counter + 5;
    });

    if (scrollController != null && !scrollController.position.outOfRange) {
      scrollController.animateTo(
        counter,
        duration: new Duration(milliseconds: 3000),
        curve: Curves.linear,
      );
    }
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
    //Scaffold.of(context).hasEndDrawer

    return Scaffold(
      backgroundColor: bgColor1,
      key: scaffoldKey,
      drawer: kDrawer(),
      body: pageB(),
//      drawerCallback: (open) {
//        if (open) {
//          setState(() {
//            drawerVisible = true;
//          });
//        } else {
//          setState(() {
//            drawerVisible = false;
//          });
//          Future.delayed(Duration(milliseconds: 15), () {
//            print("scrolling enabled");
//            scrollController.animateTo(
//              counter + 5,
//              duration: new Duration(milliseconds: 50),
//              curve: Curves.linear,
//            );
//          });
//        }
//      },
    );
  }

  randUsersItem(int index) {
    final int p = _getRealIndex(
        index /*+ widget.initialPage*/, realPage, earnedUsers.length);

    BaseModel model = earnedUsers[p];
    //BaseModel model = randUsers[index];
    bool isCenter = (p).isEven;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (isCenter) addSpace(12),
        IgnorePointer(
          child: imageHolder(
            60,
            model.getBoolean(USE_AVATAR)
                ? avatars[model.getInt(AVATAR_POSITION)]
                : model.getImage(),
            local: model.getBoolean(USE_AVATAR),
          ),
        ),
        /*IgnorePointer(
          child: imageHolder(60, model.getImage()),
        ),*/
        addSpace(2),
        Text(
          model.getString(USERNAME),
          style: textStyle(false, 12, Colors.black.withOpacity(.6)),
        ),
        addSpace(2),
        Text(
          "earned",
          style: textStyle(true, 12, black),
        ),
        Text("\$${model.getInt(AMOUNT_EARNED)}",
            textAlign: TextAlign.center, style: textStyle(true, 14, black)),
      ],
    );
  }

  pageB() {
    Text(
      "How do I achieve this message dot on  chat with firebase firestore?",
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return Stack(
      //fit: StackFit.expand,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 3,
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.elliptical(150, 50),
                bottomRight: Radius.elliptical(150, 50),
              )),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: GestureDetector(
                    onTap: () {
                      scaffoldKey.currentState.openDrawer();
                      bool open = scaffoldKey.currentState.isDrawerOpen;
                      if (open) {
                        setState(() {
                          drawerVisible = true;
                        });
                      } else {
                        setState(() {
                          drawerVisible = false;
                        });
                        Future.delayed(Duration(milliseconds: 15), () {
                          print("scrolling enabled");
                          scrollController.animateTo(
                            counter + 5,
                            duration: new Duration(milliseconds: 50),
                            curve: Curves.linear,
                          );
                        });
                      }
                    },
                    child: Icon(
                      Icons.menu,
                      color: white,
                      //size: 18,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        addSpace(10),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "${userModel.getString(USERNAME)},\nWelcome Back.",
                                style: textStyle(true, 20, white),
                              ),
                              CupertinoButton(
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Total Earnings",
                                        style: textStyle(true, 14, white),
                                      ),
                                      Row(
                                        //crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            "\$${userModel.getInt(AMOUNT_EARNED)}",
                                            style: textStyle(true, 40, white),
                                          ),
                                          /*Text(
                                          "\$150",
                                          style: textStyle(true, 40, white),
                                        ),*/
                                          Icon(
                                            Icons.navigate_next,
                                            size: 25,
                                            color: white.withOpacity(.7),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  pressedOpacity: 0.5,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    goToWidget(context, Earnings());
                                  }),
//                              InkWell(
//                                onTap: () {
//                                  //goToWidget(context, Earnings());
//                                },
//                                child: Column(
//                                  children: <Widget>[
//                                    Text(
//                                      "Total Earnings",
//                                      style: textStyle(true, 14, white),
//                                    ),
//                                    Row(
//                                      //crossAxisAlignment: CrossAxisAlignment.end,
//                                      children: <Widget>[
//                                        Text(
//                                          "\$${userModel.getInt(AMOUNT_EARNED)}",
//                                          style: textStyle(true, 40, white),
//                                        ),
//                                        /*Text(
//                                          "\$150",
//                                          style: textStyle(true, 40, white),
//                                        ),*/
//                                        Icon(
//                                          Icons.navigate_next,
//                                          size: 25,
//                                          color: white.withOpacity(.7),
//                                        )
//                                      ],
//                                    ),
//                                  ],
//                                ),
//                              ),
                            ],
                          ),
                        ),
                        addSpace(15),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(15)),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                addSpace(10),
                                Text(
                                  "Share to Keep Earning",
                                  style: textStyle(true, 25, txColor),
                                ),
                                addSpace(10),
                                GestureDetector(
                                    onLongPress: () {
                                      if (!isAdmin) return;
                                      showListDialog(
                                        context,
                                        [
                                          "Logout",
                                          "Add Admin User",
                                          "Remove Admin User",
                                          "Create Dummy",
                                          "Reset Users",
                                          "Enable Dummies",
                                          "Disable Dummies",
                                          "View Dummies",
                                          "View Users",
                                        ],
                                        usePosition: false,
                                        onClicked: (position) {
                                          if (position == "Logout") {
                                            showMessage(
                                                context,
                                                Icons.warning,
                                                Colors.red,
                                                "Logout?",
                                                "Are you sure you want to logout?",
                                                clickYesText: "Yes",
                                                cancellable: true,
                                                onClicked: (_) async {
                                              showProgress(true, context,
                                                  cancellable: true,
                                                  msg: "Logging Out");
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              await BaseModule
                                                  .resetCurrentUser();
                                              userListenerController?.cancel();
                                              clearScreenUntil(
                                                  context, PreLaunch());
                                            });
                                            return;
                                          }

                                          if (position == "Add Admin User") {
                                            pushAndResult(
                                                context,
                                                inputDialog(
                                                  "Email Address",
                                                  inputType: TextInputType.text,
                                                ), result: (_) async {
                                              if (_ == null) return;
                                              String email =
                                                  _.toLowerCase().trim();
                                              makeAdmin(email, true);
                                            });
                                            return;
                                          }
                                          if (position == "Remove Admin User") {
                                            pushAndResult(
                                                context,
                                                inputDialog(
                                                  "Email Address",
                                                  inputType: TextInputType.text,
                                                ), result: (_) async {
                                              if (_ == null) return;
                                              String email =
                                                  _.toLowerCase().trim();
                                              makeAdmin(email, false);
                                            });
                                            return;
                                          }
                                          if (position == "Create Dummy") {
                                            popUpWidget(context, CreateDummy());
                                            return;
                                          }
                                          if (position == "Reset Users") {
                                            showMessage(
                                                context,
                                                Icons.warning,
                                                Colors.red,
                                                "Reset Users?",
                                                "Are you sure you want to reset all users data?",
                                                clickYesText: "Yes",
                                                cancellable: false,
                                                clickNoText: "No",
                                                onClicked: (_) async {
                                              if (_) resetUsers();
                                            }, delayInMilli: 600);
                                            return;
                                          }
                                          if (position == "Disable Dummies") {
                                            appSettingsModel
                                              ..put(DISABLE_DUMMY, true)
                                              ..updateItems();

                                            return;
                                          }

                                          if (position == "Enable Dummies") {
                                            appSettingsModel
                                              ..put(DISABLE_DUMMY, false)
                                              ..updateItems();

                                            return;
                                          }
                                          if (position == "View Dummies") {
                                            popUpWidget(context, ViewDummy());
                                            return;
                                          }

                                          if (position == "View Users") {
                                            popUpWidget(context, ViewUsers());
                                          }
                                        },
                                        useTint: false,
                                        delayInMilli: 10,
                                      );
                                    },
                                    child: CupertinoButton(
                                        onPressed: () async {
                                          createFirebaseDynamicLink((_) async {
                                            await Share.share(
                                              "Hey when you sign up for Klippit we both earn \$1."
                                              " Use my referal link $_",
                                            );
                                          });
                                        },
                                        pressedOpacity: 0.5,
                                        padding: EdgeInsets.all(0),
                                        child: Image.asset(mail, height: 80))),
                                addSpace(10),
                                Text(
                                  "Invite",
                                  style: textStyle(
                                      true, 12, black.withOpacity(.5)),
                                ),
                                addSpace(10),
                                Text(
                                  "You get \$1,\n when your friends join.",
                                  textAlign: TextAlign.center,
                                  style: textStyle(true, 16, txColor),
                                ),
                                addSpace(10),
                              ],
                            ),
                          ),
                        ),
                        addSpace(15),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    logo_bg,
                                    height: 50,
                                    width: 100,
                                  ),
                                  addSpaceWidth(10),
                                  Text(
                                    "Latest Activity",
                                    style: textStyle(true, 20, bgColor),
                                  ),
                                ],
                              ),
                              Container(
                                height: 250,
                                margin: EdgeInsets.only(top: 15, bottom: 15),
                                child: GridView.builder(
                                  controller: scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1.2),
                                  itemBuilder: (c, index) {
                                    return randUsersItem(index);
                                  },
                                  itemCount: enableInfinity
                                      ? null
                                      : earnedUsers.length,
                                  shrinkWrap: true,
                                  reverse: reverseScroll,
                                  padding: EdgeInsets.all(0),
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),
                              /*Container(
                                height: 250,
                                margin: EdgeInsets.only(top: 15, bottom: 15),
                                child: GridView.builder(
                                  controller: scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1.2),
                                  itemBuilder: (c, index) {
                                    return randUsersItem(index);
                                  },
                                  itemCount:
                                      enableInfinity ? null : randUsers.length,
                                  shrinkWrap: true,
                                  reverse: reverseScroll,
                                  padding: EdgeInsets.all(0),
                                  scrollDirection: Axis.horizontal,
                                ),
                              ),*/
                            ],
                          ),
                        ),
                        addSpace(20),
                        Center(
                          child: Text(
                            "Invite Friends, Earn Money",
                            //"Klippit Is Launching Soon!",
                            textAlign: TextAlign.center,
                            style: textStyle(true, 18, black),
                          ),
                        ),
                        addSpace(10),
                        Text(
                          "We will alert you once we launch Klippit Daily\n "
                          "Deals in the Spring. A seperate app in which you\n"
                          "will be able to retrieve your earnings",
                          textAlign: TextAlign.center,
                          style: textStyle(false, 14, black),
                        ),
                        addSpace(20),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  kDrawer() {
    return Drawer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: white),
          Column(
            children: <Widget>[drawerTop(), drawerBtm()],
          )
        ],
      ),
    );
  }

  drawerTop() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(150, 50),
            bottomRight: Radius.elliptical(150, 50),
          )),
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (userModel.getBoolean(USE_AVATAR)) return;
                showListDialog(
                  context,
                  userModel.getImage().isEmpty
                      ? ["Add Photo"]
                      : [
                          "View Picture",
                          "Update Picture",
                        ],
                  onClicked: (position) async {
                    if (userModel.getImage().isEmpty && position == 0) {
                      addUpdatePicture(context, userModel);
                    }
                    if (userModel.getImage().isEmpty && position == 0 ||
                        userModel.getImage().isNotEmpty && position == 1) {
                      addUpdatePicture(context, userModel);
                      return;
                    }

                    if (userModel.getImage().isNotEmpty && position == 0) {
                      popUpWidget(
                          context,
                          PreviewImage(
                            imageURL: userModel.getImage(),
                          ));
                      return;
                    }
                  },
                  useTint: false,
                  delayInMilli: 10,
                );
              },
              child: imageHolder(
                userModel.getBoolean(USE_AVATAR) ? 70 : 95,
                userModel.getBoolean(USE_AVATAR)
                    ? avatars[userModel.getInt(AVATAR_POSITION)]
                    : userModel.getImage(),
                local: userModel.getBoolean(USE_AVATAR),
              ),
            ),
            addSpace(10),
            Text(
              userModel.getString(USERNAME),
              style: textStyle(true, 18, textColor),
            ),
            addSpace(10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    new ClipboardData(text: userModel.getString(REWARD_CODE)));
                //Clipboard.getData(userModel.getString(REWARD_CODE));
                showMessage(context, Icons.check, green_dark, "Reward Copied",
                    "Link Copied",
                    delayInMilli: 600);
              },
              child: DottedBorder(
                dashPattern: [6, 3, 2, 3],
                color: white,
                padding: EdgeInsets.all(6),
                strokeWidth: 2,
                radius: Radius.circular(15),
                borderType: BorderType.RRect,
                child: Text(
                  userModel.getString(REWARD_CODE),
                  style: textStyle(true, 25, white),
                ),
              ),
            ),
            addSpace(10),
            Text(
              "Your invite code",
              style: textStyle(false, 14, white),
            ),
            addSpace(10),
          ],
        ),
      ),
    );
  }

  addUpdatePicture(BuildContext context, BaseModel profileInfo) {
    showListDialog(
      context,
      [
        "Take a  Picture",
        "Select a Picture",
      ],
      onClicked: (position) async {
        showProgress(true, context, msg: "Uploading Photo");

        if (position == 0) {
          File file = await getImagePicker(ImageSource.camera);
          if (file == null) return;
          File cropped = await cropImage(file);
          UploadEngine uploadEngine = UploadEngine(
              uploadPath: profileInfo.getUId(), fileToSave: cropped);
          String imageURL =
              await uploadEngine.uploadPhoto(uid: profileInfo.getUId());
          userModel.put(IMAGE, imageURL);
          userModel.updateItems();
          showProgress(false, context);
          setState(() {});
        }
        if (position == 1) {
          File file = await getImagePicker(ImageSource.gallery);
          if (file == null) return;
          File cropped = await cropImage(file);
          UploadEngine uploadEngine = UploadEngine(
              uploadPath: profileInfo.getUId(), fileToSave: cropped);
          String imageURL =
              await uploadEngine.uploadPhoto(uid: profileInfo.getUId());
          userModel.put(IMAGE, imageURL);
          userModel.updateItems();
          showProgress(false, context);
          setState(() {});
        }
      },
      useTint: false,
      delayInMilli: 10,
    );
  }

  drawerBtm() {
    //print("About KlippIt".length);
    return Flexible(
      child: SingleChildScrollView(
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //padding: EdgeInsets.only(left: 10, right: 10),
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                child: Column(
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, AboutKlippit());
                        },
                        title: Text(
                          "About KlippIt",
                          style: textStyle(true, 18, textColor2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: ("About KlippIt".length * 12).roundToDouble(),
                          left: 10),
                      child: addLine(4, Colors.yellow, 0, 0, 0, 0),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, HowItWorks());
                        },
                        title: Text(
                          "How invites works",
                          style: textStyle(true, 18, textColor2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 100, left: 10),
                      child: addLine(4, bgColor, 0, 0, 0, 0),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, VerifiedInfluencers());
                        },
                        title: Text(
                          "Verified Influencers",
                          style: textStyle(true, 18, textColor2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: (100), left: 10),
                      child: addLine(4, green, 0, 0, 0, 0),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, NeedHelp());
                        },
                        title: Text(
                          "Need Help?",
                          style: textStyle(true, 18, textColor2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: ("About KlippIt".length * 12).roundToDouble(),
                          left: 10),
                      child: addLine(4, blue, 0, 0, 0, 0),
                    ),
                  ],
                ),
              ),
            ),
            addSpace(50),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                child: Column(
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, TermsAndConditions());
                        },
                        title: Text(
                          "Terms & Conditions",
                          style: textStyle(false, 14, bgColor),
                        ),
                      ),
                    ),
                    addLine(0.3, light_grey, 0, 0, 0, 0),
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          goToWidget(context, PrivacyPolicy());
                        },
                        title: Text(
                          "Privacy Policy",
                          style: textStyle(false, 14, bgColor),
                        ),
                      ),
                    ),
                    addLine(0.3, light_grey, 0, 0, 0, 0),
                    CupertinoButton(
                      onPressed: () {},
                      pressedOpacity: 0.5,
                      padding: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () {
                          showMessage(context, Icons.warning, Colors.red,
                              "Logout?", "Are you sure you want to logout?",
                              clickYesText: "Yes",
                              cancellable: true, onClicked: (_) async {
                            showProgress(true, context,
                                cancellable: true, msg: "Logging Out");
                            userListenerController?.cancel();
                            await FirebaseAuth.instance.signOut();
                            await BaseModule.resetCurrentUser();
                            clearScreenUntil(context, PreLaunch());
                          });
                        },
                        title: Text(
                          "Logout",
                          style: textStyle(false, 14, bgColor),
                        ),
                      ),
                    ),
                    addLine(0.3, light_grey, 0, 0, 0, 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  makeAdmin(String email, bool add) async {
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(EMAIL, isEqualTo: email)
        .limit(1)
        .getDocuments();
    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      model.put(IS_ADMIN, true);
      model.updateItems();
      toastInAndroid("Added");
    }
    showMessage(
        context,
        Icons.check,
        dark_green1,
        "Admin ${add ? "Added" : "Removed"}!?",
        "$email has been successfully added as an admin user!",
        clickYesText: "Ok",
        cancellable: true,
        delayInMilli: 900);
  }

  resetUsers() async {
    showProgress(true, context, msg: "Resetting Users...");
    QuerySnapshot shots =
        await Firestore.instance.collection(USER_BASE).getDocuments();
    for (DocumentSnapshot doc in shots.documents) {
      BaseModel model = BaseModel(doc: doc);
      bool isDummy = model.getBoolean(IS_DUMMY);
      if (isDummy) continue;
      var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: model.getEmail(), password: "%%*01234*%%");
      if (user != null) {
        await user.user.delete();
        model.deleteItem();
      }
    }
    showProgress(false, context);
    showMessage(context, Icons.check, dark_green1, "Reset Successful!",
        "Users has been successfully resetted and cleared!",
        clickYesText: "Ok", cancellable: true, delayInMilli: 900);
  }

  onError(e) {
    showMessage(context, Icons.warning, Colors.red, "Link Error!", e.message,
        cancellable: true, delayInMilli: 900, onClicked: (_) async {
      showProgress(false, context);
    });
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

export 'package:klippit/backbone/baseEngine.dart';
export 'package:klippit/assets.dart';
export 'package:klippit/photo_picker/photo.dart';
export 'package:klippit/notification/NotificationHandler.dart';
export 'package:klippit/notification/notificationService.dart';
export 'package:klippit/dialogs/baseDialogs.dart';
export 'package:klippit/builders/baseBuilders.dart';
export 'package:klippit/utils/baseUtils.dart';
export 'package:klippit/navigationUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/backbone/baseEngine.dart';

import 'dart:io';
BaseModel userModel = BaseModel();
BaseModel adminModel = BaseModel();
bool showProgressLayout = false;
bool showBroadcast = false;
StreamSubscription<DocumentSnapshot> userStream;
StreamSubscription<DocumentSnapshot> adminStream;

var hasInternet = ValueNotifier<bool>(false);
var isUploadingPost = ValueNotifier<bool>(false);
var userNotifier = ValueNotifier<bool>(false);
var broadcastNotifier = ValueNotifier<bool>(false);

class BaseModule {
  static BaseModule _instance;

  BaseModule._();

  factory BaseModule() {
    assert(
        _instance != null,
        'Please make sure to call BaseModule.init() '
        'at the top of your app or before using the other functions.');
    return _instance;
  }

  static void init({
    //@required DocumentSnapshot userSnapshot,
    @required Color appColor,
    @required String appName,
    @required String appIcon,
  }) {
//    assert(userSnapshot != null,
//        "Please BaseModel needs a user snapshot user to be passed");
    assert(_instance == null,
        'Are you trying to reset the previous keys by calling BaseModule.init() again?.');
    _instance = BaseModule._();
    //userModel = BaseModel(doc: userSnapshot);
    APP_COLOR = appColor;
    APP_NAME = appName;
    ic_launcher = appIcon;
  }

  static Future<FirebaseUser> initCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance
        .currentUser()
        .catchError((e) => print("User Error $e"));
    if (user != null) {
      var doc = await Firestore.instance
          .collection(USER_BASE)
          .document(user.uid)
          .get()
          .then((doc) {
        if (doc.exists) userModel = BaseModel(doc: doc);
      }).whenComplete(() {
        userStream = Firestore.instance
            .collection(USER_BASE)
            .document(user.uid)
            .snapshots()
            .listen((doc) {
          if (doc.exists) userModel = BaseModel(doc: doc);
        });
      }).catchError((e) => print("Fetch Error $e"));
    }
    return user;
  }

  static resetCurrentUser() async {
    await FirebaseAuth.instance.signOut();
    userModel = BaseModel();
    userNotifier.value = false;
    userStream?.cancel();
  }
}

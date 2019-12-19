import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/base_module.dart';

class BaseModel {
  Map<String, Object> items = new Map();
  Map<String, Object> itemUpdate = new Map();
  Map<String, Map> itemUpdateList = new Map();
  String rewardCode = "";
  
  BaseModel({Map items, DocumentSnapshot doc}) {
    if (items != null) {
      Map<String, Object> theItems = Map.from(items);
      this.items = theItems;
    }
    if (doc != null && doc.exists) {
      this.items = doc.data;
      this.items[DOCUMENT_ID] = doc.documentID;
    }
  }

  void put(String key, Object value) {
    items[key] = value;
    itemUpdate[key] = value;
  }

  void putInList(String key, Object value, bool add) {
    List itemsInList = items[key] == null ? List() : List.from(items[key]);
    if (add) {
      if (!itemsInList.contains(value)) itemsInList.add(value);
    } else {
      itemsInList.removeWhere((E) => E == value);
    }
    items[key] = itemsInList;

    Map update = Map();
    update[ADD] = add;
    update[VALUE] = value;

    itemUpdateList[key] = update;
  }

  void remove(String key) {
    items.remove(key);
    itemUpdate[key] = null;
  }

  String setRewardCode(String code){
    this.rewardCode = code;
  }

  String getDocId() {
    Object value = items[DOCUMENT_ID];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getUId() {
    Object value = items[USER_ID];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getRewardCode() {
    Object value = items[REWARD_CODE];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getOwnerId() {
    Object value = items[OWNER_ID];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getImage() {
    Object value = items[IMAGE];
    return value == null || !(value is String)
        /*? "https://i.stack.imgur.com/TMCfE.png"*/
        ? ""
        : value.toString();
  }

  String getFullName() {
    Object value = items[FULL_NAME];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getTitle() {
    Object value = items[TITLE];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getCity() {
    Object value = items[CITY];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getChurchName() {
    Object value = items[CHURCH_NAME];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getRelationshipStatus() {
    Object value = items[RELATIONSHIP_STATUS];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getChurchDenomination() {
    Object value = items[CHURCH_DENOMINATION];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getChurchAddress() {
    Object value = items[CHURCH_ADDRESS];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getBusinessAddress() {
    Object value = items[BUSINESS_ADDRESS];
    return value == null || !(value is String) || value.toString().isEmpty
        ? "NONE"
        : value.toString();
  }

  String getChurchWebsite() {
    Object value = items[CHURCH_WEBSITE];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getPushToken() {
    Object value = items[TOKEN_ID];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getToken() {
    Object value = items[PUSH_NOTIFICATION_TOKEN];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getAboutUser() {
    Object value = items[ABOUT_ME];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  int getIsOnline() {
    Object value = items[IS_ONLINE];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getTime() {
    Object value = items[TIME];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getType() {
    Object value = items[TYPE];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getStatus() {
    Object value = items[NOTIFICATION_STATUS];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getNotificationType() {
    Object value = items[NOTIFICATION_TYPE];
    return value == null || !(value is int) ? 0 : (value);
  }

  FieldValue getCreatedAt() {
    Object value = items[CREATED_AT];
    return value;
  }

  List getList(String key) {
    Object value = items[key];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getChatDetails() {
    Object value = items[CHAT_DETAILS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getChatData() {
    Object value = items[CHAT_DATA];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getConnections() {
    Object value = items[CONNECTIONS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getShares() {
    Object value = items[SHARES];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getAchievements() {
    Object value = items[ACHIEVEMENTS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getSentRequests() {
    Object value = items[SENT_REQUESTS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getReceivedRequests() {
    Object value = items[RECEIVED_REQUESTS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List<Object> addToList(String key, Object value, bool add) {
    List<Object> list = items[key];
    list = list == null ? new List<Object>() : list;
    if (add) {
      if (!list.contains(value)) list.add(value);
    } else {
      list.remove(value);
    }
    put(key, list);
    return list;
  }

  Map getMap(String key) {
    Object value = items[key];
    return value == null || !(value is Map)
        ? new Map<String, String>()
        : Map.from(value);
  }

  Map getOwner() {
    Object value = items[POST_OWNER];
    return value == null || !(value is Map)
        ? new Map<String, String>()
        : Map.from(value);
  }

  Map getChurchInfo() {
    Object value = items[CHURCH_INFO];
    return value == null || !(value is Map)
        ? new Map<String, String>()
        : Map.from(value);
  }

  Map getRequestError() {
    Object value = items[ERROR];
    return value == null || !(value is Map)
        ? new Map<String, String>()
        : Map.from(value);
  }

  Object get(String key) {
    return items[key];
  }

  String getAssetFile() {
    Object value = items[ASSET_FILE];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getThumbnailFile() {
    Object value = items[THUMBNAIL_PATH];
    return value == null || !(value is String) ? "NONE" : value.toString();
  }

  String getNotificationTitle() {
    Object value = items[NOTIFICATION_TITLE];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getNotificationSender() {
    Object value = items[NOTIFICATION_SENDER_NAME];
    return value == null || !(value is String) ? "" : value.toString();
  }

  int getInt(String key) {
    Object value = items[key];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getMessageType() {
    Object value = items[MESSAGE_TYPE];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getMessageStatus() {
    Object value = items[MESSAGE_STATUS];
    return value == null || !(value is int) ? 0 : (value);
  }

  int getAssetType() {
    Object value = items[ASSET_TYPE];
    return value == null || !(value is int) ? 0 : (value);
  }

  String getString(String key) {
    Object value = items[key];

    return value == null || !(value is String) ? "" : value.toString();
  }

  String getIsTyping() {
    Object value = items[IS_TYPING];

    return value == null || !(value is String) ? "" : value.toString();
  }

  String getGifUrl() {
    Object value = items[GIF_URL];

    return value == null || !(value is String) ? "" : value.toString();
  }

  double getDouble(String key) {
    Object value = items[key];
    return value == null || !(value is double) ? 0 : value;
  }

  bool getBoolean(String key) {
    Object value = items[key];
    return value == null || !(value is bool) ? false : value;
  }

  bool getRequestHasError() {
    return items.isNotEmpty;
  }

  bool getIsHidden() {
    Object value = items[IS_HIDDEN];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsPostReported() {
    return getReports().contains(userModel.getUId());
  }

  bool getIsPostBlocked() {
    return getBlocks().contains(userModel.getUId());
  }

  List getReports() {
    Object value = items[REPORTS];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  List getBlocks() {
    Object value = items[BLOCKED];
    return value == null || !(value is List) ? new List() : List.from(value);
  }

  bool getIsChurch() {
    Object value = items[IS_CHURCH];
    return value == null || !(value is bool) ? false : value;
  }

  bool getCanShowDate() {
    Object value = items[SHOW_DATE];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsUploadingData() {
    Object value = items[UPLOADING_DATA];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsChurchUpdated() {
    Object value = items[IS_CHURCH_UPDATED];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsPersonalUpdated() {
    Object value = items[IS_PERSONAL_UPDATED];
    return value == null || !(value is bool) ? false : value;
  }

  bool getUserBlocked() {
    Object value = items[IS_BLOCKED];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsVerified() {
    Object value = items[IS_VERIFIED];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsBlocked() {
    Object value = items[IS_CHURCH];
    return value == null || !(value is bool) ? false : value;
  }

  bool getIsNetwork() {
    Object value = items[IS_NETWORK_IMAGE];
    return value == null || !(value is bool) ? false : value;
  }

  String getEmail() {
    Object value = items[EMAIL];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getPassword() {
    Object value = items[PASSWORD];
    return value == null || !(value is String) ? "" : value.toString();
  }

  String getMessage() {
    Object value = items[MESSAGE];
    return value == null || !(value is String) ? "" : value.toString();
  }

  

  bool isMaugost() {
    return getEmail() == ("ammaugost@gmail.com") ||
        getEmail().contains("maugost");
  }

  bool isBrooks() {
    return getEmail() == ("agape@spiritoverflow.com");
  }

  void justUpdate({onComplete, bool updateTime = true}) {
    String dName = items[DATABASE_NAME];
    //if(dName==null ||dName.isEmpty())return;

    String id = items[DOCUMENT_ID];

    if (updateTime) {
      items[UPDATED_AT] = FieldValue.serverTimestamp();
      items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    Firestore db = Firestore.instance;
    db.collection(dName).document(id).setData(items).whenComplete(onComplete);
  }

  /*updateItems({bool updateTime = true}) async {
    Future.delayed(Duration(seconds: 1), () async {
      String dName = items[DATABASE_NAME];
      String id = items[DOCUMENT_ID];
      final DocumentReference updateRef =
          Firestore.instance.collection(dName).document(id);

      //try {
      await Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot updateShot = await tx.get(updateRef);
        if (updateShot.exists) {
          BaseModel model = BaseModel(doc: updateShot);
          for (String k in itemUpdate.keys) {
            model.put(k, itemUpdate[k]);
          }

          if (updateTime) {
            model.put(UPDATED_AT, FieldValue.serverTimestamp());
            model.put(TIME_UPDATED, DateTime.now().millisecondsSinceEpoch);
          }

          await tx.update(updateRef, model.items);
        }
      }).catchError((e) {
        print("Model Update Error $e");
      });
      //} on Exception catch (e) {}
    });
  }*/

  void updateItemsManually(onComplete(String error),
      {bool updateTime = true}) async {
    String dName = items[DATABASE_NAME];
    String id = items[DOCUMENT_ID];

    DocumentSnapshot doc = await Firestore.instance
        .collection(dName)
        .document(id)
        .get(source: Source.server)
        .catchError((error) {
      onComplete(error);
      return;
    });
    if (doc == null) return;
    if (!doc.exists) return;

    Map data = doc.data;
    for (String k in itemUpdate.keys) {
      data[k] = itemUpdate[k];
    }
    for (String k in itemUpdateList.keys) {
      Map update = itemUpdateList[k];
      bool add = update[ADD];
      var value = update[VALUE];

      List dataList = data[k] == null ? List() : List.from(data[k]);
      if (add) {
        if (!dataList.contains(value)) dataList.add(value);
      } else {
        dataList.removeWhere((E) => E == value);
      }
      data[k] = dataList;
    }

    if (updateTime) {
      data[UPDATED_AT] = FieldValue.serverTimestamp();
      data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    doc.reference.setData(data).whenComplete(() {
      onComplete(null);
    });
  }

  void runUpdateTrans({onError}) async {
    String dName = items[DATABASE_NAME];
    String id = items[DOCUMENT_ID];
    final DocumentReference docRef =
        Firestore.instance.collection(dName).document(id);
    Firestore.instance.runTransaction((handler) async {
      DocumentSnapshot doc = await handler.get(docRef);
      if (doc.exists) {
        await handler.update(docRef, itemUpdate).catchError((e) {
          print("Trans 1 $e");
        });
      }
    }).catchError((e) {
      print("Trans $e");
    });
  }

  void updateItems({bool updateTime = true, int delaySeconds = 0}) async {
    Future.delayed(Duration(seconds: delaySeconds), () async {
      bool connected = await isConnected();
      if (!connected) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        //print("not connected retrying in $delaySeconds seconds");
        updateItems(updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      }

      String dName = items[DATABASE_NAME];
      String id = items[DOCUMENT_ID];

      DocumentSnapshot doc = await Firestore.instance
          .collection(dName)
          .document(id)
          .get(/*source: Source.server*/)
          .catchError((error) {
        delaySeconds = delaySeconds + 10;
        delaySeconds = delaySeconds >= 60 ? 0 : delaySeconds;
        print("$error... retrying in $delaySeconds seconds");
        updateItems(updateTime: updateTime, delaySeconds: delaySeconds);
        return;
      });
      if (doc == null) return;
      if (!doc.exists) return;

      Map data = doc.data;
      for (String k in itemUpdate.keys) {
        data[k] = itemUpdate[k];
      }
      for (String k in itemUpdateList.keys) {
        Map update = itemUpdateList[k];
        bool add = update[ADD];
        var value = update[VALUE];

        List dataList = data[k] == null ? List() : List.from(data[k]);
        if (add) {
          if (value is Map) {
            int pos = dataList
                .indexWhere((m) => m[DOCUMENT_ID] == value[DOCUMENT_ID]);
            if (pos == -1) {
              dataList.add(value);
            }
          } else {
            if (!dataList.contains(value)) dataList.add(value);
          }
        } else {
          if (value is Map) {
            int pos = dataList
                .indexWhere((m) => m[DOCUMENT_ID] == value[DOCUMENT_ID]);
            if (pos != -1) {
              dataList.removeAt(pos);
            }
          } else {
            dataList.removeWhere((E) => E == value);
          }
        }
        data[k] = dataList;
      }

      if (updateTime) {
        data[UPDATED_AT] = FieldValue.serverTimestamp();
        data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
      }

      doc.reference.setData(data);
    });
  }

  void updateCountItem(String key, bool increase,
      {bool updateTime = true}) async {
    Future.delayed(Duration(seconds: 1), () async {
      String dName = items[DATABASE_NAME];
      String id = items[DOCUMENT_ID];

      DocumentSnapshot doc =
          await Firestore.instance.collection(dName).document(id).get();
      Map data = doc.data;
      var item = data[key] ?? 0;
      if (increase) {
        item = item + 1;
      } else {
        item = item - 1;
      }
      data[key] = item;

      if (updateTime) {
        data[UPDATED_AT] = FieldValue.serverTimestamp();
        data[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
      }

      doc.reference.setData(data);
    });
  }

  void deleteItem() {
    String dName = items[DATABASE_NAME];
    String id = items[DOCUMENT_ID];

    Firestore db = Firestore.instance;
    db.collection(dName).document(id).delete();
  }

  processSave(String name, bool addMyInfo) {
    items[DATABASE_NAME] = name;
    items[UPDATED_AT] = FieldValue.serverTimestamp();
    items[CREATED_AT] = FieldValue.serverTimestamp();
    items[TIME] = DateTime.now().millisecondsSinceEpoch;
    items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    if (name != (USER_BASE)) {
      if (addMyInfo) addMyDetails();
    }
  }

  void addMyDetails() {
    /*items[USER_ID] = userModel.getUserId();
    items[USER_IMAGE] = userModel.getString(USER_IMAGE);
    items[USERNAME] = userModel.getUserName();*/
    items[OWNER_ID] = userModel.getUId();
    items[USER_ID] = userModel.getUId();
    items[POST_OWNER] = userModel.items;
  }

  void saveItem(String name, bool addMyInfo, {document, onComplete, onError}) {
    processSave(name, addMyInfo);
    if (document == null) {
      Firestore.instance.collection(name).add(items).then((doc) {
        items[DOCUMENT_ID] = doc.documentID;
        updateItems(updateTime: true);
      }).whenComplete(onComplete);
    } else {
      items[DOCUMENT_ID] = document;
      Firestore.instance
          .collection(name)
          .document(document)
          .setData(items)
          //.catchError(onError)
          .whenComplete(onComplete);
    }
  }

  void saveItemManually(String name, String document, bool addMyInfo,
      onComplete, bool isUpdating) {
    if (!isUpdating) {
      processSave(name, addMyInfo);
    } else {
      items[UPDATED_AT] = FieldValue.serverTimestamp();
      items[TIME_UPDATED] = DateTime.now().millisecondsSinceEpoch;
    }

    bool hasError = false;

    Firestore.instance
        .collection(name)
        .document(document)
        .setData(items)
        .timeout(Duration(seconds: 15), onTimeout: () {
      onComplete(null, "Error, Timeout");
      hasError = true;
    }).then((void _) {
      if (!hasError) onComplete(_, null);
    }, onError: (error) {
      onComplete(null, error);
    });
  }

  bool myItem() {
    return items[USER_ID] == userModel.getUId();
  }
}

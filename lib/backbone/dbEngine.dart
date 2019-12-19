import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../assets.dart';
//Handle firebase CRUD
// C -- CREATE
// R -- READ
// U -- UPDATE
// D -- DELETE

DB userBase = new DB(collectionPath: USER_BASE);
DB postBase = new DB(collectionPath: POST_BASE);
DB commentsBase = new DB(collectionPath: COMMENTS_BASE);
DB repliesBase = new DB(collectionPath: REPLIES_BASE);
DB reportBase = new DB(collectionPath: REPORT_BASE);
//DB likesBase = new DB(collectionPath: LIKES_BASE);
//DB sharesBase = new DB(collectionPath: SHARES_BASE);
DB connectionBase = new DB(collectionPath: CONNECTION_BASE);
DB eventsBase = new DB(collectionPath: EVENT_BASE);
DB chatBase = new DB(collectionPath: CHAT_BASE);
DB groupBase = new DB(collectionPath: GROUP_BASE);
DB chatHistoryBase = new DB(collectionPath: CHAT_HISTORY_BASE);
DB paymentBase = new DB(collectionPath: PAYMENT_BASE);
DB notificationBase = new DB(collectionPath: NOTIFICATION_BASE);

enum CreateType { documentId, noDocumentId }

class DB {
  final db = Firestore.instance;
  String collectionPath;
  String documentPath;

  DB({
    @required String collectionPath,
    /*String documentPath*/
  }) {
    this.collectionPath = collectionPath;
    /*this.documentPath = documentPath;*/
  }

  Stream<QuerySnapshot> init({Query query}) {
    if (query == null) {
      return db
          .collection(collectionPath)
          .orderBy("createdAt", descending: true)
          .snapshots();
    }
    return query.snapshots();
  }

  Stream<DocumentSnapshot> initDocumentStream({String docID}) {
    return db.collection(collectionPath).document(docID).snapshots();
  }

  Future<Map<String, dynamic>> createCollection({@required var data}) async {
    DocumentReference ref = await db.collection(collectionPath).add(data);
    ref.updateData({"docId": ref.documentID});
    DocumentSnapshot snapshot = await ref.get();
    return snapshot.data;
  }

  Future<QuerySnapshot> readCollection() async {
    return await db.collection(collectionPath).getDocuments();
  }

  Stream<DocumentSnapshot> readCollectionAt({@required String documentPath}) {
    return db.collection(collectionPath).document(documentPath).snapshots();
  }

  Future<void> createDocument(
      {@required String documentPath,
      @required Map<String, dynamic> data}) async {
    await db.collection(collectionPath).document(documentPath).setData(data);
  }

  Future<DocumentSnapshot> readDocument({@required String documentPath}) async {
    return await db.collection(collectionPath).document(documentPath).get();
    ;
  }

  void deleteDocument({@required String documentPath}) async {
    await db.collection(collectionPath).document(documentPath).delete();
  }

  void updateData({@required String docId, @required var data}) async {
    return await db.collection(collectionPath).document(docId).updateData(data);
  }
}

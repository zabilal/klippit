import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/base_module.dart';

import 'baseEngine.dart';

class UploadEngine {
  String uploadPath;
  File fileToSave;

  UploadEngine({@required this.uploadPath, @required this.fileToSave});

  Future<String> uploadPhoto({@required String uid}) async {
    String response;

    try {
      final StorageReference ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child(uid)
          .child('${new DateTime.now().millisecondsSinceEpoch}.jpg');
      final StorageUploadTask task = ref.putFile(fileToSave);
      StorageTaskSnapshot downloadRef = await task.onComplete;
      response = await downloadRef.ref.getDownloadURL();
    } on PlatformException catch (e) {
      response = e.message;
    }

    return response;
  }

  Future<String> uploadVideo({@required String uid}) async {
    String response;
    try {
      final StorageReference ref = FirebaseStorage.instance
          .ref()
          .child(uploadPath)
          .child(uid)
          .child('${new DateTime.now().millisecondsSinceEpoch}');
      final StorageUploadTask task =
          ref.putFile(fileToSave, StorageMetadata(contentType: 'video/mp4'));
      StorageTaskSnapshot downloadRef = await task.onComplete;
      downloadRef.bytesTransferred;
      response = await downloadRef.ref.getDownloadURL();
    } on PlatformException catch (e) {
      response = e.message;
    }

    return response;
  }

  static Future<List<Map>> uploadFile(
      {List<BaseModel> wrapperFiles,
      String uploadPath,
      BaseModel currentUser}) async {
    List<Map> responseData = [];
    for (int i = 0; i < wrapperFiles.length; i++) {
      bool useNetwork = wrapperFiles[i].getIsNetwork();

      if (useNetwork) {
        BaseModel model = BaseModel();
        model.put(ASSET_TYPE, wrapperFiles[i].getInt(ASSET_TYPE));
        model.put(UPLOAD_URL, wrapperFiles[i].getString(THUMBNAIL_URL));
        model.put(THUMBNAIL_URL, wrapperFiles[i].getString(THUMBNAIL_URL));
        model.put(IMG_WIDTH, wrapperFiles[i].getInt(IMG_WIDTH));
        model.put(IMG_HEIGHT, wrapperFiles[i].getInt(IMG_HEIGHT));
        responseData.add(model.items);
        continue;
      }

      if (wrapperFiles[i].getInt(ASSET_TYPE) == ASSET_TYPE_VIDEO) {
        File thumbnail = File(wrapperFiles[i].getThumbnailFile());
        var saveThumbnail =
            UploadEngine(uploadPath: uploadPath, fileToSave: thumbnail);
        String thumbnailResponse =
            await saveThumbnail.uploadPhoto(uid: uploadID);

        File video = File(wrapperFiles[i].getAssetFile());
        var saveVideo = UploadEngine(uploadPath: uploadPath, fileToSave: video);
        String videoResponse = await saveVideo.uploadVideo(uid: uploadID);

        BaseModel model = BaseModel();
        model.put(ASSET_TYPE, ASSET_TYPE_VIDEO);
        model.put(UPLOAD_URL, videoResponse);
        model.put(THUMBNAIL_URL, thumbnailResponse);
        model.put(VIDEO_DURATION, wrapperFiles[i].getString(VIDEO_DURATION));
        responseData.add(model.items);

        print("uploading video");
      } else {
        File fileToSave = File(wrapperFiles[i].getAssetFile());
        var saveImage =
            UploadEngine(uploadPath: uploadPath, fileToSave: fileToSave);
        String imageResponse = await saveImage.uploadPhoto(uid: uploadID);

        BaseModel model = BaseModel();
        model.put(ASSET_TYPE, ASSET_TYPE_IMAGE);
        model.put(UPLOAD_URL, imageResponse);
        model.put(IMG_WIDTH, wrapperFiles[i].getInt(IMG_WIDTH));
        model.put(IMG_HEIGHT, wrapperFiles[i].getInt(IMG_HEIGHT));
        responseData.add(model.items);

        print("uploading image");
      }
    }
    print("finished uploading");
    return responseData;
  }

  static get uploadID =>
      "${userModel.getUId()}/${DateTime.now().millisecondsSinceEpoch}";
}

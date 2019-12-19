import 'dart:async';
import 'dart:io';

import 'package:klippit/base_module.dart';
import 'package:klippit/dialogs/listDialog.dart';
import 'package:klippit/dialogs/messageDialog.dart';
import 'package:klippit/dialogs/progressDialog.dart';
import 'package:klippit/photo_picker/photo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:klippit/assets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:smart_text_view/smart_text_view.dart';
import 'package:thumbnails/thumbnails.dart';
import 'package:timeago/timeago.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'basemodel.dart';

const MaterialColor appGreen = MaterialColor(
  0xFF6CA748,
  <int, Color>{
    50: Color(0xFFE8F5E9),
    100: Color(0xFFC8E6C9),
    200: Color(0xFFA5D6A7),
    300: Color(0xFF81C784),
    400: Color(0xFF66BB6A),
    500: Color(0xFF6CA748),
    600: Color(0xFF43A047),
    700: Color(0xFF388E3C),
    800: Color(0xFF2E7D32),
    900: Color(0xFF1B5E20),
  },
);

toast(scaffoldKey, text) {
  return scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: Padding(
      padding: const EdgeInsets.all(0.0),
      child: Text(
        text,
        style: textStyle(false, 15, white),
      ),
    ),
    duration: Duration(seconds: 2),
  ));
}

SizedBox addSpace(double size) {
  return SizedBox(
    height: size,
  );
}

addSpaceWidth(double size) {
  return SizedBox(
    width: size,
  );
}

Container addLine(
    double size, color, double left, double top, double right, double bottom) {
  return Container(
    height: size,
    width: double.infinity,
    color: color,
    margin: EdgeInsets.fromLTRB(left, top, right, bottom),
  );
}

Container bigButton(double height, double width, String text, textColor,
    buttonColor, onPressed) {
  return Container(
    height: height,
    width: width,
    child: RaisedButton(
      onPressed: onPressed,
      color: buttonColor,
      textColor: white,
      child: Text(
        text,
        style: TextStyle(
            fontSize: 20,
            fontFamily: "NirmalaB",
            fontWeight: FontWeight.normal,
            color: textColor),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
    ),
  );
}

textStyle(bool bold, double size, color, {underlined = false}) {
  return TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontFamily: bold ? poppinBold : poppinNormal,
      fontSize: size,
      decoration: underlined ? TextDecoration.underline : TextDecoration.none);
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> getLocalFile(String name) async {
  final path = await _localPath;
  return File('$path/$name');
}

Future<File> getDirFile(String name) async {
  final dir = await getExternalStorageDirectory();
  var testDir = await Directory("${dir.path}/Plinkd").create(recursive: true);
  return File("${testDir.path}/$name");
}

Future<void> toastInAndroid(String text) async {
  const platform = const MethodChannel("channel.john");
  try {
    await platform.invokeMethod('toast', <String, String>{'message': text});
  } on PlatformException catch (e) {
    //batteryLevel = "Failed to get what he said: '${e.message}'.";
  }
}

tabIndicator(int tabCount, int currentPosition, {double alpha = 1}) {
  return Container(
    padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
    //margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
    decoration: BoxDecoration(
        color: black.withOpacity(alpha),
        borderRadius: BorderRadius.circular(25)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: getTabs(tabCount, currentPosition),
    ),
  );
}

getTabs(int count, int cp) {
  List<Widget> items = List();
  for (int i = 0; i < count; i++) {
    bool selected = i == cp;
    items.add(Container(
      width: selected ? 10 : 8,
      height: selected ? 10 : 8,
      //margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: white.withOpacity(selected ? 1 : (.5)),
          shape: BoxShape.circle),
    ));
    if (i != count - 1) items.add(addSpaceWidth(5));
  }

  return items;
}

uploadFile(File file, onComplete) {
  final String ref = getRandomId();
  StorageReference storageReference = FirebaseStorage.instance.ref().child(ref);
  StorageUploadTask uploadTask = storageReference.putFile(file);
  uploadTask.onComplete
      /*.timeout(Duration(seconds: 600), onTimeout: () {
    onComplete(null, "Error, Timeout");
  })*/
      .then((task) {
    if (task != null) {
      task.ref.getDownloadURL().then((_) {
        BaseModel model = new BaseModel();
        model.put(IMAGE, _.toString());
        model.put(REFERENCE, ref);
        model.saveItem(REFERENCE_BASE, false);

        onComplete(_.toString(), null);
      }, onError: (error) {
        onComplete(null, error);
      });
    }
  }, onError: (error) {
    onComplete(null, error);
  });
}

///************ FOR TIME *************/

void showProgress(bool show, BuildContext context,
    {String msg, bool cancellable = false}) {
  if (!show) {
    showProgressLayout = false;
    return;
  }

  showProgressLayout = true;

  pushAndResult(
      context,
      progressDialog(
        message: msg,
        cancelable: cancellable,
      ));
}

addUpdatePicture(BuildContext context, BaseModel profileInfo,
    {bool isGroup = false, onComplete}) {
  showListDialog(
    context,
    [
      "Take a  Picture",
      "Select a Picture",
    ],
    onClicked: (position) async {
      if (position == 0) {
        File file = await getImagePicker(ImageSource.camera);
        if (file == null) return;
        File cropped = await cropImage(file);
        UploadEngine uploadEngine =
            UploadEngine(uploadPath: profileInfo.getUId(), fileToSave: cropped);
        String imageURL =
            await uploadEngine.uploadPhoto(uid: profileInfo.getUId());
        profileInfo.put(IMAGE, imageURL);
        profileInfo.updateItems();
        await updatePostRecords(isGroup: isGroup);
        onComplete();
      }
      if (position == 1) {
        File file = await getImagePicker(ImageSource.gallery);
        if (file == null) return;
        File cropped = await cropImage(file);
        UploadEngine uploadEngine =
            UploadEngine(uploadPath: profileInfo.getUId(), fileToSave: cropped);
        String imageURL =
            await uploadEngine.uploadPhoto(uid: profileInfo.getUId());
        profileInfo.put(IMAGE, imageURL);
        profileInfo.updateItems();
        await updatePostRecords(isGroup: isGroup);
        onComplete();
      }
    },
    useTint: false,
    delayInMilli: 10,
  );
}

void showMessage(
  context,
  icon,
  iconColor,
  title,
  message, {
  int delayInMilli = 0,
  clickYesText = "OK",
  onClicked,
  clickNoText,
  bool cancellable = false,
  bool isIcon = true,
  double iconPadding = 12.0,
}) {
  Future.delayed(Duration(milliseconds: delayInMilli), () {
    pushAndResult(
        context,
        messageDialog(
          icon,
          iconColor,
          title,
          message,
          clickYesText,
          noText: clickNoText,
          cancellable: cancellable,
          isIcon: isIcon,
          iconPadding: iconPadding,
        ),
        result: onClicked);
  });
}

void showListDialog(
  context,
  items, {
  images,
  title,
  onClicked,
  useIcon = true,
  usePosition = true,
  useTint = false,
  int delayInMilli = 0,
}) {
  Future.delayed(Duration(milliseconds: delayInMilli), () {
    pushAndResult(
        context,
        ListDialog(
          items,
          title: title,
          images: images,
          isIcon: useIcon,
          usePosition: usePosition,
          useTint: useTint,
        ),
        result: onClicked);
  });
}

bool isEmailValid(String email) {
  if (!email.contains("@") || !email.contains(".")) return false;
  return true;
}

Future<File> cropImage(File imageFile,
    {bool useCircle = false, String title = "Crop Photo"}) async {
  ImageInfo imgInfo = await getImageInfo(imageFile);
  double imgWidth = imgInfo.image.height.roundToDouble();
  double imgHeight = imgInfo.image.width.roundToDouble();
  print('Info ${imgInfo.image..height}');

  File croppedFile = await ImageCropper.cropImage(
    sourcePath: imageFile.path,
    //ratioX: imgWidth / imgHeight,
    maxWidth: imgWidth.round(),
    maxHeight: imgHeight.round(),
    cropStyle: useCircle ? CropStyle.circle : CropStyle.rectangle,
  );
  return croppedFile;
}

Future<ImageInfo> getImageInfo(File imageFile) async {
  final Completer completer = Completer<ImageInfo>();
  final ImageStream stream =
      FileImage(imageFile).resolve(const ImageConfiguration());
  final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
    if (!completer.isCompleted) {
      completer.complete(info);
    }

    print("W ${info.image.width} H ${info.image.height}");
  });
  stream.addListener(listener);

  completer.future.then((_) {
    stream.removeListener(listener);
  });
  return await completer.future;
}

Future getImagePicker(ImageSource imageSource) async {
  var image = await ImagePicker.pickImage(source: imageSource);

  return image;
}

Future getVideoPicker(ImageSource imageSource) async {
  var image = await ImagePicker.pickVideo(source: imageSource);
  return image;
}

Future pickImageAndCrop(
  ImageSource imageSource, {
  bool canCrop = true,
  bool useCircle = false,
}) async {
  var image = await ImagePicker.pickImage(source: imageSource);
  //var cropped = await cropImage(image);
  return canCrop ? await cropImage(image, useCircle: useCircle) : image;
}

Future<List> pickMultiImage(BuildContext context, PickType type,
    {int max = 8}) async {
  List<AssetPathEntity> list = await PhotoManager.getImageAsset();
  List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      context: context,
      themeColor: APP_COLOR,
      padding: 3.0,
      dividerColor: Colors.grey,
      disableColor: Colors.grey.shade300,
      itemRadio: 0.9,
      maxSelected: max,
      provider: I18nProvider.english,
      rowCount: 3,
      textColor: Colors.white,
      thumbSize: 150,
      sortDelegate: SortDelegate.common,
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
      ),
      badgeDelegate: const DurationBadgeDelegate(),
      pickType: type);
  return imgList;
}

bool isDomainEmailValid(String email) {
  if (email.contains("aol") ||
      email.contains("gmail") ||
      email.contains("yahoo") ||
      email.contains("hotmail")) return false;
  return true;
}

gradientLine({double height = 4, bool reverse = false, alpha = .3}) {
  return Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
            colors: reverse
                ? [
                    black.withOpacity(alpha),
                    transparent,
                  ]
                : [transparent, black.withOpacity(alpha)])),
  );
}

openLink(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  }
}

void yesNoDialog(context, title, message, clickedYes,
    {bool cancellable = true}) {
  Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: transition,
          opaque: false,
          pageBuilder: (context, _, __) {
            return messageDialog(
              Icons.warning,
              red0,
              title,
              message,
              "Yes",
              noText: "No, Cancel",
              cancellable: cancellable,
              isIcon: true,
            );
          })).then((_) {
    if (_ != null) {
      if (_ == true) {
        clickedYes();
      }
    }
  });
}

pushAndResult(context, item, {result}) {
  Navigator.push(
      context,
      PageRouteBuilder(
          transitionsBuilder: transition,
          opaque: false,
          pageBuilder: (context, _, __) {
            return item;
          })).then((_) {
    if (_ != null) {
      if (result != null) result(_);
    }
  });
}

Widget transition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

String getRandomId() {
  var uuid = new Uuid();
  return uuid.v1();
}

imageHolder(
  double size,
  imageUrl, {
  double stroke = 0,
  strokeColor = orang1,
  localColor = white,
  margin,
  bool local = false,
  iconHolder = Icons.person,
  double iconHolderSize = 14,
  double localPadding = 0,
  bool round = true,
  bool borderCurve = false,
  onImageTap,
}) {
  return GestureDetector(
    onTap: onImageTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderCurve ? 20 : 0),
      child: AnimatedContainer(
        curve: Curves.ease,
        margin: margin,
        alignment: Alignment.center,
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.all(stroke),
        decoration: BoxDecoration(
          color: strokeColor,
          //borderRadius: BorderRadius.circular(borderCurve ? 15 : 0),
          //border: Border.all(width: 2, color: white),
          shape: round ? BoxShape.circle : BoxShape.rectangle,
        ),
        width: size,
        height: size,
        child: Stack(
          children: <Widget>[
            new Card(
              margin: EdgeInsets.all(0),
              shape: round
                  ? CircleBorder()
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
              clipBehavior: Clip.antiAlias,
              color: transparent,
              elevation: .5,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: size,
                    height: size,
                    child: Center(
                        child: Icon(
                      iconHolder,
                      color: white,
                      size: iconHolderSize,
                    )),
                  ),
                  imageUrl is File
                      ? (Image.file(imageUrl))
                      : local
                          ? Padding(
                              padding: EdgeInsets.all(localPadding),
                              child: Image.asset(
                                imageUrl,
                                width: size,
                                height: size,
                                //color: localColor,
                                fit: BoxFit.cover,
                              ),
                            )
                          : CachedNetworkImage(
                              width: size,
                              height: size,
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                ],
              ),
            ),
            /*!isOnline
                              ? Container()
                              : Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: white, width: 2),
                                    color: red0,
                                  ),
                                ),*/
          ],
        ),
      ),
    ),
  );
}

loadingLayout(
    {Color color = white,
    Color loadColor = white,
    bool useColor = true,
    String icon}) {
  return new Container(
    color: color,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: Opacity(
            opacity: .3,
            child: Image.asset(
              icon ?? ic_launcher,
              width: 20,
              height: 20,
            ),
          ),
        ),
        Center(
          child: CircularProgressIndicator(
            //value: 20,
            valueColor:
                AlwaysStoppedAnimation<Color>(useColor ? APP_COLOR : loadColor),
            strokeWidth: 2,
          ),
        ),
      ],
    ),
  );
}

placeHolder(double height, {double width = 200}) {
  return new Container(
    height: height,
    width: width,
    color: APP_COLOR.withOpacity(.1),
    child: Center(
        child: Opacity(
            opacity: .3,
            child: Image.asset(
              ic_launcher,
              width: 20,
              height: 20,
            ))),
  );
}

loadingLayoutDec({bool useDeco = false, Decoration decoration, Widget bottom}) {
  if (useDeco) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(picnic), fit: BoxFit.cover)),
        ),
        new Container(
          //color: white,
          decoration: decoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      height: 42,
                      width: 42,
                      decoration:
                          BoxDecoration(color: black, shape: BoxShape.circle),
                    ),
                  ),
                  Center(
                    child: Opacity(
                      opacity: 1,
                      child: Image.asset(whiteAppIcon,
                          width: 40, height: 40, color: white.withOpacity(.5)),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        //value: 20,
                        valueColor: AlwaysStoppedAnimation<Color>(white),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              ),
              addSpace(10),
              Material(
                color: transparent,
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: "Connect",
                      style: TextStyle(
                          fontSize: 20,
                          color: white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: black, blurRadius: 8)])),
                  TextSpan(
                      text: "-",
                      style: textStyle(true, 18, white.withOpacity(.5))),
                  TextSpan(
                      text: "Engage",
                      style: TextStyle(
                          fontSize: 20,
                          color: white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: black, blurRadius: 8)])),
                  TextSpan(
                      text: "-",
                      style: textStyle(true, 18, white.withOpacity(.5))),
                  TextSpan(
                      text: "Grow",
                      style: TextStyle(
                          fontSize: 20,
                          color: white,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: black, blurRadius: 8)])),
                ])),
              )
            ],
          ),
        )
      ],
    );
  }
  return new Container(
    color: white,
    child: Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Center(
          child: Opacity(
            opacity: 1,
            child:
                Image.asset(whiteAppIcon, width: 30, height: 30, color: orang1),
          ),
        ),
        Center(
          child: CircularProgressIndicator(
            //value: 20,
            valueColor: AlwaysStoppedAnimation<Color>(orang1),
            strokeWidth: 2,
          ),
        ),
      ],
    ),
  );
}

emptyLayout(icon, String title, String text,
    {click,
    clickText,
    bool isIcon = false,
    bool isCurved = false,
    Color color = blue0}) {
  return Container(
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isCurved ? 30 : 0),
          topRight: Radius.circular(isCurved ? 30 : 0)),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Container(
              width: 50,
              height: 50,
              child: Stack(
                children: <Widget>[
                  new Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        //color: red0,
                        shape: BoxShape.circle),
                  ),
                  new Center(
                      child: isIcon
                          ? Icon(
                              icon,
                              size: 30,
                              color: white,
                            )
                          : Image.asset(
                              icon,
                              height: 30,
                              width: 30,
                              color: white,
                            )),
                  new Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        addExpanded(),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                              color: red3,
                              shape: BoxShape.circle,
                              border: Border.all(color: white, width: 1)),
                          child: Center(
                            child: Text(
                              "!",
                              style: textStyle(true, 14, white),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            addSpace(10),
            Text(
              title,
              style: textStyle(true, 16, black),
              textAlign: TextAlign.center,
            ),
            addSpace(5),
            Text(
              text,
              style: textStyle(false, 14, black.withOpacity(.5)),
              textAlign: TextAlign.center,
            ),
            addSpace(10),
            click == null
                ? new Container()
                : FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: light_green4,
                    onPressed: click,
                    child: Text(
                      clickText,
                      style: textStyle(true, 14, white),
                    ))
          ],
        ),
      ),
    ),
  );
}

addExpanded() {
  return Expanded(
    child: new Container(),
    flex: 1,
  );
}

addFlexible() {
  return Flexible(
    child: new Container(),
    flex: 1,
  );
}

errorDialog(retry, cancel, {String text}) {
  return Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Container(
        color: black.withOpacity(.8),
      ),
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: red0,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text(
                        "!",
                        style: textStyle(true, 30, white),
                      ))),
                  addSpace(10),
                  Text(
                    "Error",
                    style: textStyle(false, 14, red0),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              text == null ? "An unexpected error occurred, try again" : text,
              style: textStyle(false, 14, white.withOpacity(.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )),
      Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: new Container(),
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: FlatButton(
                      onPressed: retry,
                      child: Text(
                        "RETRY",
                        style: textStyle(true, 15, white),
                      )),
                ),
                addSpace(15),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: FlatButton(
                      onPressed: cancel,
                      child: Text(
                        "CANCEL",
                        style: textStyle(true, 15, white),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    ],
  );
}

avatarItem(String title, String image, onChanged) {
  return Column(
    children: <Widget>[
      GestureDetector(
        onTap: onChanged,
        child: image.isEmpty
            ? Container(
                height: 90,
                width: 90,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.withOpacity(.4)),
                    shape: BoxShape.circle),
              )
            : Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    image: DecorationImage(image: FileImage(File(image))),
                    border: Border.all(color: Colors.grey.withOpacity(.4)),
                    shape: BoxShape.circle),
              ),
      ),
      addSpace(10),
      Text(
        title,
        style: textStyle(true, 12, black.withOpacity(.4)),
      ),
    ],
  );
}

inputItem(
  String title,
  //String text,
  TextEditingController controller,
  icon,
  onChanged, {
  inputType = TextInputType.text,
  bool isPass = false,
  bool isAsset = false,
  bool autofocus = false,
  String hint = "",
  int maxLines = 1,
}) {
  //TextEditingController controller = TextEditingController(text: text);
  return new Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: textStyle(true, 12, black.withOpacity(.4)),
      ),
      //addSpace(10),
      Row(
        crossAxisAlignment: maxLines != 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(0, maxLines == 1 ? 0 : 15, 0, 0),
            child: isAsset
                ? Image.asset(
                    icon,
                    height: 18,
                    width: 18,
                    color: black.withOpacity(.4),
                  )
                : Icon(
                    icon,
                    size: 23,
                    color: black.withOpacity(.4),
                  ),
          ),
          addSpaceWidth(10),
          Flexible(
            child: new TextField(
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.none,
              autofocus: autofocus,
              //maxLength: 20,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: textStyle(false, 17, black.withOpacity(.2))),
              style: textStyle(false, 20, black),
              cursorColor: black,
              cursorWidth: 1,
              maxLines: maxLines,
              keyboardType: inputType,
              //onChanged: onChanged,
              obscureText: isPass, controller: controller,
            ),
          ),
        ],
      ),
      //addSpace(10),
      addLine(1, black.withOpacity(.1), 0, 0, 0, 20)
    ],
  );
}

dropDownV(hint, value, items, onChanged, icon, {bool isAsset = false}) {
  return Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            addSpaceWidth(5),
            if (isAsset)
              Image.asset(
                icon,
                height: 20,
                width: 20,
                color: Colors.black.withOpacity(.4),
              )
            else
              Icon(
                icon,
                size: 20,
                color: Colors.black.withOpacity(.4),
              ),
            addSpaceWidth(10),
            Flexible(
              child: DropdownButton(
                value: value,
                isExpanded: true,
                style: textStyle(false, 20, black),
                items: items,
                onChanged: onChanged,
                hint: Text(
                  hint,
                  style: textStyle(false, 17, black.withOpacity(.2)),
                ),
                underline: Container(),
              ),
            ),
          ],
        ),
        addLine(.5, black.withOpacity(.1), 0, 0, 0, 20)
      ],
    ),
  );
}

buttonItem(text, onPressed, {color = green_dark}) {
  return Container(
    height: 50,
    width: double.infinity,
    child: RaisedButton(
      onPressed: onPressed,
      color: color ?? APP_COLOR,
      textColor: white,
      child: Text(
        text,
        style: textStyle(true, 22, white),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    ),
  );
}

inputItemTv(String title, String text, icon, onTap, String hint,
    {isAsset = false, showSearch = false}) {
  return new Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        title,
        style: textStyle(false, 12, black.withOpacity(.4)),
      ),
      //addSpace(10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (isAsset)
            Image.asset(
              icon,
              height: 20,
              width: 20,
              color: Colors.black.withOpacity(.4),
            ),
          if (!isAsset)
            Icon(
              icon,
              size: 25,
              color: black.withOpacity(.4),
            ),
          addSpaceWidth(10),
          Flexible(
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        text.isEmpty ? hint : text,
                        style: textStyle(false, 17,
                            black.withOpacity(text.isEmpty ? (.2) : 1)),
                      ),
                    ),
                    addSpaceWidth(10),
                  ],
                ),
              ),
            ),
          ),
          addSpaceWidth(10),
          if (showSearch)
            Icon(
              Icons.search,
              size: 25,
              color: black.withOpacity(.4),
            ),
        ],
      ),
      //addSpace(10),
      addLine(1, black.withOpacity(.1), 0, 0, 0, 20)
    ],
  );
}

checkBoxItemTv(bool active, onTap, String hint,
    {bool showLine = false, bool circle = true}) {
  return new Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 25,
            width: 25,
            padding: EdgeInsets.all(5),
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? APP_COLOR : Colors.transparent,
                  border: Border.all(
                      color: active ? APP_COLOR : Colors.transparent)),
            ),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                    width: 2, color: active ? APP_COLOR : Colors.grey)),
          ),
          addSpaceWidth(10),
          Flexible(
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 50,
                width: double.infinity,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        hint,
                        style: TextStyle(
                            fontSize: 17,
                            color: black.withOpacity(active ? 1 : .2)),
                      ),
                    ),
                    addSpaceWidth(10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      //addSpace(10),
      if (showLine)
        addLine(1, black.withOpacity(.1), 0, 0, 0, 20)
    ],
  );
}

expandedContainer(child, {show = false}) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 5),
    child: show ? child : null,
    curve: Curves.easeOut,
    //padding: EdgeInsets.all(show ? 5 : 0),
//      decoration: BoxDecoration(
//          border: Border.all(width: 0.5, color: Colors.black.withOpacity(.1)),
//          color: Colors.grey.withOpacity(.05)
//      ),
  );
}

dropDownItem(String text) {
  return DropdownMenuItem(
    child: Text(
      text,
      style: textStyle(false, 18, black),
    ),
    value: text,
  );
}

pinnedMessageBox({
  String title,
  int time,
  String message,
  String btnTitle,
  Function onClicked,
  Function onClose,
  bool showUpdate = false,
  bool isProfile = false,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      margin: EdgeInsets.all(isProfile ? 0 : 10),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.blue, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          addSpace(10),
          Row(
            children: <Widget>[
              Icon(
                Icons.info,
                color: Colors.white,
              ),
              addSpaceWidth(10),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(.7)),
              ),
//              addSpaceWidth(10),
////              if (!isProfile)
//                Text(
//                  retrieveTimeFromData(time),
//                  style: TextStyle(color: Colors.white.withOpacity(.7)),
//                ),
              addExpanded(),
              InkWell(
                onTap: onClose,
                child: Icon(
                  Icons.clear,
                  //size: 18,
                  color: Colors.white.withOpacity(0.7),
                ),
              )
            ],
          ),
          addSpace(10),
          Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          addSpace(10),
          if (showUpdate)
            RaisedButton(
              onPressed: onClicked,
              color: Colors.white,
              padding: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                child: Text(
                  btnTitle,
                  style:
                      TextStyle(color: APP_COLOR, fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
    ),
  );
}

updatePostRecords({bool isGroup = false, BaseModel groupInfo}) async {
  if (isGroup) {
    await Firestore.instance
        .collection(POST_BASE)
        .where(POST_ID, isEqualTo: groupInfo.getDocId())
        .getDocuments()
        .then((query) {
      for (var doc in query.documents) {
        BaseModel model = BaseModel(doc: doc);
        model.put(POST_OWNER, groupInfo.items);
        model.updateItems();
      }
    });

    await Firestore.instance
        .collection(COMMENTS_BASE)
        .where(POST_ID, isEqualTo: groupInfo.getDocId())
        .getDocuments()
        .then((query) {
      for (var doc in query.documents) {
        BaseModel model = BaseModel(doc: doc);
        model.put(POST_OWNER, groupInfo.items);
        model.updateItems();
      }
    });

    await Firestore.instance
        .collection(REPLIES_BASE)
        .where(POST_ID, isEqualTo: groupInfo.getDocId())
        .getDocuments()
        .then((query) {
      for (var doc in query.documents) {
        BaseModel model = BaseModel(doc: doc);
        model.put(POST_OWNER, groupInfo.items);
        model.updateItems();
      }
    });

    return;
  }

  await Firestore.instance
      .collection(POST_BASE)
      .where(OWNER_ID, isEqualTo: userModel.getUId())
      .getDocuments()
      .then((query) {
    for (var doc in query.documents) {
      BaseModel model = BaseModel(doc: doc);
      model.put(POST_OWNER, userModel.items);
      model.updateItems();
    }
  });

  await Firestore.instance
      .collection(COMMENTS_BASE)
      .where(OWNER_ID, isEqualTo: userModel.getUId())
      .getDocuments()
      .then((query) {
    for (var doc in query.documents) {
      BaseModel model = BaseModel(doc: doc);
      model.put(POST_OWNER, userModel.items);
      model.updateItems();
    }
  });

  await Firestore.instance
      .collection(REPLIES_BASE)
      .where(OWNER_ID, isEqualTo: userModel.getUId())
      .getDocuments()
      .then((query) {
    for (var doc in query.documents) {
      BaseModel model = BaseModel(doc: doc);
      model.put(POST_OWNER, userModel.items);
      model.updateItems();
    }
  });
}

Future<bool> isConnected() async {
  var result = await (Connectivity().checkConnectivity());
  if (result == ConnectivityResult.none) {
    return Future<bool>.value(false);
  }
  return Future<bool>.value(true);
}


addUser(BaseModel me, BaseModel user) async {
  Firestore.instance
      .collection(USER_BASE)
      .document(me.getUId())
      .get()
      .then((shot) {
    BaseModel bm = BaseModel(doc: shot);
    bm.putInList(RECEIVED_REQUESTS, user.getUId(), false);
    bm.putInList(SENT_REQUESTS, user.getUId(), false);
    bm.putInList(CONNECTIONS, user.getUId(), true);
    bm.updateItems();
  });

  Firestore.instance
      .collection(USER_BASE)
      .document(user.getUId())
      .get()
      .then((shot) {
    BaseModel bm = BaseModel(doc: shot);
    bm.putInList(RECEIVED_REQUESTS, me.getUId(), false);
    bm.putInList(SENT_REQUESTS, me.getUId(), false);
    bm.putInList(CONNECTIONS, me.getUId(), true);
    bm.updateItems();
  });
}

updateShareCount(String uid) {
  Firestore.instance.collection(USER_BASE).document(uid).get().then((shot) {
    BaseModel bm = BaseModel(doc: shot);
    bm.putInList(SHARES, userModel.getUId(), true);
    bm.updateItems();
  });
}

BaseModel createEventMap(BaseModel bm) {
  BaseModel model = BaseModel();
  model.put(TYPE, bm.getType());
  model.put(DOCUMENT_ID, bm.getDocId());
  model.put(EVENT_TITLE, bm.get(EVENT_TITLE));
  model.put(EVENT_START_DATE, bm.get(EVENT_START_DATE));
  model.put(EVENT_START_TIME, bm.get(EVENT_START_TIME));
  model.put(EVENT_END_TIME, bm.get(EVENT_END_TIME));
  model.put(EVENT_END_DATE, bm.get(EVENT_END_DATE));
  model.put(EVENT_DETAILS, bm.get(EVENT_DETAILS));
  model.put(CLICKS, bm.get(CLICKS));
  model.put(EVENT_DATA, bm.get(EVENT_DATA));
  model.put(EVENT_INDEX, bm.get(EVENT_INDEX));
  model.put(LOCATION, bm.get(LOCATION));
  model.put(IS_SPONSORED, bm.get(IS_SPONSORED));

  return model;
}

createNotification(BuildContext context, String title, String msg,
    BaseModel model, NotificationType notificationType,
    {String useID, String fcmToken}) {
  print("My Item ${model.myItem()}");
  if (model.myItem()) return;

  try {
    //Handle the notification
    BaseModel bm = BaseModel();
    bm.put(TITLE, title);
    bm.put(DOCUMENT_ID, getRandomId());
    bm.put(POST_ID, useID ?? model.getDocId());
    bm.put(FULL_NAME, userModel.getFullName());
    bm.put(NOTIFICATION_BODY, msg);
    bm.put(IMAGE, userModel.getImage());
    bm.put(OWNER_ID, model.getUId());
    bm.put(MESSAGE, "${userModel.getFullName()} $msg");
    bm.put(TOKEN_ID, fcmToken);
    //print("CREATING... ${bm.items}");
    NotificationHandler(context, bm, HandlerType.outgoingNotification,
        notificationType: notificationType);
  } on PlatformException catch (e) {
    print("EEE $e");
  }
}


performanceItem(BuildContext context, BaseModel model, bool admin) {
  int status = model.getInt(STATUS);
  bool paid = model.getBoolean(HAS_PAID);
  final formatter = NumberFormat("#,###");

  String statusText = status == PENDING
      ? "PENDING APPROVAL"
      : status == APPROVED
          ? "ACTIVE"
          : status == REJECTED
              ? "REJECTED"
              : status == INACTIVE
                  ? "INACTIVE"
                  : status == COMPLETED ? "COMPLETED" : "DISAPPROVED";

}

List<String> getSearchString(String text) {
  text = text.toLowerCase().trim();
  if (text.isEmpty) return List();

  List<String> list = List();
  list.add(text);
  var parts = text.split(" ");
  for (String s in parts) {
    if (s.isNotEmpty) list.add(s);
    for (int i = 0; i < s.length; i++) {
      String sub = s.substring(0, i);
      if (sub.isNotEmpty) list.add(sub);
    }
  }
  for (int i = 0; i < text.length; i++) {
    String sub = text.substring(0, i);
    if (sub.isNotEmpty) list.add(sub.trim());
  }
  return list;
}

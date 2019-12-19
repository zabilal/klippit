import 'dart:io';

import 'package:klippit/navigationUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:klippit/backbone/AppEngine.dart';
import 'package:klippit/screens/Terms.dart';
import 'MainHome.dart';
import 'assets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:klippit/base_module.dart';

import 'package:image_picker/image_picker.dart';

import 'backbone/NotifyEngine.dart';
import 'main.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int currentPage = 0;
  int pageSize = 6;

  var pageController = PageController();
  var nameController = TextEditingController();
  String dateOfBirth = "";
  var numberController = new MaskedTextController(mask: "(000) 000-0000");
  var codeController = TextEditingController();
  var emailController = TextEditingController();
  var userNameController = TextEditingController();
  var rewardController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final formatter = DateFormat("y/ MMM/ dd");

  String countryCode = "+1";
  String phoneNumber = "";

  var avatarController = PageController(viewportFraction: 0.7);
  int avatarPosition = -1;
  bool useImage = false;
  File profileImage;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage == 0) {
          return true;
        }
        if (currentPage == 8) {
          showProgress(true, context, msg: "Finalizing Registeration...");
          FirebaseAuth.instance.currentUser().then((user) {
            Firestore.instance
                .collection(USER_BASE)
                .document(user.uid)
                .get()
                .then((doc) async {
              userModel = BaseModel(doc: doc);
              userModel.put(SIGN_UP_COMPLETE, true);
              userModel.updateItems();
              await BaseModule.initCurrentUser();
              clearScreenUntil(context, MainHome());
            });
          });
        }
        currentPage--;
        pageController.animateToPage(currentPage,
            duration: Duration(milliseconds: 500), curve: Curves.ease);

        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  color: Color(0xFF657292),
                  image: DecorationImage(
                      image: AssetImage(mesh), fit: BoxFit.cover)),
            ),
            new Column(
              children: <Widget>[
                if (currentPage < 7) appBar(),
                Flexible(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (i) {
                      setState(() {
                        currentPage = i;
                      });
                    },
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    itemBuilder: (context, i) {
                      if (i == 0)
                        return page(
                            index: i,
                            title: "What's your name?",
                            hint: "Your full name",
                            controller: nameController,
                            tAndC: true);

                      if (i == 1)
                        return page(
                            index: i,
                            title: "What's your number?",
                            hint: "(678) 0000-0000",
                            controller: numberController,
                            isPhone: true,
                            textInputType: TextInputType.number,
                            countryCode: countryCode,
                            onViewTapped: (_) {
                              countryCode = "+${_.phoneCode}";
                              setState(() {});
                            },
                            tAndC: false);
                      if (i == 2)
                        return page(
                            index: i,
                            title: "Verify your number?",
                            hint: "- - - - - -",
                            textInputType: TextInputType.number,
                            isCode: true,
                            controller: codeController);
                      if (i == 3)
                        return page(
                            index: i,
                            title: "What's your email?",
                            hint: "Your email address",
                            controller: emailController);
                      if (i == 4) {
                        //showProgress(false, context);
                        return page(
                            index: i,
                            title: "Almost done",
                            hint: "Pick a username",
                            controller: userNameController);
                      }

                      if (i == 5) {
                        //showProgress(false, context);
                        return page(
                            index: i,
                            title: "Let's finish up",
                            hint: useImage
                                ? "Choose Profile Image"
                                : "Select a Character",
                            btnTxt: !useImage
                                ? "Upload a photo"
                                : "Pick a Character",
                            isAvatar: true,
                            useImage: useImage,
                            controller: userNameController,
                            profileImage: profileImage,
                            onViewTapped: () {
                              setState(() {
                                useImage = !useImage;
                                profileImage = null;
                                avatarPosition = -1;
                              });
                            },
                            onAvatarTapped: () {
                              showListDialog(
                                context,
                                [
                                  "Pick from camera",
                                  "Pick from gallery",
                                ],
                                onClicked: (position) async {
                                  if (position == 0) {
                                    profileImage = await pickImageAndCrop(
                                        ImageSource.camera,
                                        canCrop: true,
                                        useCircle: true);
                                    setState(() {});
                                    return;
                                  }

                                  if (position == 1) {
                                    profileImage = await pickImageAndCrop(
                                        ImageSource.gallery,
                                        canCrop: true,
                                        useCircle: true);
                                    setState(() {});
                                    return;
                                  }
                                },
                                useTint: false,
                                delayInMilli: 10,
                              );
                            });
                      }

                      if (i == 6) {
                        //showProgress(false, context);
                        return page(
                            index: i,
                            title:
                                "Did someone invite you \n with a reward code?",
                            hint: userModel.getRewardCode() != null ? userModel.getRewardCode() : "Reward code (optional)",
                            controller: rewardController);
                      }

                      //if (i == 6)
                      return page(
                          index: i,
                          title:
                              "Great to have you on board,\n ${userNameController.text}",
                          hint: "Your full name",
                          controller: null,
                          isFinish: true);
                      //if (i == 5) showProgress(false, context);
                    },
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: buildBtmTitle(currentPage),
              ),
            )
          ],
        ),
      ),
    );
  }

  page({
    @required int index,
    @required String title,
    @required String hint,
    String btnTxt,
    TextEditingController controller,
    String value,
    TextInputType textInputType = TextInputType.text,
    String countryCode,
    File profileImage,
    onViewTapped,
    onAvatarTapped,
    bool isCode = false,
    bool isFinish = false,
    bool isAvatar = false,
    bool useImage = false,
    bool tAndC = false,
    bool isDOB = false,
    bool isController = true,
    bool isPhone = false,
  }) {
    if (isAvatar) {
      return Container(
        padding: EdgeInsets.only(left: 15, right: 15, bottom: 25),
        child: Column(
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.justify,
              style: textStyle(true, 20, white),
            ),
            addSpace(10),
            if (useImage && profileImage == null)
              GestureDetector(
                onTap: onAvatarTapped,
                child: Container(
                  height: 100,
                  width: 100,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: white,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: black.withOpacity(.7)),
                ),
              )
            else if (useImage && profileImage != null)
              GestureDetector(
                onTap: onAvatarTapped,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(image: FileImage(profileImage)),
                      shape: BoxShape.circle,
                      color: black.withOpacity(.7)),
                ),
              )
            else
              Flexible(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (c, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          avatarPosition = index;
                        });
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
                                  border:
                                      Border.all(color: black.withOpacity(.1))),
                            ),
                        ],
                      ),
                    );
                  },
                  itemCount: avatars.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                ),
              ),
            addSpace(10),
            Column(
              children: <Widget>[
                Text(
                  hint,
                  textAlign: TextAlign.justify,
                  style: textStyle(true, 20, indicatorColor),
                ),
                addSpace(10),
                Text(
                  "OR",
                  textAlign: TextAlign.justify,
                  style: textStyle(true, 20, white),
                ),
                addSpace(15),
                RaisedButton(
                  onPressed: onViewTapped,
                  color: Colors.transparent,
                  padding: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: white)),
                  child: Center(
                    child: Text(
                      btnTxt,
                      style: textStyle(false, 16, white),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(15),
      child: Stack(
        children: <Widget>[
          if (isFinish)
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 80,
                      width: 80,
                      child: Icon(
                        Icons.check,
                        size: 40,
                      ),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                  addSpace(10),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: textStyle(
                        true,
                        18,
                        Colors.white,
                      )),
                  addSpace(15),
                  RaisedButton(
                    onPressed: () {
                      showProgress(true, context,
                          msg: "Finalizing Registeration...");
                      FirebaseAuth.instance.currentUser().then((user) {
                        Firestore.instance
                            .collection(USER_BASE)
                            .document(user.uid)
                            .get()
                            .then((doc) async {
                          userModel = BaseModel(doc: doc);
                          userModel.put(SIGN_UP_COMPLETE, true);
                          userModel.updateItems();
                          await BaseModule.initCurrentUser();
                          clearScreenUntil(context, MainHome());
                        });
                      });
                    },
                    padding: EdgeInsets.all(12),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    child: Center(child: Text("FINISH")),
                  )
                ],
              ),
            )
          else
            //if (!isFinish)
            Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  inputTv(title, hint, controller,
                      isDOB: isDOB,
                      isPhone: isPhone,
                      isCode: isCode,
                      countryCode: countryCode,
                      onViewTap: onViewTapped,
                      textInputType: textInputType),
                  addSpace(10),
                  if (isCode) ...[
                    Text(
                      "Enter the 6 digit number sent to you",
                      style: textStyle(true, 12, white.withOpacity(.5)),
                    ),
                    addSpace(15),
                    Opacity(
                      opacity: timeText.isEmpty ? 1 : (.5),
                      child: Container(
                        height: 35,
                        width: 105,
                        child: FlatButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                                side: BorderSide(
                                    color: black.withOpacity(.1), width: .5)),
                            color: default_white,
                            onPressed: () {
                              if (timeText.isEmpty) {
                                clickVerify();
                              }
                            },
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                // addSpaceWidth(5),
                                Text(
                                  "Resend Code",
                                  style: textStyle(true, 12, black),
                                ),
                                timeText.isEmpty
                                    ? Container()
                                    : Text(
                                        timeText,
                                        style: textStyle(false, 10, black),
                                      ),
                                //addSpaceWidth(5),
                              ],
                            )),
                      ),
                    ),
                    addSpace(40),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }

  buildBtmTitle(int position) {
    if (position == 0) {
      return GestureDetector(
        onTap: () {
          goToWidget(context, TermsAndConditions());
        },
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
                text: "By signing up, you have agreed to our ",
                style: textStyle(false, 14, white)),
            TextSpan(
                text: "Terms and Conditions and Privacy Statement",
                style: textStyle(false, 14, indicatorColor, underlined: true))
          ]),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (position == 1) {
      return Text(
          "We will send you a verification code."
          " Mobile only, no VoIP or International"
          " number at this time.",
          textAlign: TextAlign.center,
          style: textStyle(
            false,
            14,
            Colors.white,
          ));
    }

    if (position == 2) {
      return Text("Need Help?",
          textAlign: TextAlign.center,
          style: textStyle(
            false,
            14,
            Colors.white,
          ));
    }

    if (position == 3) {
      return Text(
          "So we can update you about your "
          "money.You'll need to verify it to finalize "
          "your account later on.",
          textAlign: TextAlign.center,
          style: textStyle(
            false,
            14,
            Colors.white,
          ));
    }

    if (position == 4) {
      return Text(
          "Your friends and family "
          "can instantly send money to your username",
          textAlign: TextAlign.center,
          style: textStyle(
            false,
            14,
            Colors.white,
          ));
    }

  //  if (position == 5) {
  //    return Text("What your Referee reward code?",
  //        textAlign: TextAlign.center,
  //        style: textStyle(
  //          false,
  //          14,
  //          indicatorColor,
  //        ));
  //  }

    if (position == 5) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              pageController.jumpToPage(6);
            },
            child: Text("Do you have a reward code?",
                textAlign: TextAlign.center,
                style: textStyle(
                  false,
                  20,
                  Colors.white,
                )),
          ),
          addSpace(10),
          RaisedButton(
            onPressed: () {
              showProgress(true, context, msg: "Finalizing Registeration...");
              FirebaseAuth.instance.currentUser().then((user) {
                Firestore.instance
                    .collection(USER_BASE)
                    .document(user.uid)
                    .get()
                    .then((doc) async {
                  userModel = BaseModel(doc: doc);
                  userModel.put(SIGN_UP_COMPLETE, true);
                  userModel.updateItems();
                  checkRewardWithUID();

                  cloudEmailPush(
                      type: 0,
                      email: userModel.getEmail(),
                      fullName: userModel.getFullName(),
                      referred: userModel.getFullName());
                      

                  await BaseModule.initCurrentUser();
                  clearScreenUntil(context, MainHome());
                });
              });
            },
            padding: EdgeInsets.all(15),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Center(child: Text("DONE")),
          )
        ],
      );
    }
    return Container();
  }

  appBar() {
    return Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    BackButton(color: Colors.white),
                    Column(
                      children: <Widget>[
                        pageIndicator(pageSize, currentPage),
                        if (currentPage < 7 && currentPage != 5)
                          Padding(
                            padding: const EdgeInsets.only(right: 00, top: 10),
                            child: Image.asset(
                              logo,
                              height: 40,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          )
                      ],
                    ),
                    RaisedButton(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(currentPage == 2
                            ? "Verify"
                            : currentPage == 6
                                ? "Apply"
                                : currentPage == 6 ? "Finish" : "Next"),
                        onPressed: () {
                          if (currentPage == 0 && nameController.text.isEmpty) {
                            toast(scaffoldKey, "Please enter your full name");
                            return;
                          }

//
                          if (currentPage == 1) {
                            checkPhone();
                            return;
                          }

                          if (currentPage == 2) {
                            checkCode();
                            return;
                          }

                          if (currentPage == 3) {
                            checkEmail();
                            return;
                          }

                          if (currentPage == 4) {
                            checkUsername();
                            return;
                          }

                          if (currentPage == 5) {
                            checkAvatar();
                            return;
                          }

                          if (currentPage == 6) {
                            checkReward();
                            return;
                          }

                          pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        }),
                  ],
                ),
                /* if (currentPage < 8 && currentPage != 6)
                  Padding(
                    padding: const EdgeInsets.only(right: 00, top: 10),
                    child: Image.asset(
                      logo,
                      height: 40,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  )*/
              ],
            ),
          ),
        ));
  }

  inputTv(title, hint, controller,
      {bool isDOB = false,
      bool isPhone = false,
      bool isCode = false,
      String countryCode,
      onViewTap,
      TextInputType textInputType = TextInputType.text,
      Color selectorColor = white}) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
        ),
        addSpace(15),
        if (isDOB) ...[
          GestureDetector(
            onTap: onViewTap,
            child: Container(
              //alignment: Alignment.center,
              padding: EdgeInsets.all(18),
              child: Text(
                hint.isEmpty ? "YY / MM / DD" : hint,
                style: textStyle(false, 17,
                    hint.isEmpty ? Colors.white.withOpacity(.7) : white),
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2)),
            ),
          ),
          addSpace(10),
          Text(
            "Year / Month / Day",
            style: textStyle(false, 14, white),
          )
        ] else
          TextField(
            controller: controller,
            style: textStyle(false, 18, white),
            textAlign: isPhone ? TextAlign.start : TextAlign.center,
            keyboardType: textInputType,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              filled: true,
              prefixIcon: !isPhone
                  ? null
                  : GestureDetector(
                      onTap: () {
                        pickCountry(context, (Country _) {
                          onViewTap(_);
                        });
                      },
                      child: Container(
                        height: 30,
                        width: 60,
                        margin: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                            color: selectorColor,
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                          child: Text(
                            countryCode,
                            style: textStyle(true, 14, black.withOpacity(.7)),
                          ),
                        ),
                      ),
                    ),
              fillColor: Color(0xFF657292),
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(.7),
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 2.0)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 2.0)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 2.0)),
            ),
            onChanged: (newText) {
              if (!isCode) return;
              if (newText.length <= 6) {
                oldText = newText;
              } else {
                codeController.text = oldText;
              }

              String s = codeController.text;
              if (s.trim().length == 6) {
                checkCode();
              }
            },
          ),
      ],
    );
  }

  pageIndicator(int pageSize, int currentPage) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageSize, (index) {
          if (currentPage == index) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: indicatorColor),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 6,
              width: 6,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            ),
          );
        }),
      ),
    );
  }

  String verificationId = "";
  String smsCode = "";
  int forceResendingToken = 0;
  bool verified = false;
  String timeText = "";
  String oldText = "";
  int time = 0;
  final progressId = getRandomId();
  bool verifying = false;

  createTimer(bool create) {
    if (create) {
      time = 60;
    }
    if (time < 0) {
      setState(() {
        timeText = "";
      });
      return;
    }
    timeText = getTimeText();
    Future.delayed(Duration(seconds: 1), () {
      time--;
      if (mounted) setState(() {});
      createTimer(false);
    });
  }

  getTimeText() {
    if (time <= 0) return "";
    return "${time >= 60 ? "01" : "00"}:${time % 60}";
  }

  checkPhone() async {
    String text = numberController.text
        .replaceAll("(", "")
        .replaceAll(")", "")
        .replaceAll("-", "")
        .replaceAll(" ", "")
        .trim();
    if (numberController.text.isEmpty) {
      toast(scaffoldKey, "Please enter your mobile number");
      return;
    }

    if (text.startsWith("0")) {
      text = text.replaceFirst("0", "").trim();
    }
    phoneNumber = "$countryCode$text";

    showMessage(context, Icons.phone_android, textColor, phoneNumber,
        "Please verify that this is your phone number",
        clickYesText: "Proceed", clickNoText: "Edit Number", onClicked: (_) {
      if (_ == true) {
        clickVerify();
      }
    });
  }

  checkCode() async {
    String code = codeController.text.trim();
    if (code.isEmpty) {
      toast(scaffoldKey, "Enter the sms code sent to you or click resend code");
      return;
    }
    AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId, smsCode: code);
    await startAcctCreation(credential);
  }

  checkEmail() async {
    String email = emailController.text.trim();
    if (email.isEmpty) {
      toast(scaffoldKey, "Please enter your email address");
      return;
    }
    showProgress(true, context, msg: "Checking email availability...");

    try {
      Firestore.instance
          .collection(USER_BASE)
          .where(EMAIL, isEqualTo: email.toLowerCase())
          .limit(1)
          //.orderBy(TIME, descending: true)
          .getDocuments(/*source: Source.server*/)
          .then((shots) {
        print(shots.documents.length);
        if (shots.documents.length > 0) {
          showProgress(
            false,
            context,
          );
          showMessage(
              context,
              Icons.warning,
              Colors.red,
              "Email Error!",
              "You have entered an email address that exist."
                  " Only unique emails are allowed.",
              //clickYesText: "Try Again",
              cancellable: true,
              //onClicked: (_) async {},
              delayInMilli: 900);
          return;
        }

        FirebaseAuth.instance.currentUser().then((user) {
          if (user != null) {
            AuthCredential emailCredential = EmailAuthProvider.getCredential(
                email: email, password: '%%*01234*%%');
            user.linkWithCredential(emailCredential);

            Firestore.instance
                .collection(USER_BASE)
                .document(user.uid)
                .get()
                .then((doc) {
              BaseModel model = BaseModel(doc: doc);
              model.put(EMAIL, emailController.text.trim().toLowerCase());
              model.put(PASSWORD, '%%*01234*%%');
              model.put(FULL_NAME, nameController.text);
              model.updateItems();
              pageController.nextPage(
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
              showProgress(
                false,
                context,
              );
            });
          }
        });
      });
    } on PlatformException catch (e) {
      showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "Email Error!", e.message,
          clickYesText: "Try Again",
          delayInMilli: 900,
          onClicked: (_) async {});
    }
  }

  checkUsername() async {
    String username = userNameController.text.trim();
    if (username.isEmpty) {
      toast(scaffoldKey, "Please enter a username");
      return;
    }
    showProgress(true, context, msg: "Verifying Username...");

    Firestore.instance
        .collection(USER_BASE)
        .where(USERNAME, isEqualTo: username)
        .limit(1)
        //.orderBy(TIME, descending: true)
        .getDocuments(/*source: Source.server*/)
        .then((shots) {
      print(shots.documents.length);
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
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance
            .collection(USER_BASE)
            .document(user.uid)
            .get()
            .then((doc) {
          BaseModel model = BaseModel(doc: doc);
          List searchArray = getSearchString(
              "${userNameController.text} ${emailController.text}");

          model.put(EMAIL, emailController.text.trim().toLowerCase());
          model.put(REWARD_CODE, user.uid.substring(0, 8).toUpperCase());
          model.put(IS_PRE_LAUNCH, true);
          model.put(SEARCH_DATA, searchArray);

          model.put(USERNAME, username);
          model.put(AMOUNT_EARNED, 1);//Automatically grant new person $1
          model.updateItems();
          pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          showProgress(
            false,
            context,
          );
        });
      });
    });
  }

  checkReward() async {
    if (rewardController.text.isEmpty) {
      toast(scaffoldKey, "Please enter reward code");
      return;
    }

    showProgress(true, context, msg: "Verifying Code...");

    String rewardCode = rewardController.text.toUpperCase();
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(REWARD_CODE, isEqualTo: rewardCode)
        .limit(1)
        .getDocuments();

    if (shots.documents.length == 0) {
      showProgress(false, context);
      showMessage(
          context,
          Icons.warning,
          Colors.red,
          "Referral Error!",
          "Oops, seems like that referral code is not valid."
              " Double check that you've entered it correctly"
              " or ask a friend for their code.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }

    BaseModel ref = BaseModel(doc: shots.documents[0]);
    var refUser = await Firestore.instance
        .collection(USER_BASE)
        .document(ref.getUId())
        .get();

    if (!refUser.exists) {
      showProgress(false, context);
      showMessage(
          context,
          Icons.warning,
          Colors.red,
          "Referral Error!",
          "Oops, no user was found with that referral code."
              " Double check that you've entered it correctly"
              " or ask a friend for their code.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }

    var user = await FirebaseAuth.instance.currentUser();
    var userDoc =
        await Firestore.instance.collection(USER_BASE).document(user.uid).get();
    userModel = BaseModel(doc: userDoc);

    if (ref.getUId() == userModel.getUId()) {
      showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "Referral Error!",
          "Oops, the referral code entered belongs to you, therefore you can't refer yourself.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }
    if (ref.getString(INVITED_BY).isNotEmpty) {
      ref.put(INVITED_BY, userModel.getUId());
    }
    //ref.put(INVITED_BY, userModel.getUId());
    ref.putInList(REFERRALS, userModel.getUId(), true);
    ref.put(AMOUNT_EARNED, ref.getInt(AMOUNT_EARNED) + 1);
    ref.updateItems();

//    userModel.put(IS_REFERRED, true);
//    userModel.put(INVITED_BY, ref.getUId());
//    userModel.putInList(REFERRALS, ref.getUId(), true);
//    userModel.put(AMOUNT_EARNED, userModel.getInt(AMOUNT_EARNED) + 1);
//    userModel.updateItems();

    List myInvite = ref.getList(REFERRALS);
    if (myInvite.length == 1) {
      cloudEmailPush(
          type: 1,
          email: ref.getEmail(),
          fullName: ref.getFullName(),
          referred: userModel.getFullName());
    } else {
      cloudEmailPush(
          type: 2,
          email: ref.getEmail(),
          fullName: ref.getFullName(),
          referred: userModel.getFullName());
    }

    //Handle the notification
    BaseModel bm = BaseModel();
    bm.put(TITLE, "You've just earned \$1!");
    bm.put(
        MESSAGE,
        "👏💸 ${userModel.getFullName()}"
        " signed up for Klippit using your ref code."
        "Keep going!");
    bm.put(TOKEN_ID, ref.getToken());
    //bm.put(TOKEN_ID, ref.getPushToken());
    NotifyEngine(context, bm, HandleType.outgoingNotification,
        notificationType: NotifyType.referral00);

    showProgress(false, context);
    showMessage(context, Icons.check, dark_green1, "Code Approved!",
        "You applied a reward code!",
        clickYesText: "Got it", cancellable: false, onClicked: (_) async {
      // Navigator.pop(context);
      FirebaseAuth.instance.currentUser().then((user) {
                Firestore.instance
                    .collection(USER_BASE)
                    .document(user.uid)
                    .get()
                    .then((doc) async {
                  userModel = BaseModel(doc: doc);
                  userModel.put(SIGN_UP_COMPLETE, true);
                  userModel.updateItems();

                  cloudEmailPush(
                      type: 0,
                      email: userModel.getEmail(),
                      fullName: userModel.getFullName(),
                      referred: userModel.getFullName());

                  await BaseModule.initCurrentUser();
                  clearScreenUntil(context, MainHome());
                });
              });
    }, delayInMilli: 900);
  }

  checkRewardWithUID() async {
    if (uid == null) {
      // toast(scaffoldKey, "Please enter reward code or use the link from a friend");
      return;
    }

    showProgress(true, context, msg: "Verifying User...");

    String rewardCode = uid;
    QuerySnapshot shots = await Firestore.instance
        .collection(USER_BASE)
        .where(USER_ID, isEqualTo: rewardCode)
        .limit(1)
        .getDocuments();

    if (shots.documents.length == 0) {
      showProgress(false, context);
      showMessage(
          context,
          Icons.warning,
          Colors.red,
          "Referral Error!",
          "Oops, seems like that user ID is not valid."
              " Double check that you've entered it correctly"
              " or ask a friend to share their link.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }

    BaseModel ref = BaseModel(doc: shots.documents[0]);
    var refUser = await Firestore.instance
        .collection(USER_BASE)
        .document(ref.getUId())
        .get();

    if (!refUser.exists) {
      showProgress(false, context);
      showMessage(
          context,
          Icons.warning,
          Colors.red,
          "Referral Error!",
          "Oops, no user was found with that User ID."
              " Double check that you've entered it correctly"
              " or ask a friend to share their link.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }

    var user = await FirebaseAuth.instance.currentUser();
    var userDoc =
        await Firestore.instance.collection(USER_BASE).document(user.uid).get();
    userModel = BaseModel(doc: userDoc);

    if (ref.getUId() == userModel.getUId()) {
      showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "Referral Error!",
          "Oops, the user ID entered belongs to you, therefore you can't refer yourself.",
          clickYesText: "Try Again",
          cancellable: false,
          onClicked: (_) async {},
          delayInMilli: 900);
      return;
    }
    if (ref.getString(INVITED_BY).isNotEmpty) {
      ref.put(INVITED_BY, userModel.getUId());
    }
    //ref.put(INVITED_BY, userModel.getUId());
    ref.putInList(REFERRALS, userModel.getUId(), true);
    ref.put(AMOUNT_EARNED, ref.getInt(AMOUNT_EARNED) + 1);
    ref.updateItems();

//    userModel.put(IS_REFERRED, true);
//    userModel.put(INVITED_BY, ref.getUId());
//    userModel.putInList(REFERRALS, ref.getUId(), true);
//    userModel.put(AMOUNT_EARNED, userModel.getInt(AMOUNT_EARNED) + 1);
//    userModel.updateItems();

    List myInvite = ref.getList(REFERRALS);
    if (myInvite.length == 1) {
      cloudEmailPush(
          type: 1,
          email: ref.getEmail(),
          fullName: ref.getFullName(),
          referred: userModel.getFullName());
    } else {
      cloudEmailPush(
          type: 2,
          email: ref.getEmail(),
          fullName: ref.getFullName(),
          referred: userModel.getFullName());
    }

    //Handle the notification
    BaseModel bm = BaseModel();
    bm.put(TITLE, "You've just earned \$1!");
    bm.put(
        MESSAGE,
        "👏💸 ${userModel.getFullName()}"
        " signed up for Klippit using your link."
        "Keep going!");
    bm.put(TOKEN_ID, ref.getToken());
    //bm.put(TOKEN_ID, ref.getPushToken());
    NotifyEngine(context, bm, HandleType.outgoingNotification,
        notificationType: NotifyType.referral00);

    showProgress(false, context);
    showMessage(context, Icons.check, dark_green1, "Code Approved!",
        "You applied a reward code!",
        clickYesText: "Got it", cancellable: false, onClicked: (_) async {
      // Navigator.pop(context);
      FirebaseAuth.instance.currentUser().then((user) {
                Firestore.instance
                    .collection(USER_BASE)
                    .document(user.uid)
                    .get()
                    .then((doc) async {
                  userModel = BaseModel(doc: doc);
                  userModel.put(SIGN_UP_COMPLETE, true);
                  userModel.updateItems();

                  cloudEmailPush(
                      type: 0,
                      email: userModel.getEmail(),
                      fullName: userModel.getFullName(),
                      referred: userModel.getFullName());

                  await BaseModule.initCurrentUser();
                  clearScreenUntil(context, MainHome());
                });
              });
    }, delayInMilli: 900);
  }

  /*checkReward() async {
    if (rewardController.text.isEmpty) {
      toast(scaffoldKey, "Please enter reward code");
      return;
    }

    showProgress(true, context, msg: "Verifying Code...");

    Firestore.instance
        .collection(USER_BASE)
        .where(REWARD_CODE, isEqualTo: rewardController.text.toUpperCase())
        .limit(1)
        //.orderBy(TIME, descending: true)
        .getDocuments(*/ /*source: Source.server*/ /*)
        .then((shots) {
      print(shots.documents.length);
      if (shots.documents.length == 0) {
        showProgress(false, context);
        setState(() {});
        showMessage(
            context,
            Icons.warning,
            Colors.red,
            "Reward Error!",
            "The reward code doesn't exist on our record, please "
                "check and confirm the code then try again.",
            clickYesText: "Try Again",
            cancellable: false,
            onClicked: (_) async {},
            delayInMilli: 900);
        return;
      }
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance
            .collection(USER_BASE)
            .document(user.uid)
            .get()
            .then((doc) {
          BaseModel invitedBy = BaseModel(doc: shots.documents[0]);

          if (invitedBy.getUId() == userModel.getUId()) {
            showProgress(false, context);
            showMessage(context, Icons.warning, Colors.red, "Referral Error!",
                "Oops, the referral code entered belongs to you, therefore you can't refer yourself.",
                clickYesText: "Try Again",
                cancellable: false, onClicked: (_) async {
              */ /*showProgress(
            false,
            context,
          );*/ /*
            }, delayInMilli: 900);
            return;
          }

          BaseModel model = BaseModel(doc: doc);
          //model.put(SHOW_INVITED, true);
          model.put(IS_REFERRED, true);
          model.put(INVITED_BY, invitedBy.getUId());
          model.put(AMOUNT_EARNED, model.getInt(AMOUNT_EARNED) + 1);
          model.putInList(REFERRALS, invitedBy.getUId(), true);
          //model.updateCountItem(AMOUNT_EARNED, true);
          model.updateItems();

          invitedBy.put(AMOUNT_EARNED, invitedBy.getInt(AMOUNT_EARNED) + 1);
          invitedBy.putInList(REFERRALS, user.uid, true);
          //invitedBy.updateCountItem(AMOUNT_EARNED, true);
          invitedBy.put(INVITED_BY, model.getUId());
          invitedBy.updateItems();

          List myInvite = invitedBy.getList(REFERRALS);
          if (myInvite.length == 1) {
            cloudEmailPush(
                type: 1,
                email: invitedBy.getEmail(),
                fullName: invitedBy.getFullName(),
                referred: model.getFullName());
          } else {
            cloudEmailPush(
                type: 2,
                email: invitedBy.getEmail(),
                fullName: invitedBy.getFullName(),
                referred: model.getFullName());
          }

          //Handle the notification
          BaseModel bm = BaseModel();
          bm.put(TITLE, "You've just earned \$1!");
          bm.put(
              MESSAGE,
              "👏💸 ${model.getFullName()}"
              " signed up for Klippit using your ref code."
              "Keep going!");
          bm.put(TOKEN_ID, invitedBy.getPushToken());
          NotifyEngine(context, bm, HandleType.outgoingNotification,
              notificationType: NotifyType.referral00);

          pageController.nextPage(
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          showProgress(
            false,
            context,
          );
        });
      });
    });
  }*/

  checkAvatar() async {
    if (avatarPosition == -1 && !useImage) {
      toast(scaffoldKey, "Please select an avatar");
      return;
    }

    if (useImage && profileImage == null) {
      toast(scaffoldKey, "Please choose image");
      return;
    }

    if (useImage) showProgress(true, context, msg: "Uploading Image...");

    try {
      FirebaseAuth.instance.currentUser().then((user) {
        Firestore.instance
            .collection(USER_BASE)
            .document(user.uid)
            .get()
            .then((doc) async {
          var uploadEngine;
          var imageURL;

          if (useImage) {
            uploadEngine =
                UploadEngine(fileToSave: profileImage, uploadPath: USER_BASE);
            imageURL = await uploadEngine.uploadPhoto(uid: user.uid);
          }

          BaseModel model = BaseModel(doc: doc);
          model.put(AVATAR_POSITION, avatarPosition);
          model.put(USE_AVATAR, !useImage);
          model.put(IMAGE, imageURL);

          model.updateItems();
          pageController.animateToPage(7,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          if (useImage)
            showProgress(
              false,
              context,
            );
        });
      });
    } on PlatformException catch (e) {
      if (useImage) showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "Image Error!", e.message,
          clickYesText: "Try Again", onClicked: (_) async {});
    }
  }

  //keytool -list -v \-alias androiddebugkey -keystore ~/.android/debug.keystore

  clickVerify() {
    showProgress(
      true,
      context,
      msg: "Sending sms code...",
    );
    try {
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 10),
        verificationCompleted: (phoneAuthCredential) async {
          showProgress(false, context);
          await startAcctCreation(phoneAuthCredential, verified: true);
        },
        verificationFailed: (AuthException authException) {
          codeController.clear();
          showProgress(
            false,
            context,
          );
          FirebaseAuth.instance.signOut();
          showMessage(context, Icons.warning, red0, "Verification Error",
              authException.message,
              delayInMilli: 900);
        },
        codeSent: (s, [x]) {
          createTimer(true);
          //codeSent=s;
          verifying = true;
          pageController.animateToPage(2,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
          showProgress(false, context);
          verificationId = s;
          forceResendingToken = x;
          setState(() {});
        },
        codeAutoRetrievalTimeout: null,
        forceResendingToken: forceResendingToken,
      );
    } on PlatformException catch (e) {
      showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "SMS Error!", e.message,
          clickYesText: "Try Again",
          onClicked: (_) async {},
          delayInMilli: 900);
    }
  }

  startAcctCreation(AuthCredential phoneAuthCredential,
      {bool verified = false}) async {
    showProgress(true, context, msg: "Verifying Code...");
    try {
      AuthResult result =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      Firestore.instance
          .collection(USER_BASE)
          .document(result.user.uid)
          .get()
          .then((doc) {
        BaseModel dataModel = BaseModel(doc: doc);

        if (doc.exists && dataModel.getBoolean(SIGN_UP_COMPLETE)) {
          showProgress(
            false,
            context,
          );
          showMessage(context, Icons.warning, red0, "Error",
              "Phone number has already been used to create an account",
              delayInMilli: 900, onClicked: (_) {
            FirebaseAuth.instance.signOut();
          }, clickYesText: "Edit Number");
          return;
        }
        BaseModel model = BaseModel();
        model.put(FULL_NAME, nameController.text);
        model.put(USER_ID, result.user.uid);
        model.put(PHONE_NO, result.user.phoneNumber);
        model.put(PHONE_VERIFIED, true);
        model.put(BIRTHDAY, dateOfBirth);
        model.saveItem(USER_BASE, false, document: result.user.uid,
            onComplete: () {
          showProgress(false, context);
          pageController.animateToPage(3,
              duration: Duration(milliseconds: 500), curve: Curves.ease);
        });
      });
    } on PlatformException catch (e) {
      showProgress(false, context);
      showMessage(context, Icons.warning, Colors.red, "OTP Error!", e.message,
          clickYesText: "Try Again",
          delayInMilli: 900,
          onClicked: (_) async {});
    }
  }
}

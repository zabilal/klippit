import 'package:klippit/navigationUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:klippit/backbone/AppEngine.dart';
import 'MainHome.dart';
import 'assets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:klippit/base_module.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  int currentPage = 0;
  int pageSize = 3;

  var pageController = PageController();
  var nameController = TextEditingController();
  String dateOfBirth = "";
  String currentDateOfBirth;
  var numberController = new MaskedTextController(mask: "(000) 000-0000");
  var codeController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final formatter = DateFormat("y/ MMM/ dd");

  String countryCode = "+1";
  String phoneNumber = "";
  String userName = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentPage == 0) {
          return true;
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
                if (currentPage != 2) appBar(),
                Flexible(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (i) {
                      setState(() {
                        currentPage = i;
                      });
                    },
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pageSize,
                    itemBuilder: (context, i) {
                      if (i == 0)
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
                      if (i == 1)
                        return page(
                            index: i,
                            title: "Verify your number?",
                            hint: "- - - - - -",
                            textInputType: TextInputType.number,
                            isCode: true,
                            controller: codeController);

//                      if (i == 2)
//                        return page(
//                            index: i,
//                            title: "Confirm your birth date?",
//                            hint: dateOfBirth,
//                            value: dateOfBirth,
//                            isDOB: true,
//                            tAndC: true,
//                            onViewTapped: () {
//                              DatePicker.showDatePicker(context,
//                                  currentTime: DateTime(1990, 1, 1),
//                                  locale: LocaleType.en,
//                                  showTitleActions: true, onConfirm: (date) {
//                                dateOfBirth = formatter.format(date);
//                                setState(() {});
//                              }, onChanged: (date) {
//                                dateOfBirth = formatter.format(date);
//                                setState(() {});
//                              });
//                            });

                      if (i == 2) {
                        print("Page 2");
                        Future.delayed(Duration(milliseconds: 1000), () async {
                          await BaseModule.initCurrentUser();
                          clearScreenUntil(context, MainHome());
                        });
                      }

                      return page(
                          index: i,
                          title: "Welcome back,\n $userName",
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

  page(
      {@required int index,
      @required String title,
      @required String hint,
      TextEditingController controller,
      String value,
      bool isFinish = false,
      bool tAndC = false,
      bool isDOB = false,
      bool isController = true,
      bool isPhone = false,
      TextInputType textInputType = TextInputType.text,
      String countryCode,
      onViewTapped,
      bool isCode = false}) {
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
                        20,
                        Colors.white,
                      )),
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
      return Text.rich(
        TextSpan(children: [
          TextSpan(
              text:
                  "To login, please enter the mobile number you signed up with. ",
              style: textStyle(false, 14, white)),
          TextSpan(
              text: "\nChanged your mobile number?",
              style: textStyle(true, 14, indicatorColor, underlined: true))
        ]),
        textAlign: TextAlign.center,
      );
    }

    if (position == 1) {
      return GestureDetector(
        onTap: () {
          showListDialog(
            context,
            [
              "Send new code",
              "Edit phone number",
              "Are you trying to sign up?",
              "Contact support"
            ],
            onClicked: (position) {},
            useTint: false,
            delayInMilli: 10,
          );
        },
        child: Text("Need help?",
            textAlign: TextAlign.center,
            style: textStyle(
              false,
              14,
              Colors.white,
            )),
      );
    }

    return Container();
  }

  appBar() {
    return Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          //bottom: false,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: pageIndicator(pageSize, currentPage),
                        ),
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
                        child: Text(currentPage == 1
                            ? "Verify"
                            : currentPage == 2 ? "Finish" : "Next"),
                        onPressed: () {
                          if (currentPage == 0) {
                            checkPhone();
                            return;
                          }

                          if (currentPage == 1) {
                            checkCode();
                            return;
                          }

//                          if (currentPage == 2) {
//                            checkDate();
//                            return;
//                          }

                          pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease);
                        }),
                  ],
                ),
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
          textAlign: TextAlign.justify,
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
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageSize, (index) {
        if (currentPage == index) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 8,
              width: 8,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: indicatorColor),
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

  clickVerify() {
    showProgress(
      true,
      context,
      msg: "Sending sms code...",
    );
    try {
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 5),
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
          showMessage(context, Icons.warning, red0, "Verification Error",
              authException.message,
              delayInMilli: 900);
        },
        codeSent: (s, [x]) {
          createTimer(true);
          //codeSent=s;
          verifying = true;
          pageController.animateToPage(1,
              duration: Duration(milliseconds: 800), curve: Curves.ease);
          showProgress(false, context);
          verificationId = s;
          forceResendingToken = x;
          setState(() {});
        },
        codeAutoRetrievalTimeout: null,
        forceResendingToken: forceResendingToken,
      );
    } on PlatformException catch (e) {
      showMessage(context, Icons.warning, Colors.red, "SMS Error!", e.message,
          clickYesText: "Try Again",
          cancellable: true,
          delayInMilli: 900, onClicked: (_) async {
        showProgress(false, context);
      });
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
        if (!doc.exists) {
          showMessage(context, Icons.warning, red0, "Error",
              "This Phone number has not been used to create an account",
              delayInMilli: 900, onClicked: (_) {
            showProgress(
              false,
              context,
            );
            FirebaseAuth.instance.signOut();
          }, clickYesText: "Edit Number");
          return;
        }

        BaseModel model = BaseModel(doc: doc);
        setState(() {
          currentDateOfBirth = model.getString(BIRTHDAY);
          userName = model.getString(USERNAME);
          userModel = model;
          setState(() {});
        });
        showProgress(false, context);
        pageController.animateToPage(2,
            duration: Duration(milliseconds: 800), curve: Curves.ease);
      });
    } on PlatformException catch (e) {
      showMessage(context, Icons.warning, Colors.red, "OTP Error!", e.message,
          clickYesText: "Try Again",
          cancellable: true,
          delayInMilli: 900, onClicked: (_) async {
        showProgress(false, context);
      });
    }
  }

  checkDate() async {
    if (dateOfBirth.isEmpty) {
      toast(scaffoldKey, "Please choose your date of birth");
      return;
    }

    showProgress(true, context, msg: "Verifying Date of birth...");

    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      Firestore.instance
          .collection(USER_BASE)
          .document(user.uid)
          .get()
          .then((doc) {
        BaseModel model = BaseModel(doc: doc);
        String currentDateOfBirth = model.getString(BIRTHDAY);
        /*print(currentDateOfBirth.replaceAll("/ ", ""));
        print(dateOfBirth.replaceAll("/ ", ""));

        String oDob = currentDateOfBirth.replaceAll("/ ", "");
        String dob = dateOfBirth.replaceAll("/ ", "");
        print(oDob == dob);*/
        if (dateOfBirth != currentDateOfBirth) {
          showMessage(
              context,
              Icons.warning,
              Colors.red,
              "Verification Failed!",
              "Sorry we could not verify that this is your account, the date of birth doesn't correspond.",
              clickYesText: "Try Again",
              cancellable: false, onClicked: (_) async {
            showProgress(false, context);
          }, delayInMilli: 900);
          return;
        }
        if (!model.getBoolean(SIGN_UP_COMPLETE)) {
          model.put(SIGN_UP_COMPLETE, true);

          model.updateItems();
        }
        userName = model.getString(USERNAME);
        setState(() {});

        showProgress(false, context);
        pageController.animateToPage(3,
            duration: Duration(milliseconds: 800), curve: Curves.ease);
      });
    } on PlatformException catch (e) {
      showMessage(context, Icons.warning, Colors.red, "User Error!", e.message,
          clickYesText: "Try Again",
          cancellable: false,
          delayInMilli: 900, onClicked: (_) async {
        showProgress(false, context);
      });
    }
  }
}

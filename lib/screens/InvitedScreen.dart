import 'package:klippit/navigationUtils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klippit/base_module.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/backbone/NotifyEngine.dart';
import 'package:klippit/main.dart';

import 'RewardScreen.dart';

class InvitedScreen extends StatefulWidget {
  @override
  _InvitedScreenState createState() => _InvitedScreenState();
}

class _InvitedScreenState extends State<InvitedScreen> {
  var rewardController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              appBar(),
              Flexible(
                child: page(
                    index: 0,
                    title: "Did someone invite you \n with a reward code?",
                    hint: "Reward code (optional)",
                    controller: rewardController),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: buildBtmTitle(),
            ),
          )
        ],
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
      child: Container(
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
          ],
        ),
      ),
    );
  }

  buildBtmTitle() {
    return GestureDetector(
      onTap: () {
        goToWidget(context, RewardScreen());
      },
      child: Text(
        "What are reward codes?",
        style: textStyle(
          true,
          16,
          bgColor,
        ),
      ),
    );
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
                        color: bgColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          "APPLY",
                          style: textStyle(true, 15, white),
                        ),
                        onPressed: () {
                          checkReward();
                        }),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  checkReward() async {
    if (rewardController.text.isEmpty) {
      toast(scaffoldKey, "Please enter reward code");
      return;
    }

    showProgress(
      true,
      context,
      msg: "Verifying Code...",
    );

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

    if (ref.getString(INVITED_BY).isNotEmpty) {
      ref.put(INVITED_BY, userModel.getUId());
    }
    ref.putInList(REFERRALS, userModel.getUId(), true);
    ref.put(AMOUNT_EARNED, ref.getInt(AMOUNT_EARNED) + 1);
    ref.updateItems();

    userModel.put(IS_REFERRED, true);
    userModel.put(INVITED_BY, ref.getUId());
//    userModel.putInList(REFERRALS, ref.getUId(), true);
//    userModel.put(AMOUNT_EARNED, userModel.getInt(AMOUNT_EARNED) + 1);
    userModel.updateItems();

    //Handle the notification
    BaseModel bm = BaseModel();
    bm.put(TITLE, "You've just earned \$1!");
    bm.put(
        MESSAGE,
        "👏💸 ${userModel.getFullName()}"
        " signed up for Klippit using your ref code."
        "Keep going!");
    bm.put(TOKEN_ID, ref.getToken());
    NotifyEngine(context, bm, HandleType.outgoingNotification,
        notificationType: NotifyType.referral00);

    //print(ref.items);
    //print(ref.getToken());

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

    showProgress(false, context);
    showMessage(context, Icons.check, dark_green1, "Code Approved!",
        "You applied a reward code!",
        clickYesText: "Got it", cancellable: false, onClicked: (_) async {
      Navigator.pop(context);
    }, delayInMilli: 900);
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
          style: textStyle(true, 22, white),
        ),
        addSpace(15),
        Text(
          "REWARD CODE",
          textAlign: TextAlign.justify,
          style: textStyle(true, 14, white.withOpacity(.4)),
        ),
        addSpace(15),
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
                    color: white.withOpacity(.5),
                    style: BorderStyle.solid,
                    width: 2.0)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                    color: white.withOpacity(.5),
                    style: BorderStyle.solid,
                    width: 2.0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                    color: white.withOpacity(.5),
                    style: BorderStyle.solid,
                    width: 2.0)),
          ),
          onChanged: (newText) {},
        ),
      ],
    );
  }
}

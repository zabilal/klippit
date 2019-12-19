import 'package:klippit/base_module.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klippit/assets.dart';
import 'package:share/share.dart';

import 'Terms.dart';

class HowItWorks extends StatefulWidget {
  @override
  _HowItWorksState createState() => _HowItWorksState();
}

class _HowItWorksState extends State<HowItWorks> {
  var controller = ScrollController();
  double padding = 50;

  List<String> details = [
    "Klippit rewards you for inviting friends to join Klippit. Earn unlimited rewards!",
    "Everyone who signs up for Klippit gets an invite reward code to share. Yours is",
    "Share your code with friends by coping it or using the button below. "
        "They'll be invited to download and join Klippit.",
    "When a friend that is new to Klippit signs up using your link or code, you receive \$1.",
    "You can invite as many friends as you want. Keep sharing and keep earning!"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.addListener(() {
      if (controller != null && controller.position.pixels == 0) {
        setState(() {
          padding = 50;
        });
      } else {
        setState(() {
          padding = 20;
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //return Sliver
    return Scaffold(
      //backgroundColor: white,
      backgroundColor: bgColor,
      //appBar: appBar(),
      //body: page2(),
      body: page(),
    );
  }

  appBar() {
    /*   return AppBar(
      backgroundColor: white,
      elevation: .5,
      title: Text(
        "Your Earnings",
        style: textStyle(true, 18, textColor),
      ),
      iconTheme: IconThemeData(color: textColor),
    );*/
    return Container(
      color: white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BackButton(),
            Padding(
              padding: EdgeInsets.only(left: 25, right: 25),
              child: Text(
                "How it works",
                style: textStyle(true, 25, black),
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    child: addLine(4, btnColor.withOpacity(.2), 5, 10, 0, 10)),
                Flexible(child: addLine(4, Colors.yellow, 0, 10, 5, 10)),
              ],
            )
          ],
        ),
      ),
    );
  }

  page() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        appBar(),
        pageTop(),
      ],
    );
  }

  pageTop() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(15),
        color: white,
        child: LayoutBuilder(builder: (context, box) {
          return ListView(
            padding: EdgeInsets.all(0),
            children: [
              ...List.generate(details.length, (index) {
                String text = details[index];
                return Padding(
                  padding: EdgeInsets.only(
                      left: index == 0 ? 8 : 40, top: 8, bottom: 8, right: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${index > 0 ? "$index.  " : ""}$text",
                        style: textStyle(true, 18, black),
                      ),
                      if (index == 1) ...[
                        addSpace(10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.getData(userModel.getString(REWARD_CODE));
                            showMessage(
                                context,
                                Icons.check,
                                green_dark,
                                "Reward Copied",
                                "Reward code has been copied to clipboard.",
                                delayInMilli: 600);
                          },
                          child: DottedBorder(
                            dashPattern: [6, 3, 2, 3],
                            color: light_grey,
                            padding: EdgeInsets.all(6),
                            strokeWidth: 2,
                            radius: Radius.circular(15),
                            borderType: BorderType.RRect,
                            child: Text(
                              userModel.getString(REWARD_CODE),
                              style: textStyle(true, 25, black),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                );
              }),
              addSpace(10),
              RaisedButton(
                onPressed: () async {
                  await Share.share(
                    "Hey when you sign up for Klippit we both earn \$1."
                    "Register on Klippit with referal code ${userModel.getString(REWARD_CODE)}",
                  );
                },
                color: bgColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.all(15),
                child: Center(
                    child: Text(
                  "INVITE FRIENDS",
                  style: textStyle(true, 16, black),
                )),
              ),
              addSpace(15),
              GestureDetector(
                onTap: () {
                  goToWidget(context, TermsAndConditions());
                },
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: "See",
                        style: textStyle(true, 14, black.withOpacity(.4))),
                    TextSpan(
                        text: " Terms & Conditions ",
                        style: textStyle(true, 14, bgColor)),
                    TextSpan(
                        text: "for more details",
                        style: textStyle(true, 14, black.withOpacity(.4)))
                  ]),
                  textAlign: TextAlign.center,
                  style: textStyle(true, 16, black),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}

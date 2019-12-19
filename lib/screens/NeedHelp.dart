import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:url_launcher/url_launcher.dart';

import 'InvitedScreen.dart';

// ignore: must_be_immutable
class NeedHelp extends StatefulWidget {
  @override
  _NeedHelpState createState() => _NeedHelpState();
}

class _NeedHelpState extends State<NeedHelp> {
  int expand = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      //appBar: appBar(),
      body: page(),
    );
  }

  appBar() {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Need Help?",
                    style: textStyle(true, 25, black),
                  ),
                  GestureDetector(
                    onTap: () async {
                      const url =
                          'mailto:support@klippitapp.com?subject=I%20need%20help&body';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        print("Could not launch $url");
                      }
                    },
                    child: Text(
                      "Email us",
                      style: textStyle(true, 18, bgColor),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Flexible(
                    flex: 2,
                    child: addLine(4, btnColor.withOpacity(.2), 5, 10, 0, 0)),
                Flexible(child: addLine(4, Colors.yellow, 0, 10, 5, 0)),
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
        addSpace(8),
        GestureDetector(
          onTap: () {
            if (userModel.getBoolean(IS_REFERRED)) {
              showMessage(context, Icons.warning, Colors.red, "Referral Error!",
                  "You can only enter a referral code once",
                  clickYesText: "Ok", cancellable: true);

              return;
            }
            goToWidget(context, InvitedScreen());
          },
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Center(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: "Need to apply a ",
                      style: textStyle(true, 16, black)),
                  TextSpan(
                      text: "REWARD CODE",
                      style: textStyle(true, 16, white, underlined: true)),
                  TextSpan(text: "? ", style: textStyle(true, 16, black)),
                ]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  pageTop() {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(25),
        color: white,
        /*decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(150, 50),
              bottomRight: Radius.elliptical(150, 50),
            )),*/
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Container(
              color: white,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(5),
              child: Text(
                "FAQ",
                style: textStyle(true, 20, black),
              ),
            ),
            addSpace(10),
            faqItem(
                0,
                expand == 0,
                "How do referral rewards work?",
                "When you refer friends to join Klippit and they use "
                "your referral link, or code, to sign up, you earn \$1. "
                "The more friends that sign up with your code, the more money you earn",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }),
            addSpace(8),
            faqItem(
                2,
                expand == 2,
                "When do I get the reward money I've earned for referrals?",
                "You can see your referral rewards balance by logging into "
                "the Klippit mobile app. Your rewards money will be deposited "
                "into a virtual wallet within the Klippit Daily Deals app that "
                "is launching in the Spring. Klippit will notify you once we "
                "launch Klippit Daily Deals app in the Spring. From there, "
                "you can withdraw your funds from the wallet within that app.",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }),
            addSpace(8),
            faqItem(
                3,
                expand == 3,
                "How can I spend the reward I earned?",
                "After Klippit launches the “Klippit Daily Deals” app, "
                "you will be able to deposit your funds to a spending account of your choice.",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }),
            addSpace(8),
            faqItem(
                4,
                expand == 4,
                "Why do I need Klippit?",
                "Klippit is the only mobile app that turns your selfies into savings and cash."
                    " Next time you are about to take a food selfie, get paid for it!",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }, feedBack: true),
            addSpace(8),
            faqItem(
                5,
                expand == 5,
                "When will my Klippit account be ready to use?",
                "We are hard at work building the main features of Klippit Daily Deals. "
                "We expect to have your virtual wallet ready in early 2020. The Klippit "
                "team will notify you as soon as it’s ready!",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }, support: true),
            addSpace(8),
            faqItem(
                6,
                expand == 6,
                "How does the waitlist work?",
                "We will start onboarding users over the winter in limited capacity "
                "with a full commercial roll out early 2020. In Spring 2020 we will "
                "launch our corresponding app, Klippit Daily Deals.",
                onExpanded: (i) {
              setState(() {
                if (expand == i) {
                  expand = -1;
                  return;
                }

                expand = i;
              });
            }, support: true),
          ],
        ),
      ),
    );
  }

  faqItem(int p, bool expand, String title, String content,
      {onExpanded, bool feedBack = false, bool support = false}) {
    return GestureDetector(
      onTap: () {
        onExpanded(p);
      },
      child: Column(
        children: <Widget>[
          AnimatedContainer(
            child: Container(
              padding: EdgeInsets.all(15),
              color: transparent,
              /* decoration: BoxDecoration(
                  color: expand ? textColor.withOpacity(.1) : bgColor,
                  borderRadius: BorderRadius.circular(25)),*/
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      title,
                      style: textStyle(true, 18, black),
                    ),
                  ),
                  addSpaceWidth(4),
                  Icon(
                    expand ? Icons.remove_circle : Icons.add_circle,
                    color: expand ? blue6 : bgColor,
                  ),
                ],
              ),
            ),
            duration: Duration(milliseconds: 15),
          ),
          if (expand) ...[
            addSpace(10),
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                content,
                style: textStyle(
                  false,
                  18,
                  black,
                ),
              ),
            ),
            addSpace(10),
          ],
          addLine(2, light_grey, 15, 0, 15, 0)
        ],
      ),
    );
  }
}

import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class VerifiedInfluencers extends StatefulWidget {
  @override
  _VerifiedInfluencersState createState() => _VerifiedInfluencersState();
}

class _VerifiedInfluencersState extends State<VerifiedInfluencers> {
  var controller = ScrollController();
  double padding = 50;

  List<String> details = [
    "Being a Verified Influencer means that Klippit has confirmed "
        "your account is the authentic presence of a public figure. "
        "A Verified Influencer recieves higher commission payouts.",
    "Become a Verified Influencer",
    "Use your unique reward code"
        " to invite at least 10 friends to Klippit",
    "Follow us on social media"
  ];

  String instagramLink = "https://www.instagram.com/klippitcash/";
  String fbLink = "https://www.facebook.com/klippitapp";
  String uTubeLink = "https://www.youtube.com/channel/UCX3pBiW5RElNp1HdINjy9xQ";
  String twitterLink = "https://twitter.com/OfficialKlippit";
  String waitLink = "https://join.klippitapp.com/preview/e"
      "ab6a405a5e10d9099f67acfa28530c8/verifiedinfluencer/";

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
                "Verified Influencers",
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
                        "${index > 1 ? "${index - 1}.  " : ""}$text",
                        style: textStyle(true, index < 2 ? 18 : 15, black),
                      ),
                      if (index == 0) ...[
                        addSpace(15),
                        Image.asset(
                          verified_persons,
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                        )
                      ]
                    ],
                  ),
                );
              }),
              addSpace(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      launchURL(instagramLink);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(instagram), fit: BoxFit.cover)),
                    ),
                  ),
                  addSpaceWidth(5),
                  GestureDetector(
                    onTap: () async {
                      launchURL(fbLink);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(facebook), fit: BoxFit.cover)),
                    ),
                  ),
                  addSpaceWidth(5),
                  GestureDetector(
                    onTap: () async {
                      launchURL(uTubeLink);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(youtube), fit: BoxFit.cover)),
                    ),
                  ),
                  addSpaceWidth(5),
                  GestureDetector(
                    onTap: () async {
                      launchURL(twitterLink);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage(twitter), fit: BoxFit.cover)),
                    ),
                  ),
                ],
              ),
              addSpace(10),
              RaisedButton(
                onPressed: () async {
                  launchURL(waitLink);
                  /*await Share.share(
                    "Hey when you sign up for Klippit we both earn \$1."
                    "Register on Klippit with referal code ${userModel.getString(REWARD_CODE)}",
                  );*/
                },
                color: bgColor,
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                padding: EdgeInsets.all(15),
                child: Center(
                    child: Text(
                  "JOIN THE WAIT LIST",
                  style: textStyle(true, 16, black),
                )),
              ),
              addSpace(15),
              GestureDetector(
                onTap: () async {
                  launchURL(waitLink);
                  //goToWidget(context, TermsAndConditions());
                },
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: "Learn more about being a ",
                        style: textStyle(true, 14, black.withOpacity(.4))),
                    TextSpan(
                        text: " Verified Influencer ",
                        style: textStyle(true, 14, bgColor)),
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

  launchURL(String url) async {
    //const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
      //throw 'Could not launch $url';
    }
  }
}

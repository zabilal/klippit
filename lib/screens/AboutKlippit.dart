import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:url_launcher/url_launcher.dart';


class AboutKlippit extends StatefulWidget {
  @override
  _AboutKlippitState createState() => _AboutKlippitState();
}

class _AboutKlippitState extends State<AboutKlippit> {
  var controller = ScrollController();
  double padding = 50;

  List<BaseModel> bmList = [
    BaseModel()
      ..put(TITLE, "Discover")
      ..put(
          ABOUT_ME,
          "Find great deals on all "
          "the best stuff to eat, see and do near you and around the world.")
      ..put(IMAGE, discover),
    BaseModel()
      ..put(TITLE, "Post, Save, Earn")
      ..put(
          ABOUT_ME,
          "Save up to 90% on the things you need everyday just by posting"
          " or sharing. Get paid when you shop and dine at the places you visit every week.")
      ..put(IMAGE, post_save_earn),
    BaseModel()
      ..put(TITLE, "Influence - Earn 2x")
      ..put(ABOUT_ME,
          "Get paid when your followers shop and dine at the places you posted.")
      ..put(IMAGE, influence),
  ];

  String instagramLink = "https://www.instagram.com/klippitcash/";
  String fbLink = "https://www.facebook.com/klippitapp";
  String uTubeLink = "https://www.youtube.com/channel/UCX3pBiW5RElNp1HdINjy9xQ";
  String twitterLink = "https://twitter.com/OfficialKlippit";
  String waitLink =
      "https://join.klippitapp.com/preview/eab6a405a5e10d9099f67acfa28530c8/verifiedinfluencer/";

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
                "About Klippit",
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
              Text(
                "Turn your Selfies into Savings",
                style: textStyle(true, 20, black),
              ),
              addSpace(10),
              ...List.generate(bmList.length, (index) {
                BaseModel bm = bmList[index];
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bm.getString(TITLE),
                        style: textStyle(true, 25, bgColor),
                      ),
                      addSpace(10),
                      Text(
                        bm.getAboutUser(),
                        style: textStyle(false, 18, black.withOpacity(.6)),
                      ),
                      addSpace(10),
                      Image.asset(
                        bm.getImage(),
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                );
              }),
              addSpace(30),
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

import 'package:flutter/material.dart';
import 'package:klippit/base_module.dart';
import 'package:klippit/assets.dart';

class RewardScreen extends StatefulWidget {
  @override
  _RewardScreenState createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
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
                child: ListView(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  children: <Widget>[
                    Text(
                      "What are reward codes?",
                      textAlign: TextAlign.center,
                      style: textStyle(true, 24, white),
                    ),
                    addSpace(25),
                    Text(
    "Everyone who signs up for Klippit gets unique reward code to share with friends. Share your code to earn money when they sign up! Money that is earned will be able to be withdrawn when the Klippit Deals App (our accompanying daily deals app) becomes available in the Spring.",
                      textAlign: TextAlign.center,
                      style: textStyle(false, 18, white),
                    ),
                    addSpace(15),
                  ],
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: bgColor,
                padding: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  alignment: Alignment.center,
                  child: Text(
                    "Got it",
                    style: textStyle(true, 18, white),
                  ),
                ),
              ),
            ),
          )
        ],
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
                    Container(
                      width: 60,
                    )
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

import 'dart:async';

import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/backbone/AppEngine.dart';

/*class progressDialog extends StatefulWidget {
  String id;
  String message;
  bool cancelable;
  BuildContext context;

  progressDialog(id, {bool cancelable = false, message = ""}) {
    this.id = id;
    this.message = message;
    this.cancelable = cancelable;
  }

  @override
  _progressDialogState createState() {
    return _progressDialogState(id, message: message, cancelable: cancelable);
  }
}*/

class progressDialog extends StatelessWidget {
  String message;
  bool cancelable;
  BuildContext context;

  progressDialog({bool cancelable = false, message = ""}) {
    this.message = message;
    this.cancelable = cancelable;
  }

  void hideHandler() {
    Future.delayed(Duration(milliseconds: 1000), () {
      if (!showProgressLayout) {
        Navigator.pop(context);
        return;
      }

//      setState(() {
//      });
      //message = currentProgressText;

      hideHandler();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    hideHandler();

    return WillPopScope(
      child: Stack(fit: StackFit.expand, children: <Widget>[
        Container(
          color: black.withOpacity(.7),
        ),
        page()
      ]),
      onWillPop: () {
        if (cancelable) Navigator.pop(context);
      },
    );
  }

  page() {
    return GestureDetector(
      onTap: () {
        if (cancelable) Navigator.pop(context);
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: black.withOpacity(.8),
          ),
          Center(
              child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(15)),
          )),
          Center(
            child: Opacity(
              opacity: .3,
              child: Image.asset(
                ic_launcher,
                width: 20,
                height: 20,
              ),
            ),
          ),
          Center(
            child: CircularProgressIndicator(
              //value: 20,
              valueColor: AlwaysStoppedAnimation<Color>(light_green6),
              strokeWidth: 2,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: new Container(),
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  message,
                  style: textStyle(false, 15, white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

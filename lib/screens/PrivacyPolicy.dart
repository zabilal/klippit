import 'package:klippit/base_module.dart';
import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget {
  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  bool viewCreated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            appBar(),
            Flexible(
              child: new WebView(
                initialUrl: "https://join.klippitapp.com/privacyppolicy/",
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (_) async {
                  setState(() {
                    viewCreated = true;
                  });
                  print(await _.currentUrl());
                },
              ),
            ),
          ],
        );
      }),
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
              child: Text(
                "Privacy Policy",
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
}

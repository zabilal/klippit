import 'package:flutter/material.dart';
import 'package:klippit/assets.dart';
import 'package:klippit/base_module.dart';

class InfoDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
onTap: (){
  Navigator.pop(context);
},
      child: Material(
        color: black.withOpacity(.3),
        child: Container(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
              )
            ),
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset(
                  coins,
                  height: 50,
                  width: 100,
                ),
                addSpace(10),
                Text("Keep Stacking Your Coins!",
                    style: textStyle(true, 15, black)),
                addSpace(10),
                Text("After Klippit launches “Klippit Daily Deals” in the Spring, "
                    "your earnings will be transferred to that app. You will be able to "
                    "deposit your funds to a spending account of your choice!",
                    style: textStyle(false, 15, black.withOpacity(.7))),
                addSpace(10),
                RaisedButton(onPressed: (){ Navigator.pop(context);},
                    padding: EdgeInsets.all(15),
                    color: bgColor,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Center(child: Text("Ok got it!", style: textStyle(true, 16, white),)))
              ],

            ),
          ),
        ),
      ),
    );
  }
}

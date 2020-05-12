import 'dart:developer';

import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 20),
      color: Colors.transparent,
      alignment: Alignment(-1, -1),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          foregroundColor: Colors.white,
          radius: 20,
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
    );
  }
}

class HollowSocialButton extends StatelessWidget {
  final String label;
  final img;
  final Function onPress;
  HollowSocialButton({this.label, this.img, this.onPress});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPress,
      child: Container(
        height: 50.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black, style: BorderStyle.solid, width: 1.0),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: img,
              ),
              SizedBox(width: 10.0),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

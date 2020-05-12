import 'package:flutter/material.dart';

const kTextFieldDecoration = InputDecoration(
  labelText: 'Label Text',
  labelStyle: TextStyle(
      fontFamily: 'Montserrat',
      fontWeight: FontWeight.bold,
      color: Colors.grey),
  focusedBorder:
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
  focusColor: Colors.lightBlue,
);

const kLinkTextStyle = TextStyle(
    color: Colors.green,
    fontWeight: FontWeight.bold,
    fontFamily: 'Montserrat',
    decoration: TextDecoration.underline);

//const kAppTheme = Theme( // TODO Make app wide theme
//);

const kBigTextStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: Colors.green,
);

const kSmallTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.black38,
  fontWeight: FontWeight.w600,
);

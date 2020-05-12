import 'package:flutter/material.dart';
import '../constants.dart';

class MyFormField extends StatelessWidget {
  final String name;
  final bool required;
  final bool obscureText;
  final Function callback;
  final keyboardType;
  MyFormField(
      {this.name,
      this.required = false,
      this.callback,
      this.obscureText = false,
      this.keyboardType});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: (value) {
        if (required && value.isEmpty) {
          return 'This field cannot be left blank';
        } else {
          callback(value);
          return null;
        }
      },
      decoration: kTextFieldDecoration.copyWith(labelText: name),
    );
  }
}

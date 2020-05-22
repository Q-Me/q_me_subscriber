// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

Users usersFromJson(String str) => Users.fromJson(json.decode(str));

String usersToJson(Users data) => json.encode(data.toJson());

class Users {
  List<User> user;

  Users({
    this.user,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        user: List<User>.from(json["user"].map((x) => User.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "user": List<dynamic>.from(user.map((x) => x.toJson())),
      };
}

class User {
  String userId;
  String firstName;
  String lastName;
  String email;
  String phone;
  int tokenNo;

  User({
    this.userId,
    @required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.tokenNo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final splitName = json["name"].split("|");
    return User(
      userId: json["user_id"],
      firstName: splitName[0],
      lastName: splitName.length > 1 ? splitName[1] : null,
      email: json["email"],
      phone: json["phone"],
      tokenNo: json["token_no"],
    );
  }

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": firstName,
        "email": email,
        "phone": phone,
        "token_no": tokenNo,
      };
}

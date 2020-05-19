// To parse this JSON data, do
//
//     final users = usersFromJson(jsonString);

import 'dart:convert';

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
  String name;
  String email;
  String phone;
  int tokenNo;

  User({
    this.userId,
    this.name,
    this.email,
    this.phone,
    this.tokenNo,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        tokenNo: json["token_no"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "name": name,
        "email": email,
        "phone": phone,
        "token_no": tokenNo,
      };
}

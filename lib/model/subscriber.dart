// To parse this JSON data, do
//
//     final subscriber = subscriberFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/cupertino.dart';

Subscriber subscriberFromJson(String str) =>
    Subscriber.fromJson(json.decode(str));

String subscriberToJson(Subscriber data) => json.encode(data.toJson());

class Subscriber {
  String name;
  String owner;
  String email;
  String phone;
  String password;
  String address;

  Subscriber({
    this.name,
    this.owner,
    @required this.email,
    this.phone,
    this.password,
    this.address,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) => Subscriber(
        name: json["name"],
        owner: json["owner"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "password": password,
        "address": address,
      };
}

// To parse this JSON data, do
//
//     final subscriber = subscriberFromJson(jsonString);

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

Subscriber subscriberFromJson(String str) =>
    Subscriber.fromJson(json.decode(str));

String subscriberToJson(Subscriber data) => json.encode(data.toJson());

class Subscriber {
  String id;
  String name;
  String owner;
  String email;
  String phone;
  String accessToken;
  String refreshToken;
  String address;

  Subscriber({
    this.id,
    this.name,
    this.owner,
    this.email,
    this.phone,
    this.accessToken,
    this.refreshToken,
    this.address,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) => Subscriber(
        id: json['id'],
        name: json["name"],
        owner: json["owner"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "address": address,
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

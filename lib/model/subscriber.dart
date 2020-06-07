import 'dart:convert';

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
  String category;
  double latitude;
  double longitude;
  int verified;
  DateTime tokenExpiry;

  Subscriber({
    this.id,
    this.name,
    this.owner,
    this.email,
    this.phone,
    this.accessToken,
    this.refreshToken,
    this.address,
    this.latitude,
    this.longitude,
    this.verified,
    this.tokenExpiry,
    this.category,
  });

  factory Subscriber.fromJson(Map<String, dynamic> json) => Subscriber(
        id: json['id'],
        name: json["name"],
        owner: json["owner"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        latitude:
            json["latitude"] != null ? double.parse(json["latitude"]) : null,
        longitude:
            json["longitude"] != null ? double.parse(json["longitude"]) : null,
        verified: json["verified"] == 'true' ? 1 : 0,
        category: json["category"],
        accessToken: json['accessToken'],
        tokenExpiry: json["tokenExpiry"] != null
            ? DateTime.parse(json["tokenExpiry"])
            : null,
        refreshToken: json['refreshToken'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "owner": owner,
        "email": email,
        "phone": phone,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "verified": verified == 1 ? true : false,
        "category": category,
        "tokenExpiry": tokenExpiry.toString(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

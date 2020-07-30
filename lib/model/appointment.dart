// To parse this JSON data, do
//
//     final slots = slotsFromJson(jsonString);

import 'package:meta/meta.dart';

class Appointment {
  Appointment({
    @required this.startTime,
    @required this.endTime,
    @required this.status,
    this.note,
    @required this.bookedBy,
    @required this.customerName,
    @required this.customerPhone,
  });

  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String note;
  final String bookedBy;
  final String customerName;
  final String customerPhone;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        startTime: DateTime.parse(json["starttime"]).toLocal(),
        endTime: DateTime.parse(json["endtime"]).toLocal(),
        status: json["status"],
        note: json["note"],
        bookedBy: json["booked_by"],
        customerName: json["cust_name"],
        customerPhone: json["cust_phone"],
      );

  Map<String, dynamic> toJson() => {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "status": status,
        "note": note,
        "booked_by": bookedBy,
        "cust_name": customerName,
        "cust_phone": customerPhone,
      };
}

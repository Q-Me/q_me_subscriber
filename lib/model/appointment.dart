// To parse this JSON data, do
//
//     final slots = slotsFromJson(jsonString);

import 'package:meta/meta.dart';

class Appointment {
  Appointment(
      {@required this.startTime,
      @required this.endTime,
      @required this.status,
      this.note,
      @required this.bookedBy,
      @required this.customerName,
      @required this.customerPhone,
      this.otp});

  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String note;
  final String bookedBy;
  final String customerName;
  final String customerPhone;
  int otp;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        startTime: DateTime.parse(json["starttime"]),
        endTime: DateTime.parse(json["endtime"]),
        status: json["status"],
        note: json["note"],
        bookedBy: json["booked_by"],
        customerName: json["cust_name"],
        customerPhone: json["cust_phone"],
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "status": status,
        "note": note,
        "booked_by": bookedBy,
        "cust_name": customerName,
        "cust_phone": customerPhone,
        "otp": otp
      };
}

final jsonTestString = {
  "slots": [
    {
      "starttime": "2020-08-13T09:00:00.000Z",
      "endtime": "2020-08-13T10:00:00.000Z",
      "status": "CANCELLED BY SUBSCRIBER",
      "note": "A",
      "booked_by": "SUBSCRIBER",
      "cust_name": "A",
      "cust_phone": "+911234567890"
    },
    {
      "starttime": "2020-08-13T09:00:00.000Z",
      "endtime": "2020-08-13T10:00:00.000Z",
      "status": "DONE",
      "note": "b",
      "booked_by": "SUBSCRIBER",
      "cust_name": "b",
      "cust_phone": "+919874563210"
    },
    {
      "starttime": "2020-08-13T09:00:00.000Z",
      "endtime": "2020-08-13T10:00:00.000Z",
      "status": "UPCOMING",
      "note": "8445",
      "booked_by": "SUBSCRIBER",
      "cust_name": "c",
      "cust_phone": "+919856321470"
    }
  ]
};

List<Appointment> filterAppointmentsByStatus(
    List<Appointment> appointments, String status) {
  return appointments
      .where((appointment) => appointment.status == status)
      .toList();
}

void logList(List<Appointment> appointments) {
  for (int i = 0; i < appointments.length; i++) {
    print(appointments[i].toJson());
  }
}

void main() {
  List<Appointment> appointments = [];
  for (var appointmentElement in jsonTestString["slots"]) {
    appointments.add(
      Appointment.fromJson(Map<String, dynamic>.from(appointmentElement)),
    );
  }
  print(filterAppointmentsByStatus(appointments, "UPCOMING")[0].toJson());
}

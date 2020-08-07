import 'dart:collection';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';

import 'appointment.dart';

// ignore: must_be_immutable
class Slot extends Equatable with ChangeNotifier {
  Slot({
    @required this.startTime,
    @required this.endTime,
    this.booked,
    this.customersInSlot,
  });

  List<Appointment> appointments = [];
  Duration get duration => endTime.difference(startTime);

  void addAppointment(Appointment appointment) {
    appointments.add(appointment);
  }

  final DateTime startTime;
  final DateTime endTime;
  int booked; // null means not set
  int customersInSlot;

  factory Slot.fromJson(Map<String, dynamic> json) => Slot(
        startTime: DateTime.parse(json["starttime"]).toLocal(),
        endTime: DateTime.parse(json["endtime"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "cust_per_slot": customersInSlot,
        "booked": booked,
      };

  @override
  List<Object> get props => [startTime, endTime, customersInSlot, booked];
}

List<Slot> appointmentSlots(Map<String, List<Map<String, String>>> thisJson) {
  SplayTreeSet<Slot> slots = SplayTreeSet<Slot>(
    Comparing.on((slot) => slot.startTime),
  );

  var slotList = thisJson['slots'].map((e) {
    Slot slot = Slot.fromJson(e);
    Appointment appointment = Appointment.fromJson(e);

    // check if slot exists in slots
//    if (slots.contains(slot)) {
//      // TODO find the slot in slots that has the same time
//
//      return null;
//    } else {
    print('Slot:${slot.toJson()}\nAppointment:${appointment.toJson()}');
    slot.addAppointment(appointment);
    return slot;
//    }
  }).toList();
  return slotList;
}

void main() {
  final a = Slot.fromJson(json.decode('''
  {
  "starttime": "2020-06-29T15:00:00.000Z",
  "endtime": "2020-06-29T15:15:00.000Z"
  }'''));
  final b = Slot.fromJson(json.decode('''
  {
    "starttime": "2020-06-29T15:15:00.000Z",
    "endtime": "2020-06-29T15:30:00.000Z"
  }'''));

  SplayTreeSet<Slot> newSet =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));
  newSet.add(Slot.fromJson(json.decode('''
  {
    "starttime": "2020-06-29T15:30:00.000Z",
    "endtime": "2020-06-29T15:45:00.000Z"
  }''')));
  newSet.add(a);
  newSet.add(b);
  newSet.add(a);
  newSet.add(a);
//  for (Slot slot in newSet.toList()) {
//    print(slot.toJson());
//  }

  Map<String, List<Map<String, String>>> mysJson = {
    "slots": [
      {
        "starttime": "2020-06-29T15:00:00.000Z",
        "endtime": "2020-06-29T15:15:00.000Z",
        "status": "CANCELLED",
        "note": "",
        "booked_by": "USER",
        "cust_name": "Kavya2",
        "cust_phone": "9898009900"
      },
      {
        "starttime": "2020-06-29T15:00:00.000Z",
        "endtime": "2020-06-29T15:15:00.000Z",
        "status": "UPCOMING",
        "note": "",
        "booked_by": "Piyush",
        "cust_name": "Piyush",
        "cust_phone": "9673582517"
      },
      {
        "starttime": "2020-06-29T17:00:00.000Z",
        "endtime": "2020-06-29T17:15:00.000Z",
        "status": "CANCELLED",
        "note": "",
        "booked_by": "USER",
        "cust_name": "Kavya2",
        "cust_phone": "9898009900"
      },
      {
        "starttime": "2020-06-29T15:00:00.000Z",
        "endtime": "2020-06-29T15:15:00.000Z",
        "status": "UPCOMING",
        "note": "",
        "booked_by": "USER",
        "cust_name": "Kavya2",
        "cust_phone": "9898009900"
      }
    ]
  };
  for (Slot slot in appointmentSlots(mysJson).toList()) {
    print('Slot:${slot.toJson()}');
    for (Appointment appointment in slot.appointments) {
      print(appointment.toJson());
    }
    print('');
  }
}

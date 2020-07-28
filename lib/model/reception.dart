import 'dart:collection';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:ordered_set/comparing.dart';
import 'package:qme_subscriber/controllers/slots.dart';
import 'package:qme_subscriber/model/slot.dart';

import '../model/slot.dart';

Reception receptionFromJson(String str) => Reception.fromJson(json.decode(str));

String receptionToJson(Reception data) => json.encode(data.toJson());

class Reception {
  Reception({
    @required this.receptionId,
    @required this.subscriberId,
    @required this.startTime,
    @required this.endTime,
    @required this.slotDuration,
    @required this.customersInSlot,
    @required this.status,
  }) {
    this.addSlotList(createSlotsFromDuration(this));
  }

  final String receptionId;
  final String subscriberId;
  final DateTime startTime;
  final DateTime endTime;
  final Duration slotDuration;
  final int customersInSlot;
  final String status;
  SplayTreeSet<Slot> _slots =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));

  List<Slot> get slotList => _slots.toList();

  addSlot(Slot slot) => _slots.add(slot);

  addSlotList(List<Slot> slots) => _slots.addAll(slots);

  modifyBookings() {}

  factory Reception.fromJson(Map<String, dynamic> json) => Reception(
        receptionId: json["id"],
        subscriberId: json["subscriber_id"],
        startTime: DateTime.parse(json["starttime"]).toLocal(),
        endTime: DateTime.parse(json["endtime"]).toLocal(),
        slotDuration: Duration(minutes: json["slot"]),
        customersInSlot: json["cust_per_slot"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": receptionId,
        "subscriber_id": subscriberId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "slot": slotDuration.inMinutes,
        "cust_per_slot": customersInSlot,
        "status": status,
      };
}

Schedule scheduleFromMap(String str) => Schedule.fromMap(json.decode(str));

String scheduleToMap(Schedule data) => json.encode(data.toMap());

class Schedule {
  Schedule({
    @required this.starttime,
    @required this.endtime,
    @required this.slot,
    @required this.custPerSlot,
    @required this.daysOfWeek,
    @required this.repeatTill,
  });

  final String starttime;
  final String endtime;
  final String slot;
  final String custPerSlot;
  final List<int> daysOfWeek;
  final DateTime repeatTill;

  Schedule copyWith({
    String starttime,
    String endtime,
    String slot,
    String custPerSlot,
    List<int> daysOfWeek,
    DateTime repeatTill,
  }) =>
      Schedule(
        starttime: starttime ?? this.starttime,
        endtime: endtime ?? this.endtime,
        slot: slot ?? this.slot,
        custPerSlot: custPerSlot ?? this.custPerSlot,
        daysOfWeek: daysOfWeek ?? this.daysOfWeek,
        repeatTill: repeatTill ?? this.repeatTill,
      );

  factory Schedule.fromMap(Map<String, dynamic> json) => Schedule(
        starttime: json["starttime"] == null ? null : json["starttime"],
        endtime: json["endtime"] == null ? null : json["endtime"],
        slot: json["slot"] == null ? null : json["slot"],
        custPerSlot:
            json["cust_per_slot"] == null ? null : json["cust_per_slot"],
        daysOfWeek: json["daysOfWeek"] == null
            ? null
            : List<int>.from(json["daysOfWeek"].map((x) => x)),
        repeatTill: json["repeatTill"] == null
            ? null
            : DateTime.parse(json["repeatTill"]),
      );

  Map<String, dynamic> toMap() => {
        "starttime": starttime == null ? null : starttime,
        "endtime": endtime == null ? null : endtime,
        "slot": slot == null ? null : slot,
        "cust_per_slot": custPerSlot == null ? null : custPerSlot,
        "daysOfWeek": daysOfWeek == null
            ? null
            : List<dynamic>.from(daysOfWeek.map((x) => x)),
        "repeatTill": repeatTill == null ? null : repeatTill.toIso8601String(),
      };
}

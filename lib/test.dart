import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/utilities/logger.dart';

String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InlzenY3OW5ucSIsIm5hbWUiOiJBbWFuZGVlcCdzIFNhbG9vbiIsImlzU3Vic2NyaWJlciI6dHJ1ZSwiaWF0IjoxNTkzODY4ODc1LCJleHAiOjE1OTM5NTUyNzV9.1B1NKAgQw_KuXvia5yFJ9cDa7sjiiHbeHK0tqJkc1oc';
String jsonString = '''
{
    "counter": {
        "id": "Iqh52Qtji",
        "subscriber_id": "17dY6K8Hb",
        "starttime": "2020-06-29T15:00:00.000Z",
        "endtime": "2020-06-29T19:00:00.000Z",
        "slot": 15,
        "cust_per_slot": 4,
        "status": "UPCOMING"
    },
    "slots": [
        {
            "starttime": "2020-06-29T15:00:00.000Z",
            "count": 3
        },
        {
            "starttime": "2020-06-29T17:00:00.000Z",
            "count": 1
        },
        {
            "starttime": "2020-06-29T15:15:00.000Z",
            "count": 1
        },
        {
            "starttime": "2020-06-29T15:30:00.000Z",
            "count": 1
        }
    ],
    "overrides": [
        {
            "counter_id": "Iqh52Qtji",
            "starttime": "2020-06-29T16:00:00.000Z",
            "endtime": "2020-06-29T17:00:00.000Z",
            "override": 1
        },
        {
            "counter_id": "Iqh52Qtji",
            "starttime": "2020-06-29T18:00:00.000Z",
            "endtime": "2020-06-29T19:00:00.000Z",
            "override": 0
        }
    ]
}
''';
/*

List<Slot> createSlotsFromDuration(Reception reception) {
  List<Slot> slots = [];
  for (int i = 0;
      i < reception.endTime.difference(reception.startTime).inMinutes;
      i += reception.slotDuration.inMinutes) {
    slots.add(
      Slot(
        startTime: reception.startTime.add(Duration(minutes: i)),
        endTime: reception.startTime
            .add(Duration(minutes: i + reception.slotDuration.inMinutes)),
        customersInSlot: reception.customersInSlot,
      ),
    );
  }
  return slots;
}

List<Slot> createOverrideSlots(Map<String, dynamic> response) {
  List<Slot> overrideList = [];
  for (var map in response['overrides']) {
    final Slot override = Slot(
      startTime: DateTime.parse(map['starttime']).toLocal(),
      endTime: DateTime.parse(map['endtime']).toLocal(),
      customersInSlot: map['override'],
    );
    overrideList.add(override);
    print('Override:${override.toJson()}');
  }
  SplayTreeSet<Slot> overrides =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));
  overrides.addAll(overrideList);
  return overrides.toList();
}

List<Slot> overrideSlots(List<Slot> slots, List<Slot> overrideList) {
  int i = 0;
  for (int j = 0; j < overrideList.length; j++) {
    Slot currentOverrideSlot = overrideList[j];
    print('\nOverride Slot:${currentOverrideSlot.toJson()}');
    // find a slot that starts at current override start time
    while (i < slots.length &&
        (!(slots[i].startTime.isAfter(currentOverrideSlot.startTime) ||
            slots[i]
                .startTime
                .isAtSameMomentAs(currentOverrideSlot.startTime)))) {
      i++;
    }
    print('Starting to update or delete from here: ${slots[i].toJson()}');
    // Keep updating the slots according to override
    while (i < slots.length &&
        (currentOverrideSlot.endTime.isAfter(slots[i].endTime) ||
            currentOverrideSlot.endTime.isAtSameMomentAs(slots[i].endTime))) {
      slots[i].customersInSlot = currentOverrideSlot.customersInSlot;
      if (currentOverrideSlot.customersInSlot == 0) {
        print('Deleting:${slots[i].toJson()}');
        slots.removeAt(i);
        continue;
      } else {
        print('Updating:${slots[i].toJson()}');
      }
      i++;
    }
  }
  return slots;
}

List<Slot> modifyBookings(List<Slot> slots, Map<String, dynamic> response) {
  List bookings = response['slots'];
//  bookings.sort((a, b) => a['starttime'].compareTo(b)['starttime']);
  // Go through the booked appointments and add them in the slot's appointment list
  for (var map in bookings) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i]
          .startTime
          .isAtSameMomentAs(DateTime.parse(map['starttime']).toLocal())) {
        slots[i].booked = map['count'];
        print('Booked:${slots[i].toJson()}');
      }
    }
  }
  return slots;
}
*/

//void main() {
//  Map<String, dynamic> resJson = json.decode(jsonString);
//  final start = DateTime.now();
//  Reception reception = Reception.fromJson(resJson['counter']);
//  print('Receptions:${reception.toJson()}\n');
//
//  // Create slots from from window, slot duration
//  List<Slot> slots = createSlotsFromDuration(reception);
////  for (int i = 0;
////      i < reception.endTime.difference(reception.startTime).inMinutes;
////      i += reception.slotDuration.inMinutes) {
////    slots.add(
////      Slot(
////        startTime: reception.startTime.add(Duration(minutes: i)),
////        endTime: reception.startTime
////            .add(Duration(minutes: i + reception.slotDuration.inMinutes)),
////        customersInSlot: reception.customersInSlot,
////      ),
////    );
////  }
//  print('\nSlots:${slots.length}');
//  for (Slot slot in slots) {
//    print('Slot:${slot.toJson()}');
//  }
//
////  /* Remove slots from override*/
//  // Create override list
//  List<Slot> overrideList = createOverrideSlots(resJson);
////  for (var map in resJson['overrides']) {
////    final Slot override = Slot(
////      startTime: DateTime.parse(map['starttime']).toLocal(),
////      endTime: DateTime.parse(map['endtime']).toLocal(),
////      customersInSlot: map['override'],
////    );
////    overrideList.add(override);
////    print('Override:${override.toJson()}');
////  }
////  print('');
//
//  // Sort override slots according to startTime
////  SplayTreeSet<Slot> overrides =
////      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));
////  overrides.addAll(overrideList);
////  overrideList = overrides.toList();
//
//  // update or remove slots according to overrides
//  slots = overrideSlots(slots, overrideList);
////  int i = 0;
////  for (int j = 0; j < overrideList.length; j++) {
////    Slot currentOverrideSlot = overrideList[j];
////    print('\nOverride Slot:${currentOverrideSlot.toJson()}');
////    // find a slot that starts at current override start time
////    while (i < slots.length &&
////        (!(slots[i].startTime.isAfter(currentOverrideSlot.startTime) ||
////            slots[i]
////                .startTime
////                .isAtSameMomentAs(currentOverrideSlot.startTime)))) {
////      i++;
////    }
////    print('Starting to update or delete from here: ${slots[i].toJson()}');
////    // Keep updating the slots according to override
////    while (i < slots.length &&
////        (currentOverrideSlot.endTime.isAfter(slots[i].endTime) ||
////            currentOverrideSlot.endTime.isAtSameMomentAs(slots[i].endTime))) {
////      slots[i].customersInSlot = currentOverrideSlot.customersInSlot;
////      if (currentOverrideSlot.customersInSlot == 0) {
////        print('Deleting:${slots[i].toJson()}');
////        slots.removeAt(i);
////        continue;
////      } else {
////        print('Updating:${slots[i].toJson()}');
////      }
////      i++;
////    }
////  }
//
//  // TODO optimize sort the bookings according to their start time
////  List bookings = resJson['slots'];
//  slots = modifyBookings(slots, resJson);
//////  bookings.sort((a, b) => a['starttime'].compareTo(b)['starttime']);
////  // Go through the booked appointments and add them in the slot's appointment list
////  for (var map in bookings) {
////    for (int i = 0; i < slots.length; i++) {
////      if (slots[i]
////          .startTime
////          .isAtSameMomentAs(DateTime.parse(map['starttime']).toLocal())) {
////        slots[i].booked = map['count'];
////        print('Booked:${slots[i].toJson()}');
////      }
////    }
////  }
//  print('time to calsulate:${DateTime.now().difference(start).inMilliseconds}');
//  print('\nSlots:${slots.length}');
//  for (Slot slot in slots) {
//    print('Slot:${slot.toJson()}');
//  }
////  print(reception.toJson());
//}

void main() {
  /* final response = json.decode(jsonString);

  var slots = createSlotsFromDuration(Reception.fromJson(response["counter"]));
  final overrides = createOverrideSlots(response);
  slots = overrideSlots(slots, overrides);
  slots = modifyBookings(slots, response);
  print('\nSlots:${slots.length}');
  for (Slot slot in slots) {
    print('Slot:${slot.toJson()}');
  }*/
  ReceptionRepository receptionRepository = ReceptionRepository();
  testViewReceptionsByStatus(receptionRepository);
//  testViewReception();
//  ReceptionRepository receptionRepository = ReceptionRepository();
//  receptionRepository.viewReception(counterId: null, accessToken: null)
//  createOverrideReception(receptionRepository);
}

void createOverrideReception(ReceptionRepository receptionRepository) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day + 1);

  final response = await receptionRepository.createOverrideSlot(
    counterId: 'f55cNXCtP',
    startTime: today.add(Duration(hours: 10)),
    endTime: today.add(Duration(hours: 14)),
    customerPerSlotOverride: 0,
    accessToken: accessToken,
  );
  print(response.toString());
}

void testCreateReception(ReceptionRepository receptionRepository) async {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day + 1);
  final response = await receptionRepository.createReception(
    startTime: today.add(Duration(hours: 10)),
    endTime: today.add(Duration(hours: 18)),
    slotDurationInMinutes: 15,
    customerPerSlot: 5,
    accessToken: accessToken,
  );
  print('Create Reception response:' + response.toString());
}

void testViewReception(ReceptionRepository receptionRepository) async {
  Reception reception = await receptionRepository.viewReception(
      counterId: 'f55cNXCtP', accessToken: accessToken);
  print(reception.toJson());
}

void testViewReceptionsByStatus(ReceptionRepository receptionRepository) async {
  List<Reception> receptions = await receptionRepository
      .viewReceptionsByStatus(status: ['ALL'], accessToken: accessToken);
  for (Reception reception in receptions) {
    logger.i(reception.toJson());
  }
}

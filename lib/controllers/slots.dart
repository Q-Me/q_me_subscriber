import 'dart:collection';

import 'package:ordered_set/comparing.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';

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

List<Slot> orderSlotsByStartTime(List<Slot> slots) {
  SplayTreeSet<Slot> overrides =
      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));
  overrides.addAll(slots);
  return overrides.toList();
}

List<Slot> createOverrideSlots(Map<String, dynamic> response) {
  assert(response['overrides'] == null, 'No override in response');

  List<Slot> overrideList = [];
  for (var map in response['overrides']) {
    final Slot override = Slot(
      startTime: DateTime.parse(map['starttime']).toLocal(),
      endTime: DateTime.parse(map['endtime']).toLocal(),
      customersInSlot: map['override'],
    );
    overrideList.add(override);
//    log('Override:${override.toJson()}');
  }
//  SplayTreeSet<Slot> overrides =
//      SplayTreeSet<Slot>(Comparing.on((slot) => slot.startTime));
//  overrides.addAll(overrideList);
  return orderSlotsByStartTime(overrideList);
}

List<Slot> overrideSlots(List<Slot> slots, List<Slot> overrideList) {
  int i = 0;
  for (int j = 0; j < overrideList.length; j++) {
    Slot currentOverrideSlot = overrideList[j];
//    log('\nOverride Slot:${currentOverrideSlot.toJson()}');
    // find a slot that starts at current override start time
    while (i < slots.length &&
        (!(slots[i].startTime.isAfter(currentOverrideSlot.startTime) ||
            slots[i]
                .startTime
                .isAtSameMomentAs(currentOverrideSlot.startTime)))) {
      i++;
    }
//    log('Starting to update or delete from here: ${slots[i].toJson()}');
    // Keep updating the slots according to override
    while (i < slots.length &&
        (currentOverrideSlot.endTime.isAfter(slots[i].endTime) ||
            currentOverrideSlot.endTime.isAtSameMomentAs(slots[i].endTime))) {
      slots[i].customersInSlot = currentOverrideSlot.customersInSlot;
      if (currentOverrideSlot.customersInSlot == 0) {
//        log('Deleting:${slots[i].toJson()}');
        slots.removeAt(i);
        continue;
      } else {
//        log('Updating:${slots[i].toJson()}');
      }
      i++;
    }
  }
  return slots;
}

List<Slot> modifyBookings(List<Slot> slots, List bookings) {
  assert(bookings != null, "bookings list cannot be null");
//  assert(response['slots'] == null, 'no slot bookings');
//  List bookings = response['slots'];
//  bookings.sort((a, b) => a['starttime'].compareTo(b)['starttime']);
  // Go through the booked appointments and add them in the slot's appointment list
  for (var map in bookings) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i]
          .startTime
          .isAtSameMomentAs(DateTime.parse(map['starttime']).toLocal())) {
        slots[i].upcoming = map['count'];
//        logger.d('${slots[i].toJson()}');
      } else {
        slots[i].upcoming = 0;
      }
    }
  }
  return slots;
}

List<Slot> modifyDoneSlots(List<Slot> slots, List bookings) {
  assert(bookings != null);

  for (var map in bookings) {
    for (int i = 0; i < slots.length; i++) {
      if (slots[i]
          .startTime
          .isAtSameMomentAs(DateTime.parse(map['starttime']).toLocal())) {
        slots[i].upcoming = map['count'];
//        logger.d('${slots[i].toJson()}');
      } else {
        slots[i].done = 0;
      }
    }
  }
  return slots;
}

import 'dart:math';

import 'package:qme_subscriber/model/appointment.dart';

final String accessToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imc2N2VVTW84bCIsIm5hbWUiOiJQaXl1c2ggU2Fsb29uIiwiaXNTdWJzY3JpYmVyIjp0cnVlLCJpYXQiOjE1OTcyNDYyMTMsImV4cCI6MTU5NzMzMjYxM30.l4W8jTjWYm94lMSvq0OslFrZ_TbaX_pMUZKnTd5sIuU';
/*void main() async {
  final _helper = ApiBaseHelper();
  final response = await _helper.post(
    "/subscriber/slot/viewcounterdetailed",
    req: {"counter_id": "s3zvlYdLQ"},
    headers: {'Authorization': 'Bearer $accessToken'},
  );
  // Create Reception
  Reception reception = Reception.fromJson(response["counter"]);

  // create slots from reception duration
  List<Slot> slots = reception.slotList;

  final List overrideResponse = response['overrides'];
  if (overrideResponse != null &&
      overrideResponse is List &&
      overrideResponse.length != 0) {
    // apply overrides slots
    slots = overrideSlots(slots, createOverrideSlots(response));
  }

  // TODO Handle slot_done
  final List bookedSlots = response['slots_upcoming'];
  if (bookedSlots != null &&
      bookedSlots is List &&
      bookedSlots.length != null) {
    // update slots according to bookings
    slots = modifyBookings(slots, bookedSlots);

    // TODO Update done slots
//      slots = modifyDoneSlots

  }
  final List doneSlots = response['slots_done'];
  if (doneSlots != null && doneSlots is List && doneSlots.length != null) {
    slots = modifyDoneSlots(slots, doneSlots);
  }
  print(slots[0].toJson());
  print(slots[1].toJson());
  reception.replaceSlots(slots);
  reception.toJson();
}*/

void printList(List<Appointment> appointments) {
  for (int i = 0; i < appointments.length; i++) {
    print(appointments[i].toJson());
  }
}

void main() {
  Random random = Random();
  final List<String> statuses = [
    'UPCOMING',
    'CANCELLED',
    'CANCELLED BY SUBSCRIBER',
    'DONE'
  ];
  final now = DateTime.now();
  final DateTime start = DateTime(now.year, now.month, now.day, now.hour);
  final DateTime end = start.add(Duration(hours: 1));
  List<Appointment> appointments = List.generate(
    5,
    (index) => Appointment(
      startTime: start,
      endTime: end,
      status: statuses[random.nextInt(statuses.length - 1)],
      otp: random.nextInt(9999),
    ),
  );

  final String status = "UPCOMING";
  List<Appointment> filtered = filterAppointmentsByStatus(
    appointments,
    status,
  );
  print('Full List');
  printList(appointments);
  print("\nFiltering $status}");
  printList(filtered);
}

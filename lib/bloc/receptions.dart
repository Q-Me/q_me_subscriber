import 'package:flutter/widgets.dart';
import 'package:qme_subscriber/controllers/slots.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/time.dart';

class ReceptionsBloc extends ChangeNotifier {
  String _subscriberId;
  List<Reception> receptions = [];
  Reception reception = Reception(
    subscriberId: '',
    customersInSlot: 4,
    receptionId: '',
    status: 'UPCOMING',
    startTime: DateTime(2020, 7, 25, 9),
    endTime: DateTime(2020, 7, 25, 18),
    slotDuration: Duration(minutes: 30),
  );
  Map<String, dynamic> response = {
    "slots": [
      {
        "starttime": DateTime(2020, 7, 25, 9)
            .add(Duration(hours: 5, minutes: 30))
            .toIso8601String(),
        "count": 2
      },
      {
        "starttime": DateTime(2020, 7, 25, 9)
            .add(Duration(hours: 6, minutes: 30))
            .toIso8601String(),
        "count": 2
      },
    ]
  };

  ReceptionsBloc() {
    // create slots from reception duration
    List<Slot> slots = createSlotsFromDuration(reception);

    // update slots according to bookings
    slots = modifyBookings(slots, response);
    reception.addSlotList(slots);
    receptions.add(reception);
    receptions.add(Reception(
      subscriberId: '',
      customersInSlot: 4,
      receptionId: '',
      status: 'UPCOMING',
      startTime: DateTime(2020, 7, 26, 9),
      endTime: DateTime(2020, 7, 26, 18),
      slotDuration: Duration(minutes: 30),
    ));
  }

  List<Reception> getReceptionsByDate(DateTime dateTime) {
    List<Reception> filteredReceptions = [];
    for (Reception reception in receptions) {
      DateTime start = reception.startTime;
      DateTime end = reception.endTime;
      if (dateTime.isSameDate(start) || dateTime.isSameDate(end))
        filteredReceptions.add(reception);
    }
    return filteredReceptions;
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/controllers/slots.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';

class ReceptionsBloc extends ChangeNotifier {
  String _subscriberId;
  DateTime _selectedDate;
  List<Reception> selectedDateReceptions;

  ReceptionRepository _receptionRepository;

  StreamController _receptionListController;

  StreamSink<ApiResponse<List<Reception>>> get receptionsSink =>
      _receptionListController.sink;

  Stream<ApiResponse<List<Reception>>> get receptionsStream =>
      _receptionListController.stream;

  DateTime get selectedDate => _selectedDate;

  // TODO remove these
  List<Reception> receptions = [];
  Reception reception1 = Reception(
    subscriberId: '1',
    customersInSlot: 2,
    receptionId: '1',
    status: 'UPCOMING',
    startTime: DateTime(2020, 7, 29, 9),
    endTime: DateTime(2020, 7, 29, 18),
    slotDuration: Duration(minutes: 30),
  );
  Map<String, dynamic> response = {
    "slots": [
      {
        "starttime": DateTime(2020, 7, 29, 9)
            .add(Duration(hours: 5, minutes: 30))
            .toIso8601String(),
        "count": 0
      },
      {
        "starttime": DateTime(2020, 7, 29, 9)
            .add(Duration(hours: 6, minutes: 30))
            .toIso8601String(),
        "count": 0
      },
    ]
  };

  set date(DateTime selected) {
    _selectedDate = selected;
//    logger.d("Selected Date: $_selectedDate\nReceptions date: $selected");
    getReceptionsByDate();
  }

  ReceptionsBloc(this._selectedDate) {
    _receptionRepository = ReceptionRepository();
    _receptionListController = StreamController<ApiResponse<List<Reception>>>();

    // create slots from reception duration
    List<Slot> slots = createSlotsFromDuration(reception1);
    // update slots according to bookings
    slots = modifyBookings(slots, response);
    reception1.addSlotList(slots);

    receptions.add(reception1);
    Reception reception2 = Reception(
      subscriberId: '',
      customersInSlot: 4,
      receptionId: '2',
      status: 'UPCOMING',
      startTime: DateTime(2020, 7, 26, 9),
      endTime: DateTime(2020, 7, 26, 18),
      slotDuration: Duration(minutes: 30),
    );
    receptions.add(reception2);
    receptions.add(Reception(
      subscriberId: '',
      customersInSlot: 3,
      receptionId: '2',
      status: 'UPCOMING',
      startTime: DateTime(2020, 7, 27, 11),
      endTime: DateTime(2020, 7, 27, 12),
      slotDuration: Duration(minutes: 30),
    ));

    fetchReceptionsByStatus();
  }

  fetchReceptionsByStatus() async {
    receptionsSink.add(ApiResponse.loading('Getting receptions data'));

    try {
      final String accessToken =
          await SubscriberRepository().getAccessTokenFromStorage();
      receptions = await _receptionRepository.viewReceptionsByStatus(
        status: ['UPCOMING', 'ACTIVE', 'DONE', 'CANCELLED'],
        accessToken: accessToken,
      );
      receptionsSink.add(ApiResponse.completed(getReceptionsByDate()));
    } catch (e) {
      logger.e(e.toString());
      receptionsSink.add(ApiResponse.error(e.toString()));
    }
  }

  getReceptionsByDate() {
    receptionsSink.add(ApiResponse.loading('Getting receptions data'));
    List<Reception> filteredReceptions = [];
    for (Reception reception in receptions) {
      DateTime start = reception.startTime;
      DateTime end = reception.endTime;
      if (_selectedDate.isSameDate(start) || _selectedDate.isSameDate(end))
        filteredReceptions.add(reception);
    }
    this.selectedDateReceptions = filteredReceptions;
    receptionsSink.add(ApiResponse.completed(filteredReceptions));
    notifyListeners();
    return filteredReceptions;
  }

  createReception(Map<String, dynamic> formData) async {
    // To be used in create reception screen
    try {
      Reception toBeReception = Reception(
        startTime: formData['starttime'],
        endTime: formData['endtime'],
        slotDuration: Duration(minutes: formData['slot']),
        customersInSlot: formData['cust_per_slot'],
      );
      final response = await _receptionRepository.createReception(
        startTime: toBeReception.startTime,
        endTime: toBeReception.endTime,
        slotDurationInMinutes: toBeReception.slotDuration.inMinutes,
        customerPerSlot: toBeReception.customersInSlot,
        accessToken:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InlzenY3OW5ucSIsIm5hbWUiOiJBbWFuZGVlcCdzIFNhbG9vbiIsImlzU3Vic2NyaWJlciI6dHJ1ZSwiaWF0IjoxNTk2MTg4NDA4LCJleHAiOjE1OTYyNzQ4MDh9.JCEI0FCbrHtW2icmbpcAPJP10Yh1g1spTO6JkpjayPQ',
      );
      receptions.add(toBeReception);
      return response;
    } catch (e) {
      logger.e(e.toString());
      // Show persistent snack bar with error
      return e.toString();
    }
  }

  @override
  void dispose() {
    _receptionListController?.close();
    super.dispose();
  }
}

class CreateReceptionsBloc {}

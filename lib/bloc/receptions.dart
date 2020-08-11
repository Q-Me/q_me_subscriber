import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:ordered_set/comparing.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/model/reception.dart';
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

  List<Reception> receptions = [];

  set date(DateTime selected) {
    _selectedDate = selected;
//    logger.d("Selected Date: $_selectedDate\nReceptions date: $selected");
    getReceptionsByDate();
  }

  ReceptionsBloc(this._selectedDate) {
    _receptionRepository = ReceptionRepository();
    _receptionListController = StreamController<ApiResponse<List<Reception>>>();
    receptionsSink.add(ApiResponse.loading('Getting receptions data'));

    fetchReceptionsByStatus();
  }

  fetchReceptionsByStatus() async {
    receptionsSink.add(ApiResponse.loading('Getting receptions data'));

    try {
      final String accessToken =
          await SubscriberRepository().getAccessTokenFromStorage();
      receptions = await _receptionRepository.viewReceptionsByStatus(
        status: ['UPCOMING', 'ACTIVE'],
        accessToken: accessToken,
      );
      getReceptionsByDate();
    } catch (e) {
      logger.e(e.toString());
      receptionsSink.add(ApiResponse.error(e.toString()));
    }
  }

  getReceptionsByDate() async {
    receptionsSink.add(ApiResponse.loading('Getting receptions data'));
    List<Reception> filteredReceptions = [];
    final String accessToken =
        await SubscriberRepository().getAccessTokenFromStorage();
    try {
      List<Future<Reception>> futureReceptions = [];
      for (Reception reception in receptions) {
        DateTime start = reception.startTime;
        DateTime end = reception.endTime;

        if (_selectedDate.isSameDate(start) || _selectedDate.isSameDate(end)) {
          futureReceptions.add(
            _receptionRepository.viewReceptionDetailed(
              counterId: reception.receptionId,
              accessToken: accessToken,
            ),
          );
        }
      }
      filteredReceptions = await Future.wait(futureReceptions);

      SplayTreeSet<Reception> receptionsSet = SplayTreeSet<Reception>(
          Comparing.on((reception) => reception.startTime));
      receptionsSet.addAll(filteredReceptions);
      filteredReceptions = receptionsSet.toList();

      this.selectedDateReceptions = filteredReceptions;
      receptionsSink.add(ApiResponse.completed(filteredReceptions));
    } on Exception catch (e) {
      receptionsSink.add(ApiResponse.error(e.toString()));
      logger.e(e.toString());
    }

    notifyListeners();
    return filteredReceptions;
  }

  /*
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
  }*/

  @override
  void dispose() {
    _receptionListController?.close();
    super.dispose();
  }
}

class CreateReceptionsBloc {}

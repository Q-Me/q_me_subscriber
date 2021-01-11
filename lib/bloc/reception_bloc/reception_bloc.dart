import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:equatable/equatable.dart';

part 'reception_event.dart';
part 'reception_state.dart';

class ReceptionBloc extends Bloc<ReceptionEvent, ReceptionState> {
  ReceptionBloc({
    @required this.receptionRepo,
    @required this.subscriberRepository,
  }) : super(ReceptionInitial());

  ReceptionRepository receptionRepo;
  SubscriberRepository subscriberRepository;
  List<String> status = [
    "UPCOMING",
  ];

  List<String> get currentStatus {
    return status;
  }

  @override
  Stream<ReceptionState> mapEventToState(
    ReceptionEvent event,
  ) async* {
    if (event is DateWiseReceptionsRequested) {
      yield* _mapDateWiseReceptionsRequestedToState(event);
    } else if (event is StatusUpdateOfReceptionRequested) {
      yield* _mapStatusUpdateOfReceptionRequestedToState(event);
    } else if (event is ReceptionBlocUpdateRequested) {
      yield* _mapReceptionBlocUpdateRequestedToState(event);
    }
  }

  Stream<ReceptionState> _mapDateWiseReceptionsRequestedToState(
      DateWiseReceptionsRequested event) async* {
    yield ReceptionLoading();
    try {
      if (this.status.length != 0) {
        List<Reception> receptions = await _getSortedReceptions(
          date: event.date,
          status: this.status,
        );
        yield ReceptionLoadSuccessful(
          receptions: receptions,
        );
      } else {
        yield ReceptionsLoadFailure(
            error: "Please select atleast one option to view receptions");
      }
    } on AppException catch (e) {
      yield ReceptionsLoadFailure(
        error: e.message,
      );
    }
  }

  Stream<ReceptionState> _mapReceptionBlocUpdateRequestedToState(
      ReceptionBlocUpdateRequested event) async* {
    yield ReceptionLoading();
    try {
      List<Reception> receptions = await _getSortedReceptions(
        date: event.date,
        status: this.status,
      );
      yield ReceptionLoadSuccessful(
        receptions: receptions,
      );
    } on AppException catch (e) {
      yield ReceptionsLoadFailure(error: e.message);
    }
  }

  Stream<ReceptionState> _mapStatusUpdateOfReceptionRequestedToState(
      StatusUpdateOfReceptionRequested event) async* {
    yield ReceptionLoading();
    try {
      String _accessToken =
          await subscriberRepository.getAccessTokenFromStorage();
      Map<String, dynamic> _response =
          await receptionRepo.updateReceptionStatus(
        counterId: event.receptionId,
        status: event.updatedStatus,
        accessToken: _accessToken,
      );

      List<Reception> receptions = await _getSortedReceptions(
        date: event.date,
        status: this.status,
      );
      yield ReceptionLoadSuccessful(
        receptions: receptions,
      );
    } on AppException catch (e) {
      yield ReceptionsLoadFailure(
        error: e.message,
      );
    }
  }

  Future<List<Reception>> _getSortedReceptions({
    @required DateTime date,
    @required List<String> status,
  }) async {
    String _accessToken =
        await subscriberRepository.getAccessTokenFromStorage();
    List<Reception> listOfAllReceptions = await receptionRepo
        .viewReceptionsByStatus(status: status, accessToken: _accessToken);
    List<Reception> requiredReceptions = [];
    for (Reception reception in listOfAllReceptions) {
      if (reception.startTime.isSameDate(date) ||
          reception.endTime.isSameDate(date)) {
        Reception element = await receptionRepo.viewReceptionDetailed(
            receptionId: reception.receptionId);
        requiredReceptions.add(element);
      }
    }
    requiredReceptions.sort(
      (a, b) => a.startTime.compareTo(b.startTime),
    );
    return requiredReceptions;
  }

  void addElementToStatus({@required String element}) =>
      this.status.add(element);

  void removeElementFromStatus({@required String element}) =>
      this.status.remove(element);

  void replaceStatusList({@required List<String> updatedStatus}) =>
      this.status = updatedStatus;

  bool isHaving({@required String counter}) => this.status.contains(counter);
}

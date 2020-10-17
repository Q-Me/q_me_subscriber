import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';

part 'reception_event.dart';
part 'reception_state.dart';

class ReceptionBloc extends Bloc<ReceptionEvent, ReceptionState> {
  ReceptionBloc() : super(ReceptionInitial());

  ReceptionRepository _receptionRepo = new ReceptionRepository();
  @override
  Stream<ReceptionState> mapEventToState(
    ReceptionEvent event,
  ) async* {
    logger.i(event.toString() + " is the event called");
    if (event is DateWiseReceptionsRequested) {
      yield* _mapDateWiseReceptionsRequestedToState(event);
    } else if (event is ReceptionBlocUpdateRequested) {
      yield* _mapReceptionBlocUpdateRequestedToState(event);
    } else if (event is StatusUpdateOfReceptionRequested) {
      _mapStatusUpdateOfReceptionRequestedToState(event);
    }
  }

  Stream<ReceptionState> _mapDateWiseReceptionsRequestedToState(
      DateWiseReceptionsRequested event) async* {
    yield ReceptionLoading();
    try {
      List<Reception> receptions = await _getSortedReceptions(
        date: event.date,
      );
      yield ReceptionLoadSuccessful(
        receptions: receptions,
      );
    } catch (e) {
      yield ReceptionsLoadFailure(error: e);
    }
  }

  Stream<ReceptionState> _mapReceptionBlocUpdateRequestedToState(
      ReceptionBlocUpdateRequested event) async* {
    try {
      List<Reception> receptions = await _getSortedReceptions(
        date: event.date,
      );
      yield ReceptionLoadSuccessful(
        receptions: receptions,
      );
    } catch (e) {
      yield ReceptionsLoadFailure(error: e);
    }
  }

  Stream<ReceptionState> _mapStatusUpdateOfReceptionRequestedToState(
      StatusUpdateOfReceptionRequested event) async* {
    yield ReceptionLoading();
    try {
      String _accessToken =
          await SubscriberRepository().getAccessTokenFromStorage();
      Map<String, dynamic> _response =
          await _receptionRepo.updateReceptionStatus(
              counterId: event.receptionId,
              status: event.updatedStatus,
              accessToken: _accessToken);

      List<Reception> receptions = await _getSortedReceptions(
        date: event.date,
      );
      yield ReceptionLoadSuccessful(
        receptions: receptions,
      );
    } catch (e) {
      yield ReceptionsLoadFailure(
        error: e.toString(),
      );
    }
  }

  Future<List<Reception>> _getSortedReceptions(
      {@required DateTime date}) async {
    String _accessToken =
        await SubscriberRepository().getAccessTokenFromStorage();
    List<Reception> listOfAllReceptions = await _receptionRepo
        .viewReceptionsByStatus(status: ["ALL"], accessToken: _accessToken);
    List<Reception> requiredReceptions = [];
    for (Reception reception in listOfAllReceptions) {
      if (reception.startTime.isSameDate(date) ||
          reception.endTime.isSameDate(date)) {
        Reception element = await _receptionRepo.viewReceptionDetailed(
            receptionId: reception.receptionId);
        requiredReceptions.add(element);
      }
    }
    requiredReceptions.sort(
      (a, b) => a.startTime.compareTo(b.startTime),
    );
    return requiredReceptions;
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

import '../repository/reception.dart';
import '../utilities/logger.dart';

part 'appointment_event.dart';
part 'appointment_state.dart';

class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final ReceptionRepository repository;
  AppointmentBloc(this.repository)
      : assert(repository != null),
        super(AppointmentInitial());

  @override
  Stream<AppointmentState> mapEventToState(
    AppointmentEvent event,
  ) async* {
    if (event is AppointmentFinished) {
      yield* _mapBookingDoneToState(event);
    }
    if (event is AppointmentCancelRequested) {
      yield* _mapBookingCancelRequestedToState(event);
    }
  }

  Stream<AppointmentState> _mapBookingDoneToState(
      AppointmentFinished event) async* {
    yield Loading();
    try {
      var response = await repository.completeAppointment(
          counterId: event.counterId,
          phone: event.phoneNo,
          otp: event.otp,
          accessToken: event.accessToken);
      if (response["msg"] == "Slot done") {
        yield AppointmentFinishSuccessful();
      } else {
        logger.e(response["msg"]);
        yield ProcessFailure();
      }
    } catch (e) {
      logger.e(e);
      yield ProcessFailure();
    }
  }

  Stream<AppointmentState> _mapBookingCancelRequestedToState(
      AppointmentCancelRequested event) async* {
    yield Loading();
    try {
      var response = await repository.cancelAppointment(
          counterId: event.counterId,
          phone: event.phoneNo,
          accessToken: event.accessToken);
      var update;
      if (response["msg"] == "Slot Cancelled") {
        yield AppointmentCancelSuccessful();
        update = await repository.updateReceptionStatus(
            counterId: event.counterId,
            status: "DONE",
            accessToken: event.accessToken);
      } else {
        logger.e(response["msg"]);
        logger.e(update);
        yield ProcessFailure();
      }
    } catch (e) {
      logger.e(e);
    }
  }
}

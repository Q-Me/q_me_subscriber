import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';

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
      Map<String, dynamic> response = await repository.completeAppointment(
        counterId: event.counterId,
        phone: event.phoneNo,
        otp: event.otp.toString(),
        accessToken: event.accessToken,
      );
      logger.d(response["msg"]);
      yield AppointmentFinishSuccessful();
    } on BadRequestException {
      yield AppointmentWrongOtpProvided();
    } catch (e) {
      logger.e(e.toString());
      yield ProcessFailure();
    }
  }

  Stream<AppointmentState> _mapBookingCancelRequestedToState(
      AppointmentCancelRequested event) async* {
    yield Loading();
    try {
      final response = await repository.cancelAppointment(
        counterId: event.counterId,
        phone: event.phoneNo,
        accessToken: event.accessToken,
      );
      var update;
      if (response["msg"] == "Slot Cancelled") {
        yield AppointmentCancelSuccessful();
      } else {
        logger.e(response["msg"]);
        logger.e(update);
        yield ProcessFailure();
      }
    } catch (e) {
      logger.e(e.toString());
      ProcessFailure();
    }
  }
}

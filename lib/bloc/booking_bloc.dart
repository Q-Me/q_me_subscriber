import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/utilities/logger.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final ReceptionRepository receptionRepository;
  BookingBloc(this.receptionRepository) : super(BookingInitial());

  @override
  Stream<BookingState> mapEventToState(
    BookingEvent event,
  ) async* {
    if (event is BookingListRequested)
      yield* _mapBookingListRequestedToState(event);
    else if (event is AppointmentFinishRequested)
      yield* _mapAppointmentFinishRequestedToState(event);
    else if (event is AppointmentCancelRequested)
      yield* _mapAppointmentCancelRequestedToState(event);
    else if (event is BookingRefreshRequested)
      yield BookingInitial();
    else if (event is AddUnbookedAppointment)
      yield* _mapAddUnbookedAppointmentToState(event);
    else if (event is RemoveUnbookedAppointment)
      yield* _mapRemoveUnbookedAppointmentToState(event);
  }

  Stream<BookingState> _mapBookingListRequestedToState(
      BookingListRequested event) async* {
    yield BookingLoading();
    try {
      List<Appointment> response =
          await receptionRepository.viewBookingsDetailed(
              counterId: event.counterId,
              startTime: event.startTime,
              endTime: event.endTime,
              status: event.status);
      logger.i(response);
      yield BookingLoadSuccessful(response);
//      logger.d("getting bookings successful");
    } catch (e) {
      logger.e("Getting Booking list failed");
      yield BookingLoadFailure();
    }
  }

  Stream<BookingState> _mapAppointmentFinishRequestedToState(
      AppointmentFinishRequested event) async* {
    yield BookingLoading();
    try {
      var response = await receptionRepository.completeAppointment(
          counterId: event.receptionId,
          phone: event.phone,
          otp: event.otp.toString(),
          accessToken: event.accessToken);
      logger.d("calling api for completing appointment success");
      logger.i(response);
      BookingLoadSuccessful(response);
    } catch (e) {
      logger.e(e);
      yield BookingLoadFailure();
    }
  }

  Stream<BookingState> _mapAppointmentCancelRequestedToState(
      AppointmentCancelRequested event) async* {
    yield BookingLoading();
    try {
      var response = await receptionRepository.cancelAppointment(
          counterId: event.counterId, phone: event.phone);
      logger.d("calling cancel api success");
      logger.i(response);
      yield BookingLoadSuccessful(response);
    } catch (e) {
      logger.e(e);
      yield BookingLoadFailure();
    }
  }

  Stream<BookingState> _mapAddUnbookedAppointmentToState(
      AddUnbookedAppointment event) async* {
    yield BookingLoading();
    try {
      Slot slot = event.slot;
      final response = await receptionRepository.createOverrideSlot(
        receptionId: event.receptionId,
        startTime: event.slot.startTime,
        endTime: event.slot.endTime,
        customerPerSlotOverride: event.slot.customersInSlot + 1,
      );

      response["msg"] = "Override Set Successfully";
      slot.customersInSlot = event.slot.customersInSlot + 1;

      yield BookingLoadSuccessful(slot);
    } catch (e) {
      logger.d(e.toString());

      yield BookingLoadFailure();
    }
  }

  Stream<BookingState> _mapRemoveUnbookedAppointmentToState(
      RemoveUnbookedAppointment event) async* {
    yield BookingLoading();

    try {
      Slot slot = event.slot;
      final response = await receptionRepository.createOverrideSlot(
        receptionId: event.receptionId,
        startTime: event.slot.startTime,
        endTime: event.slot.endTime,
        customerPerSlotOverride: event.slot.customersInSlot - 1,
      );

      response["msg"] = "Override Set Successfully";
      slot.customersInSlot = event.slot.customersInSlot - 1;

      yield BookingLoadSuccessful(slot);
    } catch (e) {
      logger.d(e.toString());
      yield BookingLoadFailure();
    }
  }
}

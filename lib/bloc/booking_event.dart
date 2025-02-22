part of 'booking_bloc.dart';

@immutable
abstract class BookingEvent {}

class BookingListRequested extends BookingEvent {
  final String counterId;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> status;
  final int slotDurationInMinutes;

  BookingListRequested(this.counterId, this.startTime, this.endTime,
      this.status, this.slotDurationInMinutes);
}

class AppointmentCancelRequested extends BookingEvent {
  final String counterId;
  final String phone;

  AppointmentCancelRequested(this.counterId, this.phone);
}

class AppointmentFinishRequested extends BookingEvent {
  final String receptionId;
  final String phone;
  final int otp;
  final String accessToken;

  AppointmentFinishRequested(
    this.receptionId,
    this.phone,
    this.otp,
    this.accessToken,
  );
}

class AddUnbookedAppointment extends BookingEvent {
  final String receptionId;
  final Slot slot;

  AddUnbookedAppointment(
    this.receptionId,
    this.slot,
  );
}

class RemoveUnbookedAppointment extends BookingEvent {
  final String receptionId;
  final Slot slot;

  RemoveUnbookedAppointment(this.receptionId, this.slot);
}

class BookingRefreshRequested extends BookingEvent {}

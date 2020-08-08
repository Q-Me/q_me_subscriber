part of 'booking_bloc.dart';

@immutable
abstract class BookingEvent {}

class BookingListRequested extends BookingEvent {
  final String counterId;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> status;
  final int slotDurationInMinutes;
  final String accessToken;

  BookingListRequested(this.counterId, this.startTime, this.endTime,
      this.status, this.slotDurationInMinutes, this.accessToken);
}

class AppointmentCancelRequested extends BookingEvent {
  final String counterId;
  final String phone;
  final String accessToken;

  AppointmentCancelRequested(this.counterId, this.phone, this.accessToken);
}

class AppointmentFinishRequested extends BookingEvent {
  final String counterId;
  final String phone;
  final int otp;
  final String accessToken;

  AppointmentFinishRequested(
      this.counterId, this.phone, this.otp, this.accessToken);
}

part of 'appointment_bloc.dart';

@immutable
abstract class AppointmentEvent {}

class AppointmentFinished extends AppointmentEvent {
  final String counterId;
  final String phoneNo;
  final String accessToken;
  final int otp;

  AppointmentFinished(this.counterId, this.phoneNo, this.accessToken, this.otp);
}

class AppointmentCancelRequested extends AppointmentEvent {
  final String counterId;
  final String phoneNo;
  final String accessToken;

  AppointmentCancelRequested(this.counterId, this.phoneNo, this.accessToken);
}

part of 'appointment_bloc.dart';

@immutable
abstract class AppointmentState {}

class AppointmentInitial extends AppointmentState {}

class Loading extends AppointmentState {}

class AppointmentFinishSuccessful extends AppointmentState {}

class AppointmentCancelSuccessful extends AppointmentState {}

class ProcessFailure extends AppointmentState {}

class AppointmentWrongOtpProvided extends AppointmentState {}

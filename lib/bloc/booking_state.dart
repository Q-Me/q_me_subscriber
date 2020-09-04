part of 'booking_bloc.dart';

@immutable
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoadSuccessful extends BookingState {
  final response;
  BookingLoadSuccessful(this.response) : assert(response != null);
}

class BookingLoadFailure extends BookingState {}

class CardCancelledState extends BookingState {}

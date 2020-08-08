part of 'booking_bloc.dart';

@immutable
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoadSuccesful extends BookingState {
  final response;
  BookingLoadSuccesful(this.response) : assert(response != null);
}

class BookingLoadFailure extends BookingState {}

class CardCancelledState extends BookingState {}

part of 'reception_bloc.dart';

@immutable
abstract class ReceptionEvent {}

class DateWiseReceptionsRequested extends ReceptionEvent {
  final DateTime date;

  DateWiseReceptionsRequested({@required this.date});
}

class StatusUpdateOfReceptionRequested extends ReceptionEvent {
  final DateTime date;
  final String receptionId;
  final String updatedStatus;

  StatusUpdateOfReceptionRequested({
    @required this.receptionId,
    @required this.updatedStatus,
    @required this.date,
  });
}

class ReceptionBlocUpdateRequested extends ReceptionEvent {
  final DateTime date;

  ReceptionBlocUpdateRequested(this.date);
}

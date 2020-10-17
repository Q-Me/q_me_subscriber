part of 'reception_bloc.dart';

@immutable
abstract class ReceptionState {}

class ReceptionInitial extends ReceptionState {}

class ReceptionLoading extends ReceptionState {}

class ReceptionLoadSuccessful extends ReceptionState {
  final List<Reception> receptions;

  ReceptionLoadSuccessful({@required this.receptions});
}

class ReceptionsLoadFailure extends ReceptionState {
  final String error;
  
  ReceptionsLoadFailure({@required this.error});
}

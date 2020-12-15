part of 'reception_bloc.dart';

@immutable
abstract class ReceptionState extends Equatable {}

class ReceptionInitial extends ReceptionState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ReceptionLoading extends ReceptionState {
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ReceptionLoadSuccessful extends ReceptionState {
  final List<Reception> receptions;

  ReceptionLoadSuccessful({@required this.receptions});

  @override
  // TODO: implement props
  List<Object> get props => [this.receptions];
}

class ReceptionsLoadFailure extends ReceptionState {
  final String error;
  
  ReceptionsLoadFailure({@required this.error});

  @override
  // TODO: implement props
  List<Object> get props => [this.error];
}

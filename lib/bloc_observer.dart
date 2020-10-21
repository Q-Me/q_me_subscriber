import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme_subscriber/utilities/logger.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    logger.d('onEvent -- bloc: ${bloc.runtimeType}, event: $event');
  }

  @override
  void onChange(Cubit cubit, Change change) {
    super.onChange(cubit, change);
    logger.d('onChange -- cubit: ${cubit.runtimeType}, change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.d('onTransition -- bloc: ${bloc.runtimeType}, transition: $transition');
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    logger.d('onError -- cubit: ${cubit.runtimeType}, error: $error');
    super.onError(cubit, error, stackTrace);
  }
}
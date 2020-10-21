import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qme_subscriber/bloc_observer.dart';

import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/views/receptions.dart';

import 'router.dart' as router;
import 'services/analytics.dart';

import 'views/signin.dart';

var analytics = AnalyticsService();
String initialHome = SignInScreen.id;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  if (await SubscriberRepository().isSessionReady()) {
    initialHome = ReceptionsScreen.id;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialHome,
      navigatorObservers: [analytics.getAnalyticsObserver()],
    );
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
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
  runApp(FireBaseNotificationHandler());
}

class FireBaseNotificationHandler extends StatefulWidget {
  FireBaseNotificationHandler({Key key}) : super(key: key);

  @override
  _FireBaseNotificationHandlerState createState() =>
      _FireBaseNotificationHandlerState();
}

class _FireBaseNotificationHandlerState
    extends State<FireBaseNotificationHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  bool isValidCache = true;
  @override
  void initState() {
    super.initState();
    _fcm.configure(
      onLaunch: (Map<String, dynamic> message) async {
        isValidCache = false;
      },
      onResume: (Map<String, dynamic> message) async {
        isValidCache = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(
      isValidCache: isValidCache,
    );
  }
}

class MyApp extends StatelessWidget {
  final bool isValidCache;
  MyApp({
    @required this.isValidCache,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.blue),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialHome,
      onGenerateInitialRoutes: (initialRoute) {
        if (initialRoute == ReceptionsScreen.id) {
          return [
            MaterialPageRoute(
              builder: (context) => ReceptionsScreen(
                arguments: ReceptionScreenArguments(
                  isValidCache: isValidCache,
                ),
              ),
            ),
          ];
        } else {
          return [
            MaterialPageRoute(
              builder: (context) => SignInScreen(),
            ),
          ];
        }
      },
      navigatorObservers: [analytics.getAnalyticsObserver()],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/views/queues.dart';
import 'package:qme_subscriber/views/receptions.dart';

import 'router.dart' as router;
import 'services/analytics.dart';
import 'views/signin.dart';

var analytics = AnalyticsService();
String initialHome = SignInScreen.id;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (await SubscriberRepository().isSessionReady()) {
    initialHome = QueuesScreen.id;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.green),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generateRoute,
      initialRoute: ReceptionsScreen.id,
      navigatorObservers: [analytics.getAnalyticsObserver()],
    );
  }
}

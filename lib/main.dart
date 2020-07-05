import 'package:flutter/material.dart';
import 'package:qme_subscriber/services/analytics.dart';

import 'repository/subscriber.dart';
import 'router.dart' as router;
import 'views/queues.dart';
import 'views/signin.dart';

var analytics = AnalyticsService();
String initialHome = SignInScreen.id;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
//  await setSession();
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
      initialRoute: initialHome,
      navigatorObservers: [analytics.getAnalyticsObserver()],
    );
  }
}

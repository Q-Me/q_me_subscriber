import 'package:flutter/material.dart';
import 'views/people.dart';
import 'views/viewQueue.dart';
import 'views/signup.dart';
import 'views/signin.dart';
import 'views/profile.dart';
import 'views/queues.dart';
import 'views/createQueue.dart';
import 'repository/subscriber.dart';

AuthService appAuth = new AuthService();

void main() async {
  String initialHome = SignInScreen.id;

  // Get result of the login function.
//  bool _result = await appAuth.login();
  WidgetsFlutterBinding.ensureInitialized();
  SubscriberRepository subscriberRepo = SubscriberRepository();
  if (await subscriberRepo.isTokenExpired()) {
    if (await subscriberRepo.isRefreshTokenSet()) {
      // Get new accessToken
      final newAccessToken = await subscriberRepo.getAccessToken();
      if (newAccessToken != '-1') {
        initialHome = QueuesPage.id;
      }
    }
  }

  runApp(MaterialApp(
    theme: ThemeData.light().copyWith(primaryColor: Colors.green),
    debugShowCheckedModeBanner: false,
    routes: <String, WidgetBuilder>{
      SignUpScreen.id: (BuildContext context) => SignUpScreen(),
      SignInScreen.id: (BuildContext context) => SignInScreen(),
      ProfileScreen.id: (BuildContext context) => ProfileScreen(),
      QueuesPage.id: (BuildContext context) => QueuesPage(),
      CreateQueueScreen.id: (BuildContext context) => CreateQueueScreen(),
      ViewQueueScreen.id: (BuildContext context) => ViewQueueScreen(),
      PeopleScreen.id: (BuildContext context) => PeopleScreen(),
    },
    initialRoute: initialHome,
  ));
}

import 'package:flutter/material.dart';
import 'package:qme_subscriber/views/people.dart';
import 'package:qme_subscriber/views/viewQueue.dart';
import 'views/signup.dart';
import 'views/signin.dart';
import 'views/profile.dart';
import 'views/queues.dart';
import 'views/createQueue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: QueuesPage.id,
    );
  }
}

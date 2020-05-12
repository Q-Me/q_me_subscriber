import 'package:flutter/material.dart';
import 'views/signup.dart';
import 'views/signin.dart';
import 'views/profile.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Colors.green),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        SignUpPage.id: (BuildContext context) => SignUpPage(),
        SignInPage.id: (BuildContext context) => SignInPage(),
        ProfilePage.id: (BuildContext context) => ProfilePage(),
        // TODO Create Queue
      },
      initialRoute: SignUpPage.id,
    );
  }
}

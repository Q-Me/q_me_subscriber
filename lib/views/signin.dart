import 'package:flutter/material.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/views/signup.dart';
import '../widgets/text.dart';
import '../widgets/formField.dart';
import 'dart:developer';
import '../constants.dart';
import '../repository/subscriber.dart';
import '../views/queues.dart';

class SignInScreen extends StatefulWidget {
  static const String id = '/signIn';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formKey =
      GlobalKey<FormState>(); // Used in login button and forget password
  String email;
  String password;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          body: Builder(
            builder: (context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: ThemedText(words: ['Hello', 'There']),
                  ),
                  Container(
                      padding:
                          EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            MyFormField(
                              required: true,
                              name: 'EMAIL',
                              callback: (String newEmail) {
                                email = newEmail;
                                log('email is $email');
                              },
                            ),
                            SizedBox(height: 20.0),
                            MyFormField(
                              required: true,
                              obscureText: true,
                              name: 'PASSWORD',
                              callback: (String newPassword) {
                                password = newPassword;
                                log('pass1 is $password');
                              },
                            ),
                            SizedBox(height: 5.0),
                            /* TODO complete this after API for forget password is working
                            Container(
                              alignment: Alignment(1.0, 0.0),
                              padding: EdgeInsets.only(top: 15.0, left: 20.0),
                              child: InkWell(
                                child: Text(
                                  'Forgot Password',
                                  style: kLinkTextStyle,
                                ),
                              ),
                            ),*/
                            SizedBox(height: 40.0),
                            Container(
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.greenAccent,
                                color: Colors.green,
                                elevation: 7.0,
                                child: InkWell(
                                  onTap: () async {
                                    if (formKey.currentState.validate()) {
                                      // email and password both are available here
                                      var response;
                                      log('Email is $email\tpassword is $password');
                                      try {
                                        response = await SubscriberRepository()
                                            .signIn({
                                          'email': email,
                                          'password': password,
                                        });
                                        log('SIGNIN API RESPONSE: ' +
                                            response.toString());

                                        await SubscriberRepository()
                                            .storeSubscriberData(
                                                Subscriber.fromJson(response));

//                                        Navigator.push(
//                                            context,
//                                            MaterialPageRoute(
//                                                builder: (context) =>
//                                                    QueuesPage(
//                                                      subscriberId:
//                                                          response['id'],
//                                                    )));
                                        Navigator.pushNamed(
                                            context, QueuesScreen.id);
                                      } catch (e) {
//                                        Scaffold.of(context).showSnackBar(
//                                            SnackBar(
//                                                content: Text(e.toString())));
                                        _showSnackBar(e.toString());
                                        log('Error in signIn API: ' +
                                            e.toString());
                                        return;
                                      }
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Montserrat'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.0),
                            SizedBox(height: 20.0),
                          ],
                        ),
                      )),
                  SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'New to Q Me?',
                        style: TextStyle(fontFamily: 'Montserrat'),
                      ),
                      SizedBox(width: 5.0),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(SignUpScreen.id);
                          print('Register button pressed');
                        },
                        child: Text(
                          'Register',
                          style: kLinkTextStyle,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
//
//class SignInButton extends StatelessWidget {
//  const SignInButton({
//    Key key,
//    @required this.formKey,
//    @required this.email,
//    @required this.password,
//  }) : super(key: key);
//
//  final GlobalKey<FormState> formKey;
//  final String email;
//  final String password;
//
//  @override
//  Widget build(BuildContext context) {
//    return ;
//  }
//}

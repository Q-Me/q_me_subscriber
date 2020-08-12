import 'dart:developer';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/otpPage.dart';
import 'package:qme_subscriber/views/receptions.dart';
import 'package:qme_subscriber/views/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../repository/subscriber.dart';
import '../widgets/text.dart';

class SignInScreen extends StatefulWidget {
  static const String id = '/signIn';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  TabController _controller;
  var idToken;
  var verificationIdVar;
  var _authVar;
  String countryCodeVal;
  String countryCodePassword;
  bool showOtpTextfield = false;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  var _fcmToken;
  final formKey =
      GlobalKey<FormState>(); // Used in login button and forget password
  String phoneNumber;
  String password;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(text),
    ));
  }

  // otp verification with firebase
  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        // verificationCompleted: (AuthCredential credential) async {
        //   AuthResult result = await _auth.signInWithCredential(credential);
        //   print("printing the credential");
        //   print(credential);

        //   FirebaseUser user = result.user;

        //   if (user != null) {
        //     var token = await user.getIdToken().then((result) async {
        //       idToken = result.token;
        //       print(" $idToken ");
        //       FocusScope.of(context)
        //           .requestFocus(FocusNode()); // dismiss the keyboard
        //       Scaffold.of(context)
        //           .showSnackBar(SnackBar(content: Text('Processing Data')));
        //       var response;
        //       try {
        //          SharedPreferences prefs = await SharedPreferences.getInstance();
        //         prefs.setString('fcmToken', _fcmToken);
        //         response = await SubscriberRepository().signInFirebaseotp({
        //           'token': idToken,
        //         });
        //         print("@@$response@@");

        //         log('SIGNIN API RESPONSE: ' + response.toString());

        //         await SubscriberRepository()
        //             .storeSubscriberData(Subscriber.fromJson(response));
        //         Scaffold.of(context)
        //             .showSnackBar(SnackBar(content: Text('Processing Data')));
        //         var responsefcm = await SubscriberRepository().fcmTokenSubmit({
        //           'token': _fcmToken,
        //         }, response['accessToken']);
        //       prefs.setString('fcmToken',_fcmToken );
        //         print("fcm token Api: $responsefcm");
        //         print("fcm token  Apiresponse: ${responsefcm['status']}");
        //         Navigator.pushNamed(context, QueuesScreen.id);
        //       } catch (e) {
        //         print(" !!$e !!");
        //         Scaffold.of(context)
        //             .showSnackBar(SnackBar(content: Text(e.toString())));
        //         // _showSnackBar(e.toString());
        //         log('Error in signIn API: ' + e.toString());
        //         return;
        //       }
        //     });
        //   } else {
        //     print("Error");
        //   }

        //   //This callback would gets called when verification is done auto maticlly
        // },
        verificationFailed: (AuthException exception) {
          print("here is exception error");
          print(exception.message);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(exception.message.toString())));
        },
        codeSent: (String verificationId, [int forceResendingToken]) async {
          // _authVar = _auth;
          // verificationIdVar = verificationId;

          verificationIdOtp = verificationId;
          authOtp = _auth;
          loginPage = "SignIn";
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString('fcmToken', _fcmToken);

          setState(() {
            showOtpTextfield = true;
          });
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 2, vsync: this);
    firebaseCloudMessagingListeners();
    _messaging.getToken().then((token) {
      print("fcmToken: $token");
      _fcmToken = token;
    });
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _messaging.getToken().then((token) {
      print(token);
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomPadding: true,
          body: Builder(
            builder: (context) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: ThemedText(words: ['Q Me', 'Partner']),
                  ),
                  Container(
                      padding:
                          EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 20.0),
                            Container(
                              decoration: new BoxDecoration(
                                  color: Theme.of(context).primaryColor),
                              child: new TabBar(
                                controller: _controller,
                                indicatorColor: Colors.white,
                                tabs: [
                                  new Tab(
                                    icon: const Icon(Icons.message),
                                    text: '   OTP   ',
                                  ),
                                  new Tab(
                                    icon: const Icon(Icons.visibility_off),
                                    text: 'Password',
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: TabBarView(
                                controller: _controller,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Card(
                                        child: new ListTile(
                                          leading: CountryCodePicker(
                                            onChanged: print,
                                            initialSelection: 'In',
                                            hideSearch: false,
                                            showCountryOnly: false,
                                            showOnlyCountryWhenClosed: false,
                                            builder: (countryCode) {
                                              var countryCodes = countryCode;
                                              countryCodeVal =
                                                  countryCodes.toString();
                                              return Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15,
                                                  // height: 0.085,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    '$countryCode',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ));
                                            },
                                          ),
                                          title: TextFormField(
                                            decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[200])),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300])),
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                hintText: "Mobile Number"),
                                                keyboardType: TextInputType.phone,
                                            controller: _phoneController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'This field cannot be left blank';
                                              } else {
                                                setState(() {
                                                  phoneNumber =
                                                      countryCodeVal + value;
                                                });
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          shadowColor: Colors.blueAccent,
                                          color: Theme.of(context).primaryColor,
                                          elevation: 7.0,
                                          child: InkWell(
                                            onTap: () async {
                                              if (formKey.currentState
                                                  .validate()) {
                                                FocusScope.of(context).requestFocus(
                                                    FocusNode()); // dismiss the keyboard
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Processing Data')));
                                                final phone = _phoneController
                                                    .text
                                                    .trim();
                                                print("phone number: $phone");
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text("Alert!"),
                                                        content: Text(
                                                            "You might receive an SMS message for verification and standard rates apply."),
                                                        actions: <Widget>[
                                                          FlatButton(
                                                            child: Text(
                                                                "Disagree"),
                                                            textColor:
                                                                Colors.white,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            onPressed: () {
                                                              Navigator
                                                                  .pushAndRemoveUntil(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                SignInScreen(),
                                                                      ),
                                                                      (route) =>
                                                                          false);
                                                            },
                                                          ),
                                                          FlatButton(
                                                            child:
                                                                Text("Agree"),
                                                            textColor:
                                                                Colors.white,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              loginUser(
                                                                  countryCodeVal +
                                                                      phone,
                                                                  context);
                                                              Navigator
                                                                  .pushNamed(
                                                                      context,
                                                                      OtpPage
                                                                          .id);
                                                            },
                                                          ),
                                                        ],
                                                      );
                                                    });
                                              }
                                            },
                                            child: Center(
                                              child: Text(
                                                'Login',
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
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Card(
                                        child: ListTile(
                                          leading: CountryCodePicker(
                                            onChanged: print,
                                            initialSelection: 'In',
                                            hideSearch: false,
                                            showCountryOnly: false,
                                            showOnlyCountryWhenClosed: false,
                                            builder: (countryCode) {
                                              var countryCodes = countryCode;
                                              countryCodePassword =
                                                  countryCodes.toString();
                                              return Container(
                                                  alignment: Alignment.center,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.15,
                                                  // height: 0.085,
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    '$countryCode',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ));
                                            },
                                          ),
                                          title: TextFormField(
                                            decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[200])),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300])),
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                hintText: "Mobile Number"),
                                                keyboardType:TextInputType.phone,
                                            controller: _phoneController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'This field cannot be left blank';
                                              } else {
                                                setState(() {
                                                  phoneNumber =
                                                      countryCodePassword +
                                                          value;
                                                });
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02),
                                      Card(
                                        child: ListTile(
                                          title: TextFormField(
                                            obscureText: true,
                                            decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(8)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[200])),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .grey[300])),
                                                filled: true,
                                                fillColor: Colors.grey[100],
                                                hintText: "Password"),
                                            controller: _passwordController,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'This field cannot be left blank';
                                              } else {
                                                password = value;
                                                return null;
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: Material(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          shadowColor: Colors.blueAccent,
                                          color: Theme.of(context).primaryColor,
                                          elevation: 7.0,
                                          child: InkWell(
                                            onTap: () async {
                                              if (formKey.currentState
                                                  .validate()) {
                                                FocusScope.of(context).requestFocus(
                                                    FocusNode()); // dismiss the keyboard
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Processing Data')));
                                                // phone and password both are available here
                                                var response;
                                                try {
                                                  response =
                                                      await SubscriberRepository()
                                                          .signIn({
                                                    'phone': phoneNumber,
                                                    'password': password,
                                                  });
                                                  print("@@$response@@");

                                                  log('SIGNIN API RESPONSE: ' +
                                                      response.toString());

                                                  await SubscriberRepository()
                                                      .storeSubscriberData(
                                                          Subscriber.fromJson(
                                                              response));
                                                  await SubscriberRepository()
                                                      .storeSubscriberData(
                                                          Subscriber.fromJson(
                                                              response));
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              'Processing Data')));
                                                  var responsefcm =
                                                      await SubscriberRepository()
                                                          .fcmTokenSubmit({
                                                    'token': _fcmToken,
                                                  }, response['accessToken']);
                                                  print(
                                                      "fcm token Api: $responsefcm");
                                                  print(
                                                      "fcm token  Apiresponse: ${responsefcm['status']}");
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.setString(
                                                      'fcmToken', _fcmToken);

                                                 Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    ReceptionsScreen.id,
                                                    (Route<dynamic> route) =>
                                                        false);
                                                } 
                                                on UnauthorisedException catch (e){
                                                   Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              e.toMap()["msg"].toString())));
                                                }
                                                catch (e) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              e.toString())));
                                                  // _showSnackBar(e.toString());
                                                  log('Error in signIn API: ' +
                                                      e.toString());
                                                  return;
                                                }
                                              }
                                            },
                                            child: Center(
                                              child: Text(
                                                'Login',
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'New to Q Me Partners?',
                        style: TextStyle(fontFamily: 'Montserrat'),
                      ),
                      SizedBox(width: 5.0),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(SignUpScreen.id);
                          logger.d('Register button pressed');
                        },
                        child: Text(
                          'Register',
                          style: kLinkTextStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

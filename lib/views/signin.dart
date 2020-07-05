import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/views/profile.dart';
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
        verificationCompleted: (AuthCredential credential) async {
          AuthResult result = await _auth.signInWithCredential(credential);
          print("printing the credential");
          print(credential);

          FirebaseUser user = result.user;

          if (user != null) {
            var token = await user.getIdToken().then((result) async {
              idToken = result.token;
              print(" $idToken ");
              FocusScope.of(context)
                  .requestFocus(FocusNode()); // dismiss the keyboard
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Processing Data')));
              var response;
              try {
                response = await SubscriberRepository().signInFirebaseotp({
                  'token': idToken,
                });
                print("@@$response@@");

                log('SIGNIN API RESPONSE: ' + response.toString());

                await SubscriberRepository()
                    .storeSubscriberData(Subscriber.fromJson(response));

                Navigator.pushNamed(context, QueuesScreen.id);
              } catch (e) {
                print(" !!$e !!");
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
                // _showSnackBar(e.toString());
                log('Error in signIn API: ' + e.toString());
                return;
              }
            });
          } else {
            print("Error");
          }

          //This callback would gets called when verification is done auto maticlly
        },
        verificationFailed: (AuthException exception) {
          print("here is exception error");
          print(exception.message);
          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text(exception.message.toString())));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          _authVar = _auth;
          verificationIdVar = verificationId;

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
                    child: ThemedText(words: ['Q ME', 'Subsciber']),
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
                                    text: 'Login with OTP',
                                  ),
                                  new Tab(
                                    icon: const Icon(Icons.visibility_off),
                                    text: 'Login with Password',
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
                                      showOtpTextfield
                                          ? Card(
                                              child: new ListTile(
                                                title: TextFormField(
                                                  decoration: InputDecoration(
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8)),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey[200])),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      8)),
                                                          borderSide: BorderSide(
                                                              color: Colors
                                                                  .grey[300])),
                                                      filled: true,
                                                      fillColor: Colors.grey[100],
                                                      hintText: "Enter OTP"),
                                                  controller: _codeController,
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      !showOtpTextfield
                                          ? RaisedButton(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              onPressed: () {
                                                final phone = _phoneController
                                                    .text
                                                    .trim();
                                                print("phone number: $phone");
                                                loginUser(
                                                    countryCodeVal + phone,
                                                    context);
                                              },
                                              child: const Text(
                                                'GET OTP',
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(),
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
                                          shadowColor: Colors.greenAccent,
                                          color: Colors.green,
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
                                                final code =
                                                    _codeController.text.trim();
                                                try {
                                                  AuthCredential credential =
                                                      PhoneAuthProvider
                                                          .getCredential(
                                                              verificationId:
                                                                  verificationIdVar,
                                                              smsCode: code);

                                                  AuthResult result =
                                                      await _authVar
                                                          .signInWithCredential(
                                                              credential);

                                                  FirebaseUser user =
                                                      result.user;

                                                  if (user != null) {
                                                    var token = await user
                                                        .getIdToken()
                                                        .then((result) {
                                                      idToken = result.token;
                                                      print("@@ $idToken @@");
                                                    });
                                                  } else {
                                                    print("Error");
                                                  }
                                                } on PlatformException catch (e) {
                                                  print(
                                                      "Looking for Error code");
                                                  print(e.message);
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(e.code
                                                              .toString())));
                                                  print(e.code);
                                                  setState(() {
                                                    showOtpTextfield = false;
                                                  });
                                                } on Exception catch (e) {
                                                  print(
                                                      "Looking for Error message");
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              e.toString())));
                                                  setState(() {
                                                    showOtpTextfield = false;
                                                  });
                                                  print(e);
                                                }

                                                // email and password both are available here
                                                var response;
                                                try {
                                                  response =
                                                      await SubscriberRepository()
                                                          .signInFirebaseotp({
                                                    'token': idToken,
                                                  });
                                                  print("@@$response@@");

                                                  log('SIGNIN API RESPONSE: ' +
                                                      response.toString());

                                                  await SubscriberRepository()
                                                      .storeSubscriberData(
                                                          Subscriber.fromJson(
                                                              response));

                                                  Navigator.pushNamed(
                                                      context, QueuesScreen.id);
                                                } catch (e) {
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
                                                'Login with OTP',
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
                                          shadowColor: Colors.greenAccent,
                                          color: Colors.green,
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
                                                // email and password both are available here
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

                                                  Navigator.pushNamed(
                                                      context, QueuesScreen.id);
                                                } catch (e) {
                                                  print(" !!$e !!");
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
                                                'Login with password ',
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

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/views/queues.dart';
import 'package:qme_subscriber/widgets/button.dart';
import 'package:qme_subscriber/widgets/text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/app_exceptions.dart';
import '../repository/user.dart';
import 'signup.dart';

class OtpPage extends StatefulWidget {
  static const id = '/otpPage';

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Map<String, String> formData = {};
  var idToken;
  var _fcmToken;
  final formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Builder(
        builder: (context) => Form(
          key: formKey,
          child: KeyboardAvoider(
            autoScroll: true,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MyBackButton(),
                    Container(
                        padding: EdgeInsets.only(left: 20),
                        child: ThemedText(words: ['Hop', 'In'])),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical:
                                MediaQuery.of(context).size.height * 0.15),
                        child: Column(
                          children: <Widget>[
                            Card(
                              child: new ListTile(
                                title: TextFormField(
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          borderSide: BorderSide(
                                              color: Colors.grey[200])),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300])),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      hintText: "Enter OTP"),
                                  controller: _codeController,
                                ),
                              ),
                            ),
                            SizedBox(height: 50.0),
                            Container(
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.greenAccent,
                                color: Colors.green,
                                elevation: 7.0,
                                child: InkWell(
                                  onTap: () async {
                                    final code = _codeController.text.trim();
                                    try {
                                      AuthCredential credential =
                                          PhoneAuthProvider.getCredential(
                                              verificationId: verificationIdOtp,
                                              smsCode: code);

                                      AuthResult result = await authOtp
                                          .signInWithCredential(credential);

                                      FirebaseUser userFireBAse = result.user;

                                      if (userFireBAse != null) {
                                        var token = await userFireBAse
                                            .getIdToken()
                                            .then((result) {
                                          idToken = result.token;
                                          formData['token'] = idToken;
                                          print("@@ $idToken @@");
                                        });

                                        log('$formData');
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();

                                        formData['owner'] =
                                            prefs.getString('ownerSignup');
                                        formData['category'] =
                                            prefs.getString('categorySignup');

                                        formData['address'] =
                                            prefs.getString('addressSignup');

                                        formData['name'] =
                                            prefs.getString('nameSignup');

                                        formData['latitude'] =
                                            prefs.getString('latitudeSignup');

                                        formData['longitude'] =
                                            prefs.getString('longitudeSignup');
                                        formData['phone'] =
                                            prefs.getString('userPhoneSignup');
                                        formData['password'] = prefs
                                            .getString('userPasswordSignup');
                                        formData['cpassword'] = prefs
                                            .getString('userCpasswordSignup');
                                        formData['email'] = prefs.getString(
                                          'userEmailSignup',
                                        );
                                        _fcmToken = prefs.getString(
                                          'fcmToken',
                                        );
                                        Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Processing Data'),
                                          ),
                                        );

                                        UserRepository user = UserRepository();
                                        // Make SignUp API call

                                        var response;
                                        try {
                                          response =
                                              await SubscriberRepository()
                                                  .signUp(formData);
                                          log(response.toString());
                                        } catch (e) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(e.toString())));
                                          log('Error: ' + e.toString());

                                          return;
                                        }

                                        print("@# $response#@");
                                        print("@# ${response['msg']}#@");
                                        if (response['msg'] ==
                                            'Registration successful') {
                                          log('SignUp SUCCESSFUL');
                                          try {
                                            // SignIn the user
                                            response =
                                                await SubscriberRepository()
                                                    .signInFirebaseotp({
                                              'token': formData['token'],
                                            });
                                            log(response.toString());
                                          } catch (e) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())));
                                            log('Error: ' + e.toString());
                                            return;
                                          }

                                          if (response['isSubscriber'] !=
                                                  null &&
                                              response['isSubscriber'] ==
                                                  true) {
                                            // SignIn success

                                            // Store tokens into memory
                                            formData.putIfAbsent(
                                                'id', () => response['id']);
                                            formData.putIfAbsent('accessToken',
                                                () => response['accessToken']);
                                            formData.putIfAbsent('refreshToken',
                                                () => response['refreshToken']);
                                            await SubscriberRepository()
                                                .storeSubscriberData(
                                              Subscriber.fromJson(
                                                formData,
                                              ),
                                            );

                                            // Store fcm info DB
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
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

                                            // Navigate to QueuesPage
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        QueuesScreen(
                                                          subscriberId:
                                                              response['id'],
                                                        )));
                                          } else if (response['msg'] ==
                                                  "Invalid Credential" ||
                                              response['error'] != null) {
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                              response['msg'] != null
                                                  ? response['msg']
                                                  : response['error']
                                                      .toString(),
                                            )));
                                          } else {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Some unexpected error occurred')));
                                          }
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'SignUp failed:${response['msg']}')));
                                        }
                                      } else {
                                        print("SignUp failed");
                                        return;
                                      }
                                    } on PlatformException catch (e) {
                                      print("Looking for Error code");
                                      print(e.message);
                                      Navigator.of(context).pop();

                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Verification Failed"),
                                              content: Text(e.code.toString()),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("OK"),
                                                  textColor: Colors.white,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      print(e.code);
                                    } on Exception catch (e) {
                                      Navigator.of(context).pop();

                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Verification Failed"),
                                              content: Text(e.toString()),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("OK"),
                                                  textColor: Colors.white,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      print("Looking for Error message");
                                      print(e);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'SIGNUP',
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
                            SizedBox(
                              height: MediaQuery.of(context).viewInsets.bottom,
                            )
                          ],
                        )),
                  ]),
            ),
          ),
        ),
      )),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/receptions.dart';
import 'package:qme_subscriber/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.025),
                        child: Center(
                          child: Hero(
                          tag: 'hero',
                          child: new CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 80.0,
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: SvgPicture.asset("assets/images/otpSvg.svg"),
                            ),
                          ),
                        ),
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical:
                                MediaQuery.of(context).size.height * 0.15),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "OTP Verification",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 25.0),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.03,
                            ),
                            Text("Enter OTP sent to mobile number"),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            PinEntryTextField(
                              fieldWidth:
                                  MediaQuery.of(context).size.width * 0.1,
                              fields: 6,

                              onSubmit: (String pin) {
                                _codeController.text = pin;
                              }, // end onSubmit
                            ),
                            SizedBox(height: 50.0),
                            Container(
                              height: 50.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(20.0),
                                shadowColor: Colors.blueAccent,
                                color: Theme.of(context).primaryColor,
                                elevation: 7.0,
                                child: InkWell(
                                  onTap: () async {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Processing Data'),
                                      ),
                                    );
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
                                          logger.d("@@ $idToken @@");
                                        });

                                        logger.d('$formData');
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        if (loginPage == "SignUp") {
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

                                          formData['longitude'] = prefs
                                              .getString('longitudeSignup');
                                          formData['phone'] = prefs
                                              .getString('userPhoneSignup');
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

                                          UserRepository user =
                                              UserRepository();
                                          // Make SignUp API call

                                          var response;
                                          try {
                                            response =
                                                await SubscriberRepository()
                                                    .signUp(formData);
                                            logger.d(response.toString());
                                          } catch (e) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())));
                                            logger.d('Error: ' + e.toString());

                                            return;
                                          }

                                          logger.d("@# $response#@");
                                          if (response['msg'] ==
                                              'Registration successful') {
                                            logger.d('SignUp SUCCESSFUL');
                                            try {
                                              // SignIn the user
                                              response =
                                                  await SubscriberRepository()
                                                      .signInFirebaseotp({
                                                'token': formData['token'],
                                              });
                                              logger.d(response.toString());
                                            } on UnauthorisedException catch (e) {
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content: Text(e
                                                          .toMap()["msg"]
                                                          .toString())));
                                              logger
                                                  .d('Error: ' + e.toString());
                                              return;
                                            } catch (e) {
                                              Scaffold.of(context).showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text(e.toString())));
                                              logger
                                                  .d('Error: ' + e.toString());
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
                                              formData.putIfAbsent(
                                                  'accessToken',
                                                  () =>
                                                      response['accessToken']);
                                              formData.putIfAbsent(
                                                  'refreshToken',
                                                  () =>
                                                      response['refreshToken']);
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
                                              logger.d(
                                                  "fcm token Api: $responsefcm");
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString(
                                                  'fcmToken', _fcmToken);

                                              // Navigate to QueuesPage
                                              Navigator.of(context)
                                                  .pushNamedAndRemoveUntil(
                                                      ReceptionsScreen.id,
                                                      (Route<dynamic> route) =>
                                                          false);
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
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content:
                                                      Text('Processing Data')));
                                          _fcmToken =
                                              prefs.getString('fcmToken');
                                          var response;
                                          try {
                                            response =
                                                await SubscriberRepository()
                                                    .signInFirebaseotp({
                                              'token': idToken,
                                            });
                                            logger.d("@@$response@@");

                                            ('SIGNIN API RESPONSE: ' +
                                                response.toString());

                                            await SubscriberRepository()
                                                .storeSubscriberData(
                                                    Subscriber.fromJson(
                                                        response));
                                            await SubscriberRepository()
                                                .storeSubscriberData(
                                                    Subscriber.fromJson(
                                                        response));

                                            var responsefcm =
                                                await SubscriberRepository()
                                                    .fcmTokenSubmit({
                                              'token': _fcmToken,
                                            }, response['accessToken']);
                                            logger.d(
                                                "fcm token Api: $responsefcm");
                                            logger.d(
                                                "fcm token  Apiresponse: ${responsefcm['status']}");
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString(
                                                'fcmToken', _fcmToken);
                                            // Navigator.pushNamed(
                                            //     context, ReceptionsScreen.id);
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    ReceptionsScreen.id,
                                                    (Route<dynamic> route) =>
                                                        false);
                                          } on UnauthorisedException catch (e) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content: Text(e
                                                        .toMap()["msg"]
                                                        .toString())));
                                          } catch (e) {
                                            Scaffold.of(context).showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())));
                                            // _showSnackBar(e.toString());
                                            logger.d('Error in signIn API: ' +
                                                e.toString());
                                            return;
                                          }
                                        }
                                      } else {
                                        logger.d("SignUp failed");
                                        return;
                                      }
                                    } on PlatformException catch (e) {
                                      logger.d("Looking for Error code");
                                      logger.d(e.message);
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
                                      logger.d(e.code);
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
                                      logger.d(e);
                                    }
                                  },
                                  child: Center(
                                    child: Text(
                                      'VERIFY',
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

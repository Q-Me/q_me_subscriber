import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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
  String mobileNumber = "Mobile number";
  final formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  fcmTokenSet(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');
    var responsefcm = await SubscriberRepository().fcmTokenSubmit({
      'token': _fcmToken,
    }, accessToken);
    logger.d("fcm token Api: $responsefcm");
    prefs.setString('fcmToken', _fcmToken);
  }

  signInUser(BuildContext context) async {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Processing Data')));
    var response;
    try {
      response = await SubscriberRepository().signInFirebaseotp({
        'token': idToken,
      });
      logger.d("@@$response@@");
      await SubscriberRepository()
          .storeSubscriberData(Subscriber.fromJson(response));
      fcmTokenSet(response['accessToken']);

      Navigator.of(context).pushNamedAndRemoveUntil(
          ReceptionsScreen.id, (Route<dynamic> route) => false);
    } on UnauthorisedException catch (e) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text(e.toMap()["msg"].toString())));
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toMap()["msg"].toString())));
      // _showSnackBar(e.toString());
      logger.d('Error in signIn API: ' + e.toMap()["msg"].toString());
      return;
    }
  }

  signUpUser(BuildContext context) async {
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text('Processing Data')));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    formData['owner'] = prefs.getString('ownerSignup');
    formData['category'] = prefs.getString('categorySignup');
    formData['address'] = prefs.getString('addressSignup');
    formData['name'] = prefs.getString('nameSignup');
    formData['latitude'] = prefs.getString('latitudeSignup');
    formData['longitude'] = prefs.getString('longitudeSignup');
    formData['phone'] = prefs.getString('userPhoneSignup');
    formData['password'] = prefs.getString('userPasswordSignup');
    formData['cpassword'] = prefs.getString('userCpasswordSignup');
    formData['email'] = prefs.getString(
      'userEmailSignup',
    );

    UserRepository user = UserRepository();
    // Make SignUp API call

    var response;
    try {
      response = await SubscriberRepository().signUp(formData);
      logger.d(response.toString());
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toMap()["msg"].toString())));
      logger.d('Error: ' + e.toMap()["msg"].toString());

      return;
    }
    logger.d("@# $response#@");
    if (response['msg'] == 'Registration successful') {
      logger.d('SignUp SUCCESSFUL');
      try {
        // SignIn the user
        response = await SubscriberRepository().signInFirebaseotp({
          'token': formData['token'],
        });
        logger.d(response.toString());
      } on UnauthorisedException catch (e) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(e.toMap()["msg"].toString())));
        logger.d('Error: ' + e.toString());
        return;
      } catch (e) {
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text(e.toMap()["msg"].toString())));
        logger.d('Error: ' + e.toString());
        return;
      }
      if (response['isSubscriber'] != null &&
          response['isSubscriber'] == true) {
        // Store tokens into memory
        formData.putIfAbsent('id', () => response['id']);
        formData.putIfAbsent('accessToken', () => response['accessToken']);
        formData.putIfAbsent('refreshToken', () => response['refreshToken']);
        await SubscriberRepository().storeSubscriberData(
          Subscriber.fromJson(
            formData,
          ),
        );
        fcmTokenSet(response['accessToken']);
        Navigator.of(context).pushNamedAndRemoveUntil(
            ReceptionsScreen.id, (Route<dynamic> route) => false);
      } else if (response['msg'] == "Invalid Credential" ||
          response['error'] != null) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
          response['msg'] != null
              ? response['msg']
              : response['error'].toString(),
        )));
      } else {
        Scaffold.of(context).showSnackBar(
            SnackBar(content: Text('Some unexpected error occurred')));
      }
    } else {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('SignUp failed:${response['msg']}')));
    }
  }

fetchPhoneNumber()async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
    _fcmToken = prefs.getString('fcmToken');
    setState(() {
      mobileNumber = prefs.get('userPhoneSignup');
    });
  }
  @override
  void initState(){
    fetchPhoneNumber();
    super.initState();
  }
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
                              backgroundColor: Colors.transparent,
                              radius: 60.0,
                              child: SvgPicture.asset("assets/images/user.svg"),
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
                             Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Enter OTP sent to: "),
                            Text("$mobileNumber", style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obsecureText: false,
                      animationType: AnimationType.fade,
                      validator: (v) {
                        if (v.length != 6) {
                          return "Please enter valid otp";
                        } else {
                          return null;
                        }
                      },
                      pinTheme: PinTheme(
                        inactiveFillColor: Colors.white,
                        activeFillColor:Colors.white,
                        inactiveColor: Theme.of(context).primaryColor,
                        activeColor: Theme.of(context).primaryColor
                      ),
                      animationDuration: Duration(milliseconds: 300),
                      enableActiveFill: true,
                      onCompleted: (pin) {
                        _codeController.text = pin;
                      },
                      onChanged: (pin) {
                        setState(() {
                           _codeController.text = pin;
                        });
                      },
                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        return true;
                      },
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
                                        if (loginPage == "SignUp") {
                                          signUpUser(context);
                                        } else {
                                          signInUser(context);
                                        }
                                      } else {
                                        logger.d("SignUp failed");
                                        return;
                                      }
                                    } on PlatformException catch (e) {
                                      logger.d("Looking for Error code");
                                      logger.d(e.message);
                                       String errorMessage;
                                  e.code.toString() == "ERROR_INVALID_VERIFICATION_CODE"
                                  ?errorMessage = "Invalid OTP was entered"
                                  :errorMessage = e.code.toString();
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text("Verification Failed"),
                                              content: Text(errorMessage),
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

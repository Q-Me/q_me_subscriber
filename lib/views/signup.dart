import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:qme_subscriber/views/otpPage.dart';
import 'package:qme_subscriber/views/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/keys.dart';
import '../bloc/signup.dart';
import '../constants.dart';
import '../model/subscriber.dart';
import '../repository/subscriber.dart';
import '../views/queues.dart';
import '../widgets/button.dart';
import '../widgets/formField.dart';
import '../widgets/text.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
class SignUpScreen extends StatefulWidget {
  static const id = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

var verificationIdOtp;
var authOtp;
String loginPage;

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneController = TextEditingController(text: "+91");
  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool passwordVisible;
  SignUpBloc signUpBloc;
  Subscriber subscriber;
  final _codeController = TextEditingController();
  final FirebaseMessaging _messaging = FirebaseMessaging();
  var _fcmToken;
  var idToken;
  bool checkedValue = false;
  bool showOtpTextfield = false;
  Future<void> _launched;

  // otp verification with firebase

  final List<String> subscriberCategory = [
    "Choose Category",
    "Saloon",
    "Grocery Store",
    "Supermarket",
    "Medical Store",
    "Airport"
  ];
  String selectedCategory; Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    passwordVisible = false;
    selectedCategory = subscriberCategory[0];
    signUpBloc = SignUpBloc();
    subscriber = Subscriber();
    super.initState();
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
    var _mapLocationController = TextEditingController();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Builder(
          builder: (context) => SingleChildScrollView(
            reverse: true,
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  MyBackButton(),
                  Container(
                      padding: EdgeInsets.only(left: 20),
                      child: ThemedText(words: ['Hop', 'In'])),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                    child: KeyboardAvoider(
                      child: Column(
                        children: <Widget>[
                          MyFormField(
                            required: true,
                            name: 'OWNER\'S NAME',
                            callback: (value) {
                              formData['owner'] = value;
                              subscriber.owner = value;
                            },
                          ),
                          SizedBox(height: 10.0),
                          MyFormField(
                            name: 'BUSINESS NAME',
                            required: true,
                            callback: (value) {
                              formData['name'] = value;
                              subscriber.name = value;
                            },
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                  labelText: 'Subscriber Category'),
                              items: subscriberCategory.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              hint: Text(selectedCategory),
                              value: selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  selectedCategory = value;
                                  log('Category selected:$selectedCategory');
                                  formData['category'] = selectedCategory;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'This field cannot be left blank';
                                } else {
                                  setState(() {
                                    formData['phone'] = value;
                                  });
                                  subscriber.phone = value;
                                }
                              },
                              decoration: kTextFieldDecoration.copyWith(
                                  labelText: "PHONE"),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          MyFormField(
                            name: 'ADDRESS',
                            required: true,
                            callback: (value) {
                              formData['address'] = value;
                              subscriber.address = value;
                            },
                          ),
                          TextFormField(
                            
                            onChanged: (value) {
                              formData['address'] = value;
                            },
                            controller: _mapLocationController,
                            showCursor: false,
                            readOnly: true,
                             validator: (value) {
                                if (value.isEmpty) {
                                  return 'This field cannot be left blank';
                                }
                             },
                            onTap: () {
                              log('Address field tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    resizeToAvoidBottomInset: true,
                                    apiKey: mapsApiKey,
                                    onPlacePicked: (result) {
                                      log('${result.geometry.location.lat},${result.geometry.location.lng}');

                                      _mapLocationController.text =
                                          '${result.geometry.location.lat},${result.geometry.location.lng}';

                                      subscriber.latitude =
                                          result.geometry.location.lat;
                                      formData['latitude'] =
                                          subscriber.latitude.toString();

                                      subscriber.longitude =
                                          result.geometry.location.lng;
                                      formData['longitude'] =
                                          subscriber.longitude.toString();

                                      Navigator.of(context).pop();
                                    },
                                    useCurrentLocation: true,
                                  ),
                                ),
                              );
                            },
                            
                            decoration: InputDecoration(
                              labelText: 'MAP LOCATION',
                              labelStyle: kLabelStyle,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.location_on),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  log('Location button clicked');
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          MyFormField(
                            keyboardType: TextInputType.emailAddress,
                            name: 'EMAIL',
                            required: false,
                            callback: (value) {
                              formData['email'] = value;
                              subscriber.email = value;
                            },
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            // Password
                            obscureText: passwordVisible,
                            validator: (value) {
                             Pattern pattern =
                                    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])';
                                RegExp regex = new RegExp(pattern);
                                if (value.length < 6 || value.length > 20)
                                  return 'Password should be not be less than 6 characters';
                                else if (!regex.hasMatch(value)) {
                                  return 'Password must contain one numeric ,one upper and one lower case letter';
                                } {
                                formData['password'] = value;
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'PASSWORD',
                              labelStyle: kLabelStyle,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor)),
                              focusColor: Colors.lightBlue,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          TextFormField(
                            // Password
                            obscureText: passwordVisible,
                            validator: (value) {
                              if (value.length < 6)
                                return 'Password should be not be less than 6 characters';
                              else {
                                formData['cpassword'] = value;
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'CONFIRM PASSWORD',
                              labelStyle: kLabelStyle,
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.green)),
                              focusColor: Theme.of(context).primaryColorDark,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  // Based on passwordVisible state choose the icon
                                  passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  // Update the state i.e. toogle the state of passwordVisible variable
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          CheckboxListTileFormField(
                              title: FlatButton(
                                color: Colors.transparent,
                                onPressed: () => setState(() {
                                  _launched = _launchInBrowser(
                                      "https://q-me.flycricket.io/privacy.html");
                                }),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'I Agree to Privacy Policy',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              onSaved: (newValue) {
                                setState(() {
                                  checkedValue = newValue;
                                });
                              },
                              validator: (bool value) {
                                if (value) {
                                  return null;
                                } else {
                                  return 'You need to accept terms!';
                                }
                              },
                            ),
                          SizedBox(height: 50.0),
                          SignUpButton(
                              formKey: formKey,
                              formData: formData,
                              phoneController: _phoneController,
                              fcmToken: _fcmToken),
                          SizedBox(height: 20.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignUpButton extends StatefulWidget {
  const SignUpButton({
    Key key,
    @required this.formKey,
    @required this.formData,
    @required this.phoneController,
    @required this.fcmToken,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final Map<String, String> formData;
  final TextEditingController phoneController;
  final String fcmToken;

  @override
  _SignUpButtonState createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  var idToken;

  Future<bool> loginUser(String phone, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
          Navigator.pushNamed(context, OtpPage.id);
    _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 60),
        // verificationCompleted: (AuthCredential credential) async {
        //   AuthResult result = await _auth.signInWithCredential(credential);

        //   FirebaseUser user = result.user;

        //   if (user != null) {
        //     var token = await user.getIdToken().then((result) {
        //       idToken = result.token;
        //       widget.formData['token'] = idToken;
        //       print(" $idToken ");
        //     });
        //     log('${widget.formData}');
        //     SharedPreferences prefs = await SharedPreferences.getInstance();

        //     widget.formData['owner'] = prefs.getString('ownerSignup');
        //     widget.formData['category'] = prefs.getString('categorySignup');

        //     widget.formData['address'] = prefs.getString('addressSignup');

        //     widget.formData['name'] = prefs.getString('nameSignup');

        //     widget.formData['latitude'] = prefs.getString('latitudeSignup');

        //     widget.formData['longitude'] = prefs.getString('longitudeSignup');
        //     widget.formData['phone'] = prefs.getString('userPhoneSignup');
        //     widget.formData['password'] = prefs.getString('userPasswordSignup');
        //     widget.formData['cpassword'] =
        //         prefs.getString('userCpasswordSignup');
        //     widget.formData['email'] = prefs.getString(
        //       'userEmailSignup',
        //     );

        //     Scaffold.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text('Processing Data'),
        //       ),
        //     );

        //     // UserRepository user = UserRepository();
        //     // Make SignUp API call

        //     var response;
        //     try {
        //       response = await SubscriberRepository().signUp(widget.formData);
        //       log(response.toString());
        //     } catch (e) {
        //       Scaffold.of(context)
        //           .showSnackBar(SnackBar(content: Text(e.toString())));
        //       log('Error: ' + e.toString());

        //       return;
        //     }

        //     print("@# $response#@");
        //     print("@# ${response['msg']}#@");
        //     if (response['msg'] == 'Registration successful') {
        //       log('SignUp SUCCESSFUL');
        //       try {
        //         // SignIn the user
        //         response = await SubscriberRepository().signInFirebaseotp({
        //           'token': widget.formData['token'],
        //         });
        //         await SubscriberRepository()
        //             .storeSubscriberData(Subscriber.fromJson(response));
        //         Scaffold.of(context)
        //             .showSnackBar(SnackBar(content: Text('Processing Data')));

        //         var responsefcm = await SubscriberRepository().fcmTokenSubmit({
        //           'token': widget.fcmToken,
        //         }, response['accessToken']);
        //         print("fcm token Api: $responsefcm");
        //         print("fcm token  Apiresponse: ${responsefcm['status']}");
        //          prefs.setString('fcmToken', widget.fcmToken);
        //         log(response.toString());
        //       } catch (e) {
        //         Scaffold.of(context)
        //             .showSnackBar(SnackBar(content: Text(e.toString())));
        //         log('Error: ' + e.toString());
        //         return;
        //       }

        //       if (response['isSubscriber'] != null &&
        //           response['isSubscriber'] == true) {
        //         // SignIn success

        //         // Store tokens into memory
        //         widget.formData.putIfAbsent('id', () => response['id']);
        //         widget.formData
        //             .putIfAbsent('accessToken', () => response['accessToken']);
        //         widget.formData.putIfAbsent(
        //             'refreshToken', () => response['refreshToken']);
        //         await SubscriberRepository().storeSubscriberData(
        //           Subscriber.fromJson(
        //             widget.formData,
        //           ),
        //         );

        //         // Store profile info in local DB

        //         // Navigate to QueuesPage
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => QueuesScreen(
        //                       subscriberId: response['id'],
        //                     )));
        //       } else if (response['msg'] == "Invalid Credential" ||
        //           response['error'] != null) {
        //         Scaffold.of(context).showSnackBar(SnackBar(
        //             content: Text(
        //           response['msg'] != null
        //               ? response['msg']
        //               : response['error'].toString(),
        //         )));
        //       } else {
        //         Scaffold.of(context).showSnackBar(
        //             SnackBar(content: Text('Some unexpected error occurred')));
        //       }
        //     } else {
        //       Scaffold.of(context).showSnackBar(
        //           SnackBar(content: Text('SignUp failed:${response['msg']}')));
        //     }
        //   } else {
        //     print("Error");
        //   }

        //   //This callback would gets called when verification is done auto maticlly
        // },
        verificationFailed: (AuthException exception) {
          print(exception.message);
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(exception.message.toString())));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          authOtp = _auth;
          verificationIdOtp = verificationId;
          loginPage = "SignUp";
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Theme.of(context).primaryColor,
        elevation: 7.0,
        child: InkWell(
          onTap: () async {
            log('${widget.formData}');
            if (widget.formKey.currentState.validate()) {
              log('${widget.formData is Map<String, String>}');

              // check phone number length
              if (widget.formData['phone'].length != 13) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Phone number must have 10 digits with Country code')));
                return;
              }

              if (widget.formData['password'] != widget.formData['cpassword']) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')));
                return null;
              }

              FocusScope.of(context)
                  .requestFocus(FocusNode()); // dismiss the keyboard
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Processing Data')));

              final phone = widget.phoneController.text.trim();
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
                          child: Text("Disagree"),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignInScreen(),
                                ),
                                (route) => false);
                          },
                        ),
                        FlatButton(
                          child: Text("Agree"),
                          textColor: Colors.white,
                          color: Theme.of(context).primaryColor,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            loginUser(phone, context);
                          },
                        ),
                      ],
                    );
                  });
              SharedPreferences prefs = await SharedPreferences.getInstance();

              prefs.setString('ownerSignup', widget.formData['owner']);
              prefs.setString('categorySignup', widget.formData['category']);
              prefs.setString('nameSignup', widget.formData['name']);
              prefs.setString('addressSignup', widget.formData['address']);
              prefs.setString('latitudeSignup', widget.formData['latitude']);
              prefs.setString('longitudeSignup', widget.formData['longitude']);
              prefs.setString('userPhoneSignup', widget.formData['phone']);
              prefs.setString(
                  'userPasswordSignup', widget.formData['password']);
              prefs.setString(
                  'userCpasswordSignup', widget.formData['cpassword']);
              prefs.setString('userEmailSignup', widget.formData['email']);
              prefs.setString('fcmToken', widget.fcmToken);

              
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
    );
  }
}

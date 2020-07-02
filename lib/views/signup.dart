import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

import '../api/keys.dart';
import '../bloc/signup.dart';
import '../constants.dart';
import '../model/subscriber.dart';
import '../repository/subscriber.dart';
import '../views/queues.dart';
import '../widgets/button.dart';
import '../widgets/formField.dart';
import '../widgets/text.dart';

class SignUpScreen extends StatefulWidget {
  static const id = '/signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool passwordVisible;
  SignUpBloc signUpBloc;
  Subscriber subscriber;
  final List<String> subscriberCategory = [
    // TODO Dynamically fetch this list from api
    "Saloon",
    "Grocery Store",
    "Supermarket",
    "Medical Store",
    "Airport"
  ];
  String selectedCategory;

  @override
  void initState() {
    passwordVisible = false;
    selectedCategory = subscriberCategory[0];
    signUpBloc = SignUpBloc();
    subscriber = Subscriber();
    super.initState();
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
                            callback: (value) {
                              formData['name'] = value;
                              subscriber.name = value;
                            },
                          ),
                          SizedBox(height: 10.0),
                          DropdownButton<String>(
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
                          SizedBox(height: 10.0),
                          MyFormField(
                            keyboardType: TextInputType.phone,
                            name: 'PHONE',
                            required: true,
                            callback: (value) {
                              formData['phone'] = value;
                              subscriber.phone = value;
                            },
                          ),
                          SizedBox(height: 10.0),
                          MyFormField(
                            name: 'ADDRESS',
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
                            required: true,
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
                              if (value.length < 6)
                                return 'Password should be not be less than 6 characters';
                              else {
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
                          SizedBox(height: 50.0),
                          SignUpButton(formKey: formKey, formData: formData),
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

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    Key key,
    @required this.formKey,
    @required this.formData,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final Map<String, String> formData;

  @override
  Widget build(BuildContext context) {
    return Container(
      /*TODO Make this container into a button class
         using provider of form data, form key and
         onTap callback function
         */
      height: 50.0,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Theme.of(context).primaryColor,
        elevation: 7.0,
        child: InkWell(
          onTap: () async {
            log('$formData');
            if (formKey.currentState.validate()) {
              log('${formData is Map<String, String>}');

              // check phone number length
              if (formData['phone'].length != 10) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Phone number must have 10 digits')));
                return;
              }

              if (formData['password'] != formData['cpassword']) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')));
                return null;
              }

              FocusScope.of(context)
                  .requestFocus(FocusNode()); // dismiss the keyboard
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('Processing Data')));

              // Make SignUp API call
              var response;
              try {
                response = await SubscriberRepository().signUp(formData);
                log(response.toString());
              } catch (e) {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(e.toString())));
                log('Error: ' + e.toString());

                return;
              }

              if (response['msg'] == 'Registration successful') {
                log('SignUp SUCCESSFUL');
                try {
                  // SignIn the user
                  response = await SubscriberRepository().signIn({
                    'email': formData['email'],
                    'password': formData['password']
                  });
                  log(response.toString());
                } catch (e) {
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                  log('Error: ' + e.toString());
                  return;
                }

                if (response['isSubscriber'] != null &&
                    response['isSubscriber'] == true) {
                  // SignIn success

                  // Store tokens into memory
                  formData.putIfAbsent('id', () => response['id']);
                  formData.putIfAbsent(
                      'accessToken', () => response['accessToken']);
                  formData.putIfAbsent(
                      'refreshToken', () => response['refreshToken']);
                  await SubscriberRepository().storeSubscriberData(
                    Subscriber.fromJson(
                      formData,
                    ),
                  );

                  // Store profile info in local DB

                  // Navigate to QueuesPage
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QueuesScreen(
                                subscriberId: response['id'],
                              )));
                } else if (response['msg'] == "Invalid Credential" ||
                    response['error'] != null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                    response['msg'] != null
                        ? response['msg']
                        : response['error'].toString(),
                  )));
                } else {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Some unexpected error occurred')));
                }
              } else {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('SignUp failed:${response['msg']}')));
              }
              // Here there is no chance of invalid credentials because same password is used for signUp and sigIn
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

import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'dart:developer';

import '../widgets/button.dart';
import '../widgets/text.dart';
import '../widgets/formField.dart';

class SignUpPage extends StatefulWidget {
  static final id = 'signup';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool passwordVisible;

  @override
  void initState() {
    // TODO: implement initState
    passwordVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 30.0),
                          child: Column(
                            children: <Widget>[
                              MyFormField(
                                required: true,
                                name: 'OWNER\'S NAME',
                                callback: (value) {
                                  formData['owner'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                name: 'BUSINESS NAME',
                                callback: (value) {
                                  formData['bName'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                keyboardType: TextInputType.phone,
                                name: 'PHONE',
                                required: true,
                                callback: (value) {
                                  formData['phone'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                name: 'ADDRESS',
                                callback: (value) {
                                  formData['address'] = value;
                                },
                              ),
                              SizedBox(height: 10.0),
                              MyFormField(
                                keyboardType: TextInputType.emailAddress,
                                name: 'EMAIL',
                                required: true,
                                callback: (value) {
                                  formData['email'] = value;
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
                                    formData['pswd'] = value;
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'PASSWORD',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor)),
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
                                    formData['cpswd'] = value;
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'CONFIRM PASSWORD',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green)),
                                  focusColor:
                                      Theme.of(context).primaryColorDark,
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
                              Container(
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
                                      if (formKey.currentState.validate()) {
                                        log('$formData');

                                        // check phone number length
                                        if (formData['phone'].length != 10) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Phone number must have 10 digits')));
                                          return;
                                        }

                                        if (formData['pswd'] !=
                                            formData['cpswd']) {
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Passwords do not match')));
                                          return null;
                                        }

                                        FocusScope.of(context).requestFocus(
                                            FocusNode()); // dismiss the keyboard
                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Processing Data')));

                                        // TODO Make SignUp API call
                                        // TODO SignIn the user
                                        SnackBar(content: Text('Sigining in'));
                                        // Navigate to Nearby screen
                                        // TODO Check for other errors
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
                              ),
                              SizedBox(height: 20.0),
                              /*HollowSocialButton(
                                label: 'Signup with Facebook',
                                img: ImageIcon(
                                    AssetImage('assets/facebook.png')),
                                onPress: () {
                                  print('Signup with FB Pressed');
//                                Navigator.pushNamed(context, NearbyScreen.id);
                                },
                              ),
                              SizedBox(height: 20.0),
                              HollowSocialButton(
                                label: '  Signup with Google  ',
                                img: ImageIcon(
                                    AssetImage('assets/icons8-google-512.png')),
                                onPress: () {
                                  log('Signup with Google Pressed');
                                },
                              ),
                              SizedBox(height: 20.0),*/
                            ],
                          )),
                    ]),
              ),
            ),
          )),
    );
  }
}

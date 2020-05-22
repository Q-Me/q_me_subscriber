import 'package:flutter/material.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/bloc/signup.dart';
import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/views/queues.dart';
import 'dart:developer';

import '../widgets/button.dart';
import '../widgets/text.dart';
import '../widgets/formField.dart';

class SignUpScreen extends StatefulWidget {
  static final id = 'signup';

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showSpinner = false;
  final formKey = GlobalKey<FormState>();
  Map<String, String> formData = {};
  bool passwordVisible;
  SignUpBloc signUpBloc;

  @override
  void initState() {
    // TODO: implement initState
    passwordVisible = false;
    super.initState();
    signUpBloc = SignUpBloc();
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
                            },
                          ),
                          SizedBox(height: 10.0),
                          MyFormField(
                            name: 'BUSINESS NAME',
                            callback: (value) {
                              formData['name'] = value;
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
                                formData['password'] = value;
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
                              labelStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
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
            if (formKey.currentState.validate()) {
              log('$formData');
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

              if (response['msg'] == 'Registation successful') {
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
                  await SubscriberRepository().storeSubscriberData(
                    Subscriber.fromJson(
                      {
                        'id': response['id'],
                        'name': formData['name'],
                        'email': formData['email'],
                        'owner': formData['owner'],
                        'phone': formData['phone'],
                        'address': formData['address'],
                      },
                    ),
                  );

                  // Navigate to QueuesPage
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QueuesPage(
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
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('SignUp failed')));
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

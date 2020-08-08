import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:qme_subscriber/bloc/appointment_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/reception.dart';
import '../repository/reception.dart';
import '../repository/subscriber.dart';
import '../utilities/logger.dart';

class CustomerAppointment extends StatefulWidget {
  static const id = '/customerAppointment';
  final Reception reception;

  const CustomerAppointment({Key key,@required this.reception}) : super(key: key);
  @override
  _CustomerAppointmentState createState() => _CustomerAppointmentState();
}

class _CustomerAppointmentState extends State<CustomerAppointment> {
  final formKey = GlobalKey<FormState>();
  Future<void> _launched;
  String otpPin = "";
  String userName = 'abc xyz';
  String userPhoneNumber = '123456789';
  String userEmail = "abc@gmail.com";
  bool buttonEnabled = false;
  ReceptionRepository repository = ReceptionRepository();
  String title = "Appointment";
  MaterialColor color = Colors.blue;
  BuildContext parentContext;

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  dialogBox(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //return object of type dialoge
        return CupertinoAlertDialog(
          title: new Text("$title \n"),
          content: new Text(message ?? "Empty"),
          actions: <Widget>[
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                setState(() {
                  title = "Appointment";
                  color = Colors.blue;
                });
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                BlocProvider.of<AppointmentBloc>(parentContext).add(
                    AppointmentCancelRequested(
                        widget.reception.receptionId,
                        userPhoneNumber,
                        await SubscriberRepository()
                            .getAccessTokenFromStorage()));
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    if (otpPin.length == 4) {
      buttonEnabled = true;
    }
    EdgeInsets _pad;
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    _pad = EdgeInsets.only(
      top: cHeight * 0.01,
      bottom: cHeight * 0.01,
      left: cWidth * 0.04,
      right: cWidth * 0.04,
    );

    return BlocProvider(
      create: (context) {
        return AppointmentBloc(repository);
      },
      child: SafeArea(
          child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                elevation: 0,
                backgroundColor: color,
              ),
              body: BlocConsumer<AppointmentBloc, AppointmentState>(
                  builder: (context, state) {
                parentContext = context;
                logger.i(state);
                if (state is Loading) {
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AppointmentInitial ||
                    state is ProcessFailure) {
                  return Padding(
                      padding: _pad,
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                '${DateFormat('d MMMM y').format(widget.reception.startTime)} at ${DateFormat.jm().format(widget.reception.startTime)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              subtitle: Text(
                                '${widget.reception.endTime.difference(widget.reception.startTime).inMinutes} min, ends at ${DateFormat.jm().format(widget.reception.endTime)}',
                              ),
                            ),
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding: _pad,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.green,
                                        child: userName == null
                                            ? Icon(
                                                Icons.person,
                                                size: cHeight * 0.06,
                                              )
                                            : Text(
                                                userName
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.white),
                                              ),
                                        radius: cHeight * 0.05,
                                      )),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: cWidth * 0.03,
                                      vertical: cHeight * 0.04,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          userName ?? "",
                                          style: TextStyle(
                                            fontSize: cWidth * 0.05,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _launched =
                                      _makePhoneCall('tel:$userPhoneNumber');
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                            left: cWidth * 0.04,
                                            top: cHeight * 0.02,
                                          ),
                                          child: Icon(
                                            Icons.phone,
                                            color: Colors.grey,
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: cWidth * 0.07,
                                          top: cHeight * 0.02,
                                        ),
                                        child: Text(
                                          userPhoneNumber ?? "",
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  left: cWidth * 0.04,
                                  top: cHeight * 0.02,
                                ),
                                child: userEmail.isNotEmpty
                                    ? Icon(
                                        Icons.email,
                                        color: Colors.grey,
                                      )
                                    : Container(),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: cWidth * 0.07,
                                  top: cHeight * 0.02,
                                ),
                                child: Container(
                                  width: cWidth * 0.72,
                                  child: Text(
                                    userEmail ?? "",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.05),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      "OTP Verification",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25.0),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.03,
                                    ),
                                    Text("Enter OTP sent to mobile number"),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                    ),
                                    PinEntryTextField(
                                      showFieldAsBox: true,
                                      fieldWidth:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      fields: 4,
                                      onSubmit: (String pin) {
                                        setState(() {
                                          otpPin = pin;
                                        });
                                      }, // end onSubmit
                                    ),
                                    SizedBox(height: 50.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          height: 50.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: FlatButton(
                                            onPressed: () async {
                                                setState(() {
                                                  title = "Cancel Appointment";
                                                  color = Colors.red;
                                                });
                                                dialogBox(context, "Confirm",
                                                    "Do you really want to cancel");
                                              },
                                            child: Text(
                                              "Cancel",
                                              style: TextStyle(
                                                  color: Colors.red[700]),
                                            ),
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.red,
                                                    width: 1,
                                                    style: BorderStyle.solid),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                        ),
                                        Container(
                                          height: 50.0,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.3,
                                          child: Material(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                            shadowColor: buttonEnabled
                                                ? Colors.blue
                                                : Colors.grey,
                                            color: buttonEnabled
                                                ? Colors.blue
                                                : Colors.grey,
                                            elevation: 7.0,
                                            child: InkWell(
                                              onTap: !buttonEnabled
                                                  ? null
                                                  : () async {
                                                      print("Button Enabled");
                                                      BlocProvider.of<
                                                                  AppointmentBloc>(
                                                              context)
                                                          .add(AppointmentFinished(
                                                              widget.reception
                                                                  .receptionId,
                                                              userPhoneNumber,
                                                              await SubscriberRepository()
                                                                  .getAccessTokenFromStorage(),
                                                              int.parse(
                                                                  otpPin)));
                                                    },
                                              child: Center(
                                                child: Text(
                                                  'Done',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ));
                } else if (state is AppointmentCancelSuccessful ||
                    state is AppointmentFinishSuccessful) {
                  return Center(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(
                            backgroundColor: Colors.green),
                        Text(
                            "Please wait while your request is being processed..."),
                      ],
                    ),
                  );
                }
              }, listener: (context, state) {
                if (state is ProcessFailure) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content:
                        Text("An unexpected error occured...Please try again"),
                  ));
                } else if (state is AppointmentCancelSuccessful ||
                    state is AppointmentFinishSuccessful) {
                  // TODO: Pop the navigator here
                }
              }))),
    );
  }
}

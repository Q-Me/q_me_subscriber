import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:qme_subscriber/bloc/appointment_bloc.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/widgets/slotWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/reception.dart';
import '../repository/reception.dart';
import '../repository/subscriber.dart';
import '../utilities/logger.dart';

class AppointmentView extends StatefulWidget {
  static const id = '/appointment';
  final Reception reception;
  final Appointment appointment;

  AppointmentView({
    Key key,
    @required this.reception,
    @required this.appointment,
  }) : super(key: key) {
    logger.d('Reception:${reception.toJson()}\nSlot:\n${appointment.toJson()}');
  }

  @override
  _AppointmentViewState createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _launched;
  bool buttonEnabled = false;
  String otpPin = "";
  Reception get reception => widget.reception;
  Appointment get appointment => widget.appointment;
  String get userName => appointment.customerName;
  String get userPhoneNumber => appointment.customerPhone;
  ReceptionRepository repository = ReceptionRepository();
  BuildContext parentContext;

  double get cHeight => MediaQuery.of(context).size.height;
  double get cWidth => MediaQuery.of(context).size.width;

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
        //return object of type dialog
        return CupertinoAlertDialog(
          title: new Text("$title \n"),
          content: new Text(message ?? "Empty"),
          actions: <Widget>[
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: new Text("Yes"),
              onPressed: () async {
                BlocProvider.of<AppointmentBloc>(parentContext).add(
                    AppointmentCancelRequested(
                        reception.receptionId,
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

  void showSnackBar(String text, int seconds) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: seconds),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    if (otpPin.length == 4) {
      buttonEnabled = true;
    }
    EdgeInsets _pad = EdgeInsets.symmetric(
        vertical: cHeight * 0.01, horizontal: cWidth * 0.04);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Appointment"),
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: BlocProvider(
          create: (context) => AppointmentBloc(repository),
          child: BlocConsumer<AppointmentBloc, AppointmentState>(
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
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SlotListTile(
                        slot: Slot(
                          startTime: appointment.startTime,
                          endTime: appointment.endTime,
                        ),
                      ),
                      AppointmentDetail(
                        pad: _pad,
                        widget: Container(
                          padding: _pad,
                          child: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              userName.substring(0, 1).toUpperCase(),
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            ),
                            radius: MediaQuery.of(context).size.height * 0.04,
                          ),
                        ),
                        title: userName,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _launched = _makePhoneCall('tel:$userPhoneNumber');
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 20),
                            Padding(
                              padding: EdgeInsets.only(
                                left: cWidth * 0.04,
                                top: cHeight * 0.02,
                              ),
                              child: Icon(
                                Icons.phone,
                                color: Colors.grey,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: cWidth * 0.07,
                                top: cHeight * 0.02,
                              ),
                              child: Text(
                                userPhoneNumber,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20),
                          Padding(
                            padding: EdgeInsets.only(
                              left: cWidth * 0.04,
                              top: cHeight * 0.02,
                            ),
                            child: Icon(
                              Icons.note,
                              color: Colors.grey,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: cWidth * 0.07,
                              top: cHeight * 0.02,
                            ),
                            child: Text(
                              appointment.note,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: cHeight * 0.05),
                          child: Column(
                            children: <Widget>[
                              Text("OTP Verification",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      .copyWith(fontWeight: FontWeight.bold)),
                              SizedBox(height: cHeight * 0.03),
                              Text("Enter OTP for the appointment"),
                              SizedBox(height: cHeight * 0.05),
                              PinEntryTextField(
                                showFieldAsBox: true,
                                fieldWidth: cWidth * 0.1,
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
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      height: 50.0,
                                      child: FlatButton(
                                        onPressed: () async {
                                          dialogBox(context, "Confirm",
                                              "Do you really want to cancel");
                                        },
                                        child: Text(
                                          "Cancel",
                                          style:
                                              TextStyle(color: Colors.red[700]),
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
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 50.0,
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
                                          onTap: () async {
                                            if (!buttonEnabled) {
                                              showSnackBar(
                                                  'Please enter OTP to complete the appointment',
                                                  10);
                                              return;
                                            }

                                            print("Button Enabled");
                                            BlocProvider.of<AppointmentBloc>(
                                                    context)
                                                .add(
                                              AppointmentFinished(
                                                reception.receptionId,
                                                userPhoneNumber,
                                                await SubscriberRepository()
                                                    .getAccessTokenFromStorage(),
                                                int.parse(otpPin),
                                              ),
                                            );
                                          },
                                          child: Center(
                                            child: Text(
                                              'Done',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
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
                );
              } else if (state is AppointmentCancelSuccessful ||
                  state is AppointmentFinishSuccessful) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(backgroundColor: Colors.green),
                      Text(
                          "Please wait while your request is being processed..."),
                    ],
                  ),
                );
              }
              return null;
            },
            listener: (context, state) {
              if (state is ProcessFailure) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content:
                      Text("An unexpected error occured...Please try again"),
                ));
              } else if (state is AppointmentCancelSuccessful ||
                  state is AppointmentFinishSuccessful) {
                // TODO: Pop the navigator here
              }
            },
          ),
        ),
      ),
    );
  }
}

class AppointmentDetail extends StatelessWidget {
  const AppointmentDetail({
    Key key,
    @required EdgeInsets pad,
    @required this.widget,
    @required this.title,
  })  : _pad = pad,
        super(key: key);
  final Widget widget;
  final EdgeInsets _pad;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        widget,
        Container(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
      ],
    );
  }
}

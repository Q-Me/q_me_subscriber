import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/constants.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/receptions.dart';
import 'package:qme_subscriber/widgets/button.dart';
import 'package:qme_subscriber/widgets/slotWidgets.dart';

class CreateAppointmentArgs {
  final Slot slot;
  final String receptionId;
  const CreateAppointmentArgs(
      {@required this.receptionId, @required this.slot});
}

class CreateAppointment extends StatefulWidget {
  static const String id = '/createAppointment';
  final CreateAppointmentArgs args;

  CreateAppointment(this.args);

  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  Slot get slot => widget.args.slot;
  String get receptionId => widget.args.receptionId;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final phoneFocus = FocusNode();
  final noteFocus = FocusNode();
  final _phoneController = TextEditingController(text: "+91");
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, ReceptionsScreen.id);
            },
            child: Icon(Icons.arrow_back),
          ),
          title: Text('Create Appointment'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SlotListTile(slot: slot),
              Divider(),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Customer Name'),
                        controller: _nameController,
                        autofocus: true,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter some text';
                          }
                          if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                            return "Name should only contain letters";
                          }
                          return null;
                        },
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(phoneFocus);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration:
                            kTextFieldDecoration.copyWith(labelText: "PHONE"),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: _phoneController,
//                        focusNode: phoneFocus,
                        validator: (value) {
                          // Check for +91 and 10 digits after that
                          if (value.length > 3 &&
                              value.substring(0, 2) == '+91') {
                            return 'Number should start with +91';
                          }
                          if (value.substring(3).length != 10) {
                            return 'Number should be of 10 digits';
                          }
                          return null;
                        },
                        onFieldSubmitted: (v) {
                          FocusScope.of(context).requestFocus(noteFocus);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _noteController,
//                        focusNode: noteFocus,
                        decoration: InputDecoration(
                          labelText: 'Note',
                        ),
                      ),
                      SizedBox(height: 30),
                      Builder(
                        builder: (BuildContext context) {
                          return ThemedSolidButton(
                            text: "Book Appointment",
                            buttonFunction: () async {
                              if (formKey.currentState.validate()) {
                                // Dismiss the keyboard
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());

                                final String name = _nameController.text;
                                final String phone = _phoneController.text;
                                final String note = _noteController.text;
                                logger.d(
                                    'Name:$name\nPhone:$phone\nNote:$note\n${slot.toJson()}');
                                try {
                                  final String accessToken =
                                      await SubscriberRepository()
                                          .getAccessTokenFromStorage();
                                  final response = await ReceptionRepository()
                                      .bookAppointment(
                                    receptionId: receptionId,
                                    startTime: slot.startTime,
                                    endTime: slot.endTime,
                                    customerName: name,
                                    phone: phone,
                                    note: note,
                                    accessToken: accessToken,
                                  );
                                  if (response["msg"] ==
                                      "Slot Booked Successfully") {
                                    showSnackBar(
                                        "Appointment booked successfully", 5);

                                    final Appointment appointment =
                                        Appointment.fromJson(response["slot"]);
                                    return showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Booking Details'),
                                        content: SingleChildScrollView(
                                          child: AppointmentDetails(
                                              appointment: appointment),
                                        ),
                                        actions: [GoToHomeButton()],
                                      ),
                                    );
                                  }
                                } on BadRequestException catch (e) {
                                  logger.e(e.toString());
                                  showSnackBar(
                                      List.from(e.toMap()["error"]).join("\n"),
                                      5);
                                } catch (e) {
                                  logger.e(e.toString());
                                  showSnackBar(e.toString(), 5);
                                }
                              }
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

class GoToHomeButton extends StatelessWidget {
  const GoToHomeButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Go to Home'),
      onPressed: () {
        Navigator.pushReplacementNamed(context, ReceptionsScreen.id);
      },
    );
  }
}

class AppointmentDetails extends StatelessWidget {
  const AppointmentDetails({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return ListBody(
      children: [
        Text('Appointment Booked for:'),
        Text(
          '${appointment.customerName}\n${appointment.customerPhone}\n',
          style: Theme.of(context).textTheme.headline6,
        ),
        Text('Starts'),
        Text(
          '${DateFormat('d MMMM y').format(appointment.startTime)}\n${DateFormat.jm().format(appointment.startTime)}\nfor ${appointment.endTime.difference(appointment.startTime).inMinutes} min',
          style: Theme.of(context).textTheme.headline6,
        ),
        Text('till'),
        Text(
          '${DateFormat.jm().format(appointment.endTime)}\n',
          style: Theme.of(context).textTheme.headline6,
        ),
        Text('OTP for appointment is '),
        Text(
          appointment.otp.toString(),
          style: Theme.of(context).textTheme.headline6,
        ),
        Text(
          '\nPlease make a note of this Name and OTP and communicate OTP to the customer',
          style: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

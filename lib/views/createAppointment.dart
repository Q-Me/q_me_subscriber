import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme_subscriber/constants.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/receptions.dart';

class CreateAppointment extends StatefulWidget {
  static const String id = '/createAppointment';
  final Slot slot;
  final String receptionId;

  CreateAppointment({
    @required this.slot,
    this.receptionId,
  });

  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  Slot get slot => widget.slot;
  String get receptionId => widget.receptionId;

  final formKey = GlobalKey<FormState>();
  final phoneFocus = FocusNode();
  final noteFocus = FocusNode();
  final _phoneController = TextEditingController(text: "+91");
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void showSnackBar(BuildContext context, String text, int seconds) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          duration: Duration(seconds: seconds),
          action: SnackBarAction(
            label: 'Dismiss',
            onPressed: () {
              Scaffold.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
          title: Text('Create Appointment'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  '${DateFormat('d MMMM y').format(slot.startTime)} at ${DateFormat.jm().format(slot.startTime)}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                subtitle: Text(
                  '${slot.endTime.difference(slot.startTime).inMinutes} min, ends at ${DateFormat.jm().format(slot.endTime)}',
                ),
              ),
              Divider(),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          /*TODO make sure that only text with no number is
                           is put in this field*/
                        ),
                        controller: _nameController,
                        autofocus: true,
                        autovalidate: true,
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
                      TextFormField(
                        decoration:
                            kTextFieldDecoration.copyWith(labelText: "PHONE"),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        controller: _phoneController,
                        autovalidate: true,
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
                      TextFormField(
                        controller: _noteController,
//                        focusNode: noteFocus,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Note',
                          /* Note for the appointment
                           */
                        ),
                      ),
                      Builder(
                        builder: (BuildContext context) => RaisedButton(
                          child: Text('Book'),
                          onPressed: () async {
                            if (formKey.currentState.validate()) {
                              // Dismiss the keyboard
                              FocusScope.of(context).requestFocus(FocusNode());

                              final String name = _nameController.text;
                              final String phone = _phoneController.text;
                              final String note = _noteController.text;
                              logger.d(
                                  'Name:$name\nPhone:$phone\nNote:$note\n${slot.toJson()}');
                              try {
                                final String accessToken =
                                    await SubscriberRepository()
                                        .getAccessTokenFromStorage();
                                final response =
                                    await ReceptionRepository().bookAppointment(
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
                                  showSnackBar(context,
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
                                      actions: [
                                        FlatButton(
                                          child: Text('Go to Home'),
                                          onPressed: () {
                                            Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                    ReceptionsScreen.id));
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }
                              } on Exception catch (e) {
                                logger.e(e.toString());
                                showSnackBar(context, e.toString(), 5);
                              }
                            }
                          },
                        ),
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
          '\nPlease make a note of this Name and OTP and communicate it OTP to the customer',
          style: TextStyle(
            color: Colors.red,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}

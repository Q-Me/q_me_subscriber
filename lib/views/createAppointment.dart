import 'package:flutter/material.dart';

class CreateAppointment extends StatefulWidget {
  static const String id = '/createAppointment';
  @override
  _CreateAppointmentState createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: Text('hello'),
      ),
    ));
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:qme_subscriber/constants.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:qme_subscriber/widgets/text.dart';

class CreateQueueScreen extends StatefulWidget {
  static final id = 'createQueue';
  @override
  _CreateQueueScreenState createState() => _CreateQueueScreenState();
}

class _CreateQueueScreenState extends State<CreateQueueScreen> {
  DateTime _startDateTime = DateTime.now(), _endDataTime;

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 90)));
    if (picked != null) {
      setState(() {
        _startDateTime = picked;
      });
      log(_startDateTime.toString());
    }
  }

  Future _selectTime() async {
    TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );
    if (picked != null) {
      setState(() {
        _startDateTime
            .add(Duration(hours: picked.hour, minutes: picked.minute));
      });
      log(_startDateTime.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  title: Text('Create Queue'),
        leading: Icon(Icons.arrow_back_ios),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedText(
                words: ['Create Queue'],
                fontSize: 50,
              ),
              Text('Start', style: kBigTextStyle),
              Row(
                children: <Widget>[
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        _selectDate();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'DD-MM-YYYY',
                            labelText: getDate(_startDateTime),
                          ),
//                          onSaved: (String val) {},
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        _selectTime();
                      },
                      child: IgnorePointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Time',
                              labelText: getTime(_startDateTime)),
//                        maxLength: 10,
                          // validator: validateDob,
                          onSaved: (String val) {},
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

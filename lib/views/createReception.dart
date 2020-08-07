import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';

import '../constants.dart';
import '../utilities/time.dart';
import '../widgets/text.dart';

class CreateReceptionScreen extends StatefulWidget {
  static const id = '/createReception';
  final DateTime selectedDate;
  CreateReceptionScreen({this.selectedDate});

  @override
  _CreateReceptionScreenState createState() => _CreateReceptionScreenState();
}

class _CreateReceptionScreenState extends State<CreateReceptionScreen> {
  DateTime _startDateTime, _endDateTime;
  Map<String, dynamic> formData = {};
  final formKey = GlobalKey<FormState>();

  Future<DateTime> _selectDate(DateTime oldDateTime) async {
    DateTime dateTime = oldDateTime;
    final now = DateTime.now();
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(Duration(days: 90)));
    if (picked != null) {
      dateTime == null
          ? dateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              now.hour,
              now.minute,
            )
          : dateTime = DateTime(
              picked.year,
              picked.month,
              picked.day,
              dateTime.hour,
              dateTime.minute,
            );
//      logger.d('DATE PICKED\n${picked.toString()}\nDate Selected: ${dateTime.toString()}');
      return dateTime;
    } else {
      return oldDateTime;
    }
  }

  Future<DateTime> _selectTime(DateTime oldDateTime) async {
    DateTime newDateTime = oldDateTime;
    TimeOfDay picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (newDateTime != null) {
          newDateTime = DateTime(newDateTime.year, newDateTime.month,
              newDateTime.day, picked.hour, picked.minute);
          logger.d('Time added');
        } else {
          final now = DateTime.now();
          newDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            picked.hour,
            picked.minute,
          );
        }
      });
//      logger.d('TIME PICKED\n${picked.toString()}\nDate Selected: ${newDateTime.toString()}');
      return newDateTime;
    } else {
      return oldDateTime;
    }
  }

  @override
  void initState() {
    _startDateTime = widget.selectedDate;
    _endDateTime = widget.selectedDate;
    formData['starttime'] = _startDateTime;
    formData['endtime'] = _endDateTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //  title: Text('Create Queue'),
        leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: Column(
            children: <Widget>[
              ThemedText(words: ['Create', 'Reception'], fontSize: 50),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Start', style: kBigTextStyle.copyWith(fontSize: 26)),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: InkWell(
                            onTap: () async {
                              DateTime picked =
                                  await _selectDate(_startDateTime);
                              setState(() {
//                                logger.d('Date set state called');
                                _startDateTime = picked;
                                _endDateTime = picked;
                                formData['startDateTime'] = _startDateTime;
                              });
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController()
                                  ..text = _startDateTime != null
                                      ? getDate(_startDateTime)
                                      : null,
                                decoration:
                                    InputDecoration(hintText: 'DD-MM-YYYY'),
                                validator: (value) => value.isEmpty
                                    ? 'Date cannot be left empty'
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Flexible(
                          child: InkWell(
                            onTap: () async {
                              DateTime temp = await _selectTime(_startDateTime);
                              if (temp != null) {
                                setState(() {
                                  logger.d('Time Set state called');
                                  _startDateTime = temp;
                                  formData['startDateTime'] = _startDateTime;
                                });
                              } else {
                                logger.d('no time selected');
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController()
                                  ..text = _startDateTime != null
                                      ? getTime(_startDateTime)
                                      : null,
                                decoration: InputDecoration(hintText: 'hh:mm'),
                                validator: (value) => value.isEmpty
                                    ? 'Time cannot me left empty '
                                    : null,
                                onSaved: (String val) {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text('End', style: kBigTextStyle.copyWith(fontSize: 26)),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: InkWell(
                            onTap: () async {
                              DateTime picked = await _selectDate(_endDateTime);
                              setState(() {
                                logger.d('Date set state called');
                                _endDateTime = picked;
                                formData['endtime'] = _endDateTime;
                              });
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController()
                                  ..text = _endDateTime != null
                                      ? getDate(_endDateTime)
                                      : null,
                                decoration:
                                    InputDecoration(hintText: 'DD-MM-YYYY'),
                                validator: (value) => value.isEmpty
                                    ? 'Date cannot be left empty'
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Flexible(
                          child: InkWell(
                            onTap: () async {
                              DateTime temp = await _selectTime(_endDateTime);
                              if (temp != null) {
                                setState(() {
                                  logger.d('Time Set state called');
                                  _endDateTime = temp;
                                  formData['endtime'] = _endDateTime;
                                });
                              } else {
                                logger.d('no time selected');
                              }
                            },
                            child: IgnorePointer(
                              child: TextFormField(
                                controller: TextEditingController()
                                  ..text = _endDateTime != null
                                      ? getTime(_endDateTime)
                                      : null,
                                decoration: InputDecoration(hintText: 'hh:mm'),
                                validator: (value) => value.isEmpty
                                    ? 'Time cannot me left empty '
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    /*GestureDetector(
                      onTap: () {
                        // TODO Show following list of radio buttons in alert box
                        */ /*
                        Does not repeat
                        Every day
                        Every week
                        Custom...
                        */ /*
                        */ /*on custom selection show a new screen of schedule*/ /*
                      },
                      child: Row(
                        children: <Widget>[
//                        SizedBox(width: 7),
                          Icon(
                            Icons.refresh,
                            size: 25,
                            color: Colors.black45,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Does not repeat',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),*/
                    SizedBox(height: 5),
                    // TODO Drop down of slot durations for 5 min, 10 min, 15, min, 20 min, 30 min,1 hr
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Time per slot (in minutes)',
                        hintStyle: TextStyle(color: Colors.redAccent),
                        hoverColor: Colors.green,
                      ),
                      onSaved: (value) {
                        logger.d(value);
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'This field cannot be left empty';
                        else {
                          try {
                            formData['slot'] = int.parse(value);
                            return null;
                          } on FormatException catch (e) {
                            logger.d(e.toString());
                            return 'Please enter an integer value';
                          } catch (e) {
                            logger.e(e.toString());

                            return e.toString();
                          }
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Customers served in 1 slot',
                        hintStyle: TextStyle(color: Colors.redAccent),
                        hoverColor: Colors.green,
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'This field cannot be left empty';
                        else {
                          try {
                            formData['cust_per_slot'] = int.parse(value);
                            return null;
                          } on FormatException catch (e) {
                            logger.d(e.toString());
                            return 'Please enter an integer value';
                          } catch (e) {
                            logger.e(e.toString());
                            return e.toString();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Provider.value(
                  value: formData,
                  child: CreateReceptionButton(formKey: formKey)),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateReceptionButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  CreateReceptionButton({@required this.formKey});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> formData = Provider.of<Map<String, dynamic>>(context);
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () async {
            if (formKey.currentState.validate()) {
              logger.d('Form Valid $formData');

              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Creating reception...'),
                duration: Duration(seconds: 1),
              ));

              String msgToShow;
              try {
                final String accessToken =
                    await SubscriberRepository().getAccessTokenFromStorage();
                final response = await ReceptionRepository().createReception(
                  startTime: formData['starttime'],
                  endTime: formData['endtime'],
                  slotDurationInMinutes: formData['slot'],
                  customerPerSlot: formData['cust_per_slot'],
                  accessToken: accessToken,
                );

                msgToShow = response;
              } catch (e) {
                logger.e(e.toString());
                // Show persistent snack bar with error
                msgToShow = e.toString();
                return;
              }
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(msgToShow),
                  duration: Duration(seconds: 5),
                ),
              );
              // TODO add the reception to the list of all receptions in the receptions bloc
              if (msgToShow == 'Counter Created Successfully') {
                Navigator.pop(context);
              }
              return;
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Create Reception',
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
    );
  }
}

import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qme_subscriber/repository/queue.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import '../views/queues.dart';
import '../constants.dart';
import '../utilities/time.dart';
import '../widgets/text.dart';

class CreateQueueScreen extends StatefulWidget {
  static const id = '/createQueue';
  @override
  _CreateQueueScreenState createState() => _CreateQueueScreenState();
}

class _CreateQueueScreenState extends State<CreateQueueScreen> {
  DateTime _startDateTime, _endDateTime;
  Map<String, dynamic> formData = {};
  int avgTime, maxPeople;
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
      log('DATE PICKED\n${picked.toString()}\nDate Selected: ${dateTime.toString()}');
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
          log('Time added');
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
      log('TIME PICKED\n${picked.toString()}\nDate Selected: ${newDateTime.toString()}');
      return newDateTime;
    } else {
      return oldDateTime;
    }
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
              ThemedText(words: ['Create Queue'], fontSize: 50),
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
                                log('Date set state called');
                                _startDateTime = picked;
                                formData['startDateTime'] = picked;
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
                                  log('Time Set state called');
                                  _startDateTime = temp;
                                  formData['startDateTime'] = _startDateTime;
                                });
                              } else {
                                log('no time selected');
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
                                log('Date set state called');
                                _endDateTime = picked;
                                formData['endDateTime'] = _endDateTime;
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
                                  log('Time Set state called');
                                  _endDateTime = temp;
                                  formData['endDateTime'] = _endDateTime;
                                });
                              } else {
                                log('no time selected');
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
                    SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Average Time per token (in minutes)',
                        hintStyle: TextStyle(color: Colors.redAccent),
                        hoverColor: Colors.green,
                      ),
                      onSaved: (value) {
                        log(value);
                      },
                      validator: (value) {
                        if (value.isEmpty)
                          return 'This field cannot be left empty';
                        else {
                          try {
                            avgTime = int.parse(value);
                            formData['avgTime'] = avgTime;
                            log("Everything in avgTime is ok");
                            return null;
                          } on FormatException catch (e) {
                            log(e.toString());
                            return 'Please enter an integer value';
                          } catch (e) {
                            return e.toString();
                          }
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Maximum number of people allowed in queue',
                        hintStyle: TextStyle(color: Colors.redAccent),
                        hoverColor: Colors.green,
                      ),
                      validator: (value) {
                        if (value.isEmpty)
                          return 'This field cannot be left empty';
                        else {
                          try {
                            maxPeople = int.parse(value);
                            formData['max_allowed'] = value;
                            log("Everything in maxPeople is ok");
                            return null;
                          } on FormatException catch (e) {
                            log(e.toString());
                            return 'Please enter an integer value';
                          } catch (e) {
                            return e.toString();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              CreateQueueButton(
                formKey: formKey,
                formData: formData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateQueueButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> formData;
  CreateQueueButton({@required this.formKey, @required this.formData});
  @override
  Widget build(BuildContext context) {
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
            log('${formData.toString()}');
            if (formKey.currentState.validate()) {
              log('Form Valid');

              // Prepare the request
              Map<String, String> newFormData = {
                'start_date_time': getApiDateTime(formData['startDateTime']),
                'end_date_time': getApiDateTime(formData['endDateTime']),
                'avg_time_on_counter': formData['avgTime'].toString(),
                'max_allowed': formData['max_allowed'].toString(),
              };
              log('Request:' + newFormData.toString());

              final String accessToken =
                  await SubscriberRepository().getAccessTokenFromStorage();

              // Call api to create queue
              var response;
              try {
                response = await QueueRepository().createQueue(
                    queueDetails: newFormData, accessToken: accessToken);
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(response['msg']),
                ));
              } catch (e) {
                log('Error in creating queue API: ' + e.toString());
                // if queue creating failed show a message with the error
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(e.toString()),
                ));
                return;
              }
              // If queue created successfully then
              Navigator.pushNamed(context, QueuesScreen.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Create Queue',
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

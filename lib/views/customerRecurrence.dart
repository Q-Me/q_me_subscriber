import 'package:date_utils/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/receptions.dart';
import 'package:weekday_selector/weekday_selector.dart';

class CustomerRecurrence extends StatefulWidget {
  static const id = '/CustomerRecurrence';
  final String startTime;
  final String endTime;
  final String customersInSlot;
  final String slotDuration;

  CustomerRecurrence({
    Key key,
    @required this.startTime,
    @required this.endTime,
    @required this.customersInSlot,
    @required this.slotDuration,
  }) : super(key: key);

  @override
  _CustomerRecurrenceState createState() => _CustomerRecurrenceState();
}

var cur = DateTime.now();
enum SingingCharacter { lafayette, jefferson }

SingingCharacter _character = SingingCharacter.lafayette;

class _CustomerRecurrenceState extends State<CustomerRecurrence> {
List weekdays = [0, 1, 2, 3, 4, 5, 6];
  DateTime _selectedDate = DateTime.now();
final values = List.filled(7, true);
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  String displayMonth;
  String repeatsTill;
  DateTime _selectedDate1 = cur.add(
    Duration(days: 30),
  );
  void _launchStartDate(BuildContext context) async {
    _selectedDate = _selectedDate1;
    await selectDateFromPicker(context);
    setState(() {
      _selectedDate1 = _selectedDate;
    });
  }

  Future<String> selectDateFromPicker(BuildContext context) async {
    DateTime _date = DateTime.now().add(Duration(days: 365));
    DateTime d = DateTime(1960);

    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: d,
      lastDate: _date,
    );

    if (selected != null) {
      _selectedDate = selected;
      repeatsTill = selected.toString();
      displayMonth = Utils.formatMonth(selected);
    }
    setState(() {
      repeatsTill = selected.toString();
    });
    return displayMonth;
  }
  @override
  void initState() {
    repeatsTill = widget.endTime;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets _pad;
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    _pad = EdgeInsets.only(
      top: cHeight * 0.05,
      bottom: cHeight * 0.01,
      left: cWidth * 0.04,
      right: cWidth * 0.04,
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Customer Recurrence"),
          elevation: 0,
        ),
        body: Padding(
          padding: _pad,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      left: cWidth * 0.035, bottom: cHeight * 0.02),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "REPEATS ON",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                    child: WeekdaySelector(
                  fillColor: Colors.transparent,
                  elevation: 0.1,
                  selectedFillColor: Theme.of(context).primaryColor,
                  color: Colors.black87,
                  onChanged: (int day) {
                    setState(() {
                      final index = day % 7;
                      values[index] = !values[index];
                    });
                  },
                  values: values,
                )),
                Container(
                  height: 1,
                  color: Colors.grey,
                  margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: cWidth * 0.035,
                    bottom: cHeight * 0.02,
                    top: cHeight * 0.05,
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ENDS On",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Column(
                  children: <Widget>[
                    ListTile(
                      title: const Text('NEVER'),
                      leading: Radio(
                        value: SingingCharacter.lafayette,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            if (value == SingingCharacter.lafayette) {
                              repeatsTill = widget.endTime.toString();
                            }
                            _character = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "ON  " +
                            '${_selectedDate1.day} ${DateFormat.MMM().format(_selectedDate1)} ${_selectedDate1.year}',
                      ),
                      onTap: () {
                        _launchStartDate(context);
                        _character = SingingCharacter.jefferson;
                      },
                      leading: Radio(
                        value: SingingCharacter.jefferson,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            repeatsTill = _selectedDate1.toString();
                            _character = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: cHeight * 0.15,
                ),
                Container(
                  height: 50.0,
                  margin: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Material(
                    borderRadius: BorderRadius.circular(20.0),
                    shadowColor: Colors.blue,
                    color: Theme.of(context).primaryColor,
                    elevation: 7.0,
                    child: InkWell(
                      onTap: () async {
                        weekdays.clear();
                        for (int i = 0; i < 7; i++) {
                          if (values[i] == true) {
                            setState(() {
                              weekdays.add(i);
                            });
                          }
                        }
                        try {
                          final String accessToken =
                              await SubscriberRepository()
                                  .getAccessTokenFromStorage();
                          final response =
                              await ReceptionRepository().repeatSchedule(
                            startTime: widget.startTime,
                            endTime: widget.endTime,
                            slot: widget.slotDuration,
                            custPerSlot: widget.customersInSlot,
                            daysOfWeek: weekdays,
                            repeatTill: repeatsTill,
                            accessToken: accessToken,
                          );
                          logger.d(response);
                          logger.d(response['msg']);
                          if (response['msg'] ==
                              'Counters Scheduled Successfully.') {
                                print("startTime:${widget.startTime}");
    print("endTime:${widget.endTime}");
    print("slot:${widget.startTime}");
    print("custPerSlot:${widget.customersInSlot}");
    print("daysOfWeek:$weekdays");
    print("repeatTill:$repeatsTill");
    print("acessToekn:$accessToken");
                            Navigator.pushReplacementNamed(
                                context, ReceptionsScreen.id);
                          }
                        } catch (e) {
                          logger.e(e.toString());
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text(e.toString()),
                          ));
                          return;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Center(
                          child: Text(
                            'Set Schedule',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:date_utils/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:weekday_selector/weekday_selector.dart';

class CustomerRecurrence extends StatefulWidget {
  static const id = '/CustomerRecurrence';
  @override
  _CustomerRecurrenceState createState() => _CustomerRecurrenceState();
}

var cur = DateTime.now();
enum SingingCharacter { lafayette, jefferson }

SingingCharacter _character = SingingCharacter.lafayette;

class _CustomerRecurrenceState extends State<CustomerRecurrence> {
  DateTime _selectedDate = DateTime.now();
  List weekdays = [0, 1, 2, 3, 4, 5, 6];

  final values = List.filled(7, true);

  DateTime _selectedDate = DateTime.now();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  String displayMonth;

  DateTime _selectedDate1 = cur.add(
    Duration(days: 30),
  );
  String displayMonth1 = "Jan";
  DateTime _selectedDate2 = DateTime.now();
  String displayMonth2 = "Jan";

  void _launchStartDate() async {
    _selectedDate = _selectedDate1;
    displayMonth1 = await selectDateFromPicker();
    setState(() {
      _selectedDate1 = _selectedDate;
    });
  }

  Future<String> selectDateFromPicker() async {
    DateTime _date = DateTime.now();
    DateTime d = DateTime(1960);

    DateTime selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: d,
      lastDate: _date,
    );

    if (selected != null) {
      _selectedDate = selected;
      displayMonth = Utils.formatMonth(selected);
    }
    return displayMonth;
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
                        _launchStartDate();
                      },
                      leading: Radio(
                        value: SingingCharacter.jefferson,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

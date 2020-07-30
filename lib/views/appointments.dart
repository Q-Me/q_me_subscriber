import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  static const String id = '/appointments';
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

bool display = false;

var cur = DateTime.now();

DateTime eDate = DateTime.now();
DateTime sDate = eDate.subtract(Duration(days: 7));

var data = [{}, {}];

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  String displayMonth;

  DateTime _selectedDate1 = cur.subtract(
    Duration(days: 30),
  );
  String displayMonth1 = "Jan";
  DateTime _selectedDate2 = DateTime.now();
  String displayMonth2 = "Jan";

  void _launchStartDate() async {
    display = false;
    _selectedDate = _selectedDate1;
    displayMonth1 = await selectDateFromPicker();
    setState(() {
      _selectedDate1 = _selectedDate;
    });
  }

  void _launchEndDate() async {
    display = true;
    _selectedDate = _selectedDate2;
    displayMonth2 = await selectDateFromPicker();
    setState(() {
      _selectedDate2 = _selectedDate;
    });
  }

  Future<String> selectDateFromPicker() async {
    DateTime _date = DateTime.now();
    DateTime d = DateTime(1960);
    if (display) {
      d = DateTime(
        _selectedDate1.year,
        _selectedDate1.month,
        _selectedDate1.day,
        00,
      );
    } else
      _date = DateTime(
        _selectedDate2.year,
        _selectedDate2.month,
        _selectedDate2.day,
        23,
      );

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

  Future<void> getData() async {
    sDate = _selectedDate1;
    eDate = DateTime(_selectedDate2.year, _selectedDate2.month,
        _selectedDate2.day, 23, 59, 59);
    print("Starting date: $sDate");
    print("End date: $eDate");
    // data = await apicall
  }

  @override
  Widget build(BuildContext context) {
    print(cur);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios)),
          title: Text("Appointments"),
        ),
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            print(data);
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError)
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text("Network Error"),
                      )
                    ],
                  ),
                );
              else
                return _transBuildList(
                  context,
                  data,
                );
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
      ),
    );
  }

  Widget _transBuildList(
    BuildContext context,
    dynamic data,
  ) {
    var len = data == null ? 0 : data.length + 1;

    return Scrollbar(
      child: ListView.builder(
        itemCount: len,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            bool karma = false;
            if (len == 1) karma = true;
            return dateView(karma);
          } else
            return listElement(
              context,
              len - index - 1,
              data,
            );
        },
      ),
    );
  }

  Widget dateView(
    bool karma,
  ) {
    var cHeight = MediaQuery.of(context).size.height;
    var cWidth = MediaQuery.of(context).size.width;
    EdgeInsets _pad = EdgeInsets.symmetric(
      vertical: cHeight * 0.018,
      horizontal: cWidth * 0.04,
      // bottom: cHeight * 0.015,
    );
    return Container(
      padding: _pad,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Card(
                  elevation: 3.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                      left: 10,
                      // top: 10,
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      size: cWidth * 0.085,
                    ),
                    title: Text(
                      "Start date",
                      style: TextStyle(
                        fontSize: cWidth * 0.04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      '${_selectedDate1.day} ${DateFormat.MMM().format(_selectedDate1)} ${_selectedDate1.year}',
                      style: TextStyle(
                        fontSize: cWidth * 0.043,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _launchStartDate();
                    },
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 3.0,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                      left: 10,
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      // color: Theme.Colors.yellow700Color,
                      size: cWidth * 0.085,
                    ),
                    title: Text(
                      "End date",
                      style: TextStyle(
                        fontSize: cWidth * 0.04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      '${_selectedDate2.day} ${DateFormat.MMM().format(_selectedDate2)} ${_selectedDate2.year}',
                      style: TextStyle(
                        fontSize: cWidth * 0.043,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _launchEndDate();
                    },
                  ),
                ),
              ),
            ],
          ),
          !karma
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                    top: cHeight * 0.2,
                  ),
                  child: Center(
                    child: Text(
                      "There are no Appoinments",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}

Widget listElement(
  BuildContext context,
  int index,
  dynamic data,
) {
  var cHeight = MediaQuery.of(context).size.height;
  var cWidth = MediaQuery.of(context).size.width;

  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: cWidth * 0.04,
      vertical: cHeight * 0.005,
    ),
    child: InkWell(
      onTap: null,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: cHeight * 0.005,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  trailing: Text(
                    "Booked",
                  ),
                  leading: Container(
                    child: CircleAvatar(
                      child: Icon(
                        Icons.border_color,
                      ),
                    ),
                    width: 32.0,
                    height: 32.0,
                    padding: EdgeInsets.all(2), // borde width
                    decoration: BoxDecoration(
                      // color: color, // border color
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    "Person" + " " + "Name",
                  ),
                  subtitle: Text(
                    "Phone",
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

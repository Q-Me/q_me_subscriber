import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/appointment.dart';

class SlotView extends StatefulWidget {
  static const String id = '/slot';
  final Reception reception;
  final Slot slot;

  SlotView({this.reception, this.slot}) {
    logger.d('Reception:${reception.toJson()}\nSlot:\n${slot.toJson()}');
  }

  @override
  _SlotViewState createState() => _SlotViewState();
}

bool display = false;

var cur = DateTime.now();

DateTime eDate = DateTime.now();
DateTime sDate = eDate.subtract(Duration(days: 7));

// var appointment = [{}, {}];
List appointment = [
  {
    "starttime": "2020-06-29T15:00:00.000Z",
    "endtime": "2020-06-29T15:15:00.000Z",
    "status": "CANCELLED",
    "note": "",
    "booked_by": "USER",
    "cust_name": "Kavya2",
    "cust_phone": "9898009900"
  },
  {
    "starttime": "2020-06-29T17:00:00.000Z",
    "endtime": "2020-06-29T17:15:00.000Z",
    "status": "CANCELLED",
    "note": "",
    "booked_by": "USER",
    "cust_name": "Kavya2",
    "cust_phone": "9898009900"
  },
  {
    "starttime": "2020-06-29T15:00:00.000Z",
    "endtime": "2020-06-29T15:15:00.000Z",
    "status": "UPCOMING",
    "note": "",
    "booked_by": "USER",
    "cust_name": "Kavya2",
    "cust_phone": "9898009900"
  }
];

class _SlotViewState extends State<SlotView> {
  Reception get reception => widget.reception;
  Slot get slot => widget.slot;

  @override
  Widget build(BuildContext context) {
    print(cur);

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios)),
              title: Text("Slots"),
            ),
            body: _transBuildList(context, appointment)));
  }

  Widget _transBuildList(
    BuildContext context,
    dynamic appointment,
  ) {
    var len = appointment == null ? 0 : appointment.length + 1;

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
              appointment,
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
          Text(
            "${DateFormat('d MMMM y').format(reception.startTime)}",
            style: TextStyle(
              fontSize: cWidth * 0.04,
              fontWeight: FontWeight.w400,
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TimeCard(
                  text: 'Start',
                  dateTime: DateTime.now(),
                ),
              ),
              Expanded(
                child: TimeCard(
                    text: 'End',
                    dateTime: DateTime.now().add(Duration(minutes: 90))),
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

class TimeCard extends StatelessWidget {
  final String text;
  final DateTime dateTime;

  TimeCard({@required this.text, @required this.dateTime});

  @override
  Widget build(BuildContext context) {
    String _addLeadingZeroIfNeeded(int value) {
      if (value < 10) return '0$value';
      return value.toString();
    }

    final String hourLabel = _addLeadingZeroIfNeeded(dateTime.hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(dateTime.minute);

    return Card(
      elevation: 3.0,
      child: ListTile(
        contentPadding: EdgeInsets.only(
          left: 10,
          // top: 10,
        ),
        leading: Icon(
          Icons.access_time,
          size: 36,
        ),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          '$hourLabel:$minuteLabel',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

Widget listElement(
  BuildContext context,
  int index,
  dynamic appointment,
) {
  var cHeight = MediaQuery.of(context).size.height;
  var cWidth = MediaQuery.of(context).size.width;
  final item = appointment[index]["cust_name"].toString();
  return Padding(
    padding: EdgeInsets.symmetric(
      horizontal: cWidth * 0.04,
      vertical: cHeight * 0.005,
    ),
    child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, AppointmentView.id,
              arguments: {"reception": null});
        },
        child: Dismissible(
          key: Key(item),
          onDismissed: (tap) {
            Scaffold.of(context)
                .showSnackBar(SnackBar(content: Text("$item Appointment Cancelled")));
          },
          background: Container(color: Colors.red),
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
                      trailing: Text(appointment[index]["status"],
                          style: appointment[index]["status"] == "UPCOMING"
                              ? TextStyle(color: Colors.green)
                              : appointment[index]["status"] == "DONE"
                                  ? TextStyle(color: Colors.blue)
                                  : appointment[index]["status"] == "UNBOOKED"
                                      ? TextStyle(color: Colors.grey)
                                      : TextStyle(color: Colors.red)),
                      leading: Container(
                        child: CircleAvatar(
                          child: Icon(
                            Icons.account_circle,
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
                      title: Text(appointment[index]["cust_name"]),
                      subtitle: Text(
                        appointment[index]["cust_phone"] +
                            "\n\nNote: " +
                            appointment[index]["note"],
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
        )),
  );
}

import 'package:flutter/material.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/widgets/slotWidgets.dart';

final List<Appointment> appointmentList = [
  Appointment.fromJson({
    "starttime": "2020-06-29T15:00:00.000Z",
    "endtime": "2020-06-29T15:15:00.000Z",
    "status": "CANCELLED",
    "note": "",
    "booked_by": "USER",
    "cust_name": "Kavya2",
    "cust_phone": "9898009900"
  }),
  Appointment.fromJson({
    "starttime": "2020-06-29T17:00:00.000Z",
    "endtime": "2020-06-29T17:15:00.000Z",
    "status": "CANCELLED",
    "note": "",
    "booked_by": "USER",
    "cust_name": "Kavya2",
    "cust_phone": "9898009900"
  })
];

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

class _SlotViewState extends State<SlotView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double get mediaHeight => MediaQuery.of(context).size.height;
  Reception get reception => widget.reception;
  Slot get slot => widget.slot;

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
            onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios)),
          title: Text("Slots"),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.018,
                horizontal: MediaQuery.of(context).size.width * 0.04,
                // bottom: cHeight * 0.015,
              ),
              child: SlotDetails(slot: slot),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  itemCount: appointmentList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    final Appointment appointment = appointmentList[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: mediaHeight * 0.005,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                trailing: Text(appointment.status),
                                leading: Container(
                                  child: CircleAvatar(
                                      child: Icon(Icons.account_circle)),
                                  width: 32.0,
                                  height: 32.0,
                                  padding: EdgeInsets.all(2), // borde width
                                  decoration: BoxDecoration(
                                    // color: color, // border color
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  appointment.customerName,
                                ),
                                subtitle: Text(
                                  appointment.customerPhone,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

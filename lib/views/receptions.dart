import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/bloc/receptions.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:qme_subscriber/widgets/fabsHomeScreen.dart';

import '../widgets/calenderItems.dart';

class ReceptionsScreen extends StatefulWidget {
  static const String id = '/appointments';
  @override
  _ReceptionsScreenState createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  DateTime selectedDate = DateTime.now();
  List<DateTime> markedDates = [
    DateTime.now().add(Duration(days: 1)),
    DateTime.now().add(Duration(days: 3)),
  ];

  onSelect(data) {
    logger.d("Selected Date -> $data");
  }

  ReceptionsBloc receptionsBloc;
  @override
  void initState() {
    receptionsBloc = ReceptionsBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FancyFab(),
        /*FloatingActionButton(
          child: Stack(
            children: <Widget>[
              FloatingActionButton(
                child: Text('Create appointment'),
                onPressed: () {
                  logger.d('appointment pressed');
                },
              ),
              FloatingActionButton(
                child: Text('Create reception'),
                onPressed: () {
                  logger.d('reception pressed');
                },
              ),
            ],
          ),
          onPressed: () {
            logger.d('FAB pressed');
          },
        )*/
        body: ChangeNotifierProvider.value(
          value: receptionsBloc,
          child: Column(
            children: <Widget>[
              /*Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Icon(
                  Icons.menu,
                  size: 30,
                ),
              ),*/
              CalendarStrip(
                startDate: startDate,
                endDate: endDate,
                onDateSelected: onSelect,
                dateTileBuilder: dateTileBuilder,
                iconColor: Colors.black87,
                monthNameWidget: monthNameWidget,
                markedDates: markedDates,
                containerDecoration: BoxDecoration(color: Colors.black12),
              ),
              Expanded(
                child: receptionsBloc
                            .getReceptionsByDate(selectedDate)
                            .length !=
                        0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: receptionsBloc
                            .getReceptionsByDate(selectedDate)
                            .length,
                        itemBuilder: (context, receptionsIndex) {
                          Reception reception = receptionsBloc
                              .getReceptionsByDate(selectedDate)
                              .elementAt(receptionsIndex);
                          return ListView.builder(
                            itemCount: reception.slotList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Slot slot = reception.slotList[index];

                              List<Widget> bookedBoxes = List.generate(
                                  slot.booked != null ? slot.booked : 0,
                                  (index) => Container(
                                        padding: EdgeInsets.all(20),
                                        margin: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Text('booked'),
                                      ));
                              List<Widget> unBookedBoxes = List.generate(
                                  slot.booked == null
                                      ? slot.customersInSlot
                                      : slot.customersInSlot - slot.booked,
                                  (index) => Container(
                                        padding: EdgeInsets.all(20),
                                        margin: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        child: Text('unbooked'),
                                      ));

                              final allBoxes = [
                                ...bookedBoxes,
                                ...unBookedBoxes,
                                Container(
                                  padding: EdgeInsets.all(20),
                                  margin: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                  ),
                                )
                              ];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 100,
                                      child: Opacity(
//                              opacity: index % 2 == 0 ? 1 : 0,
                                        opacity: 1,
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              getTime(slot.startTime),
                                              style: TextStyle(fontSize: 20),
                                              softWrap: true,
                                            ),
                                            Text(
                                              'to',
                                              style: TextStyle(fontSize: 20),
                                              softWrap: true,
                                            ),
                                            Text(
                                              getTime(slot.endTime),
                                              style: TextStyle(fontSize: 20),
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Wrap(
                                        children: allBoxes,
                                      ),
                                    )
                                    /*Wrap(

                              children: slot.appointments
                                  .map((e) => Container(
                                        padding: EdgeInsets.all(20),
                                        child: Icon(Icons.close),
                                      ))
                                  .toList(),
                            ),*/
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    : Text('sdg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/bloc/receptions.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:qme_subscriber/widgets/calenderItems.dart';
import 'package:qme_subscriber/widgets/fabsHomeScreen.dart';

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
    setState(() {
      receptionsBloc.date = selectedDate;
    });
  }

  addedReception() {}

  ReceptionsBloc receptionsBloc;
  @override
  void initState() {
    receptionsBloc = ReceptionsBloc(selectedDate);
    receptionsBloc.date = selectedDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Reception> filteredReceptions = receptionsBloc.getReceptionsByDate();
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FancyFab(),
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
                child: filteredReceptions.length != 0
                    ? ListView.builder(
                        itemCount: receptionsBloc.selectedDateReceptions.length,
                        itemBuilder: (context, receptionsIndex) {
                          Reception reception =
                              filteredReceptions[receptionsIndex];
                          logger.i('Showing reception: ${reception.toJson()}');
                          return ListView.builder(
                            itemCount: reception.slotList.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Slot slot = reception.slotList[index];

                              List<Widget> bookedBoxes = List.generate(
                                slot.booked != null ? slot.booked : 0,
                                (index) => BookedSeat(),
                              );
                              List<Widget> unBookedBoxes = List.generate(
                                  slot.booked == null
                                      ? slot.customersInSlot
                                      : slot.customersInSlot - slot.booked,
                                  (index) => UnbookedSeat());

                              final allBoxes = [
                                ...bookedBoxes,
                                ...unBookedBoxes,
                                AddOverride()
                              ];

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    SlotTiming(slot: slot),
                                    Expanded(
                                      child: Wrap(
                                        runSpacing: 3,
                                        spacing: 3,
                                        children: allBoxes,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        })
                    : Text('sdg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddOverride extends StatelessWidget {
  const AddOverride({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(),
      ),
      child: Icon(
        Icons.add,
      ),
    );
  }
}

class SlotTiming extends StatelessWidget {
  const SlotTiming({
    Key key,
    @required this.slot,
  }) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
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
    );
  }
}

class BookedSeat extends StatelessWidget {
  const BookedSeat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text('booked'),
    );
  }
}

class UnbookedSeat extends StatelessWidget {
  const UnbookedSeat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Text('unbooked'),
    );
  }
}

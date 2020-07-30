import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/bloc/receptions.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:qme_subscriber/widgets/calenderItems.dart';
import 'package:qme_subscriber/widgets/error.dart';
import 'package:qme_subscriber/widgets/fabsHomeScreen.dart';
import 'package:qme_subscriber/widgets/loader.dart';

class ReceptionsScreen extends StatefulWidget {
  static const String id = '/receptions';
  @override
  _ReceptionsScreenState createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  DateTime selectedDate = DateTime.now();
  List<DateTime> markedDates = [];

  onSelect(DateTime select) {
//    logger.d('Select functions: $select');
    receptionsBloc.date = select;
  }

  addedReception() {
    /*When coming back from Create Reception page*/
  }

  ReceptionsBloc receptionsBloc;
  @override
  void initState() {
    receptionsBloc = ReceptionsBloc(selectedDate);
    receptionsBloc.date = selectedDate;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                child: StreamBuilder<ApiResponse<List<Reception>>>(
                    stream: receptionsBloc.receptionsStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.COMPLETED:
                            if (snapshot.data.data.length == 0) {
                              return Text(
                                  'No reception found on ${Provider.of<ReceptionsBloc>(context).selectedDate.toString()}');
                            }
                            return ReceptionsListView(
                                receptions: snapshot.data.data);
                            break;
                          case Status.LOADING:
                            return Loading(
                                loadingMessage: snapshot.data.message);
                            break;
                          case Status.ERROR:
                            return Error(errorMessage: snapshot.data.message);
                            break;
                        }
                      } else {
                        return Text('No data');
                      }
                      return Container();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceptionsListView extends StatelessWidget {
  const ReceptionsListView({
    Key key,
    @required this.receptions,
  }) : super(key: key);

  final List<Reception> receptions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: receptions.length,
        shrinkWrap: true,
        itemBuilder: (context, receptionsIndex) {
          Reception reception = receptions[receptionsIndex];
//          logger.i('Showing reception: ${reception.toJson()}');
          return ChangeNotifierProvider.value(
            value: reception,
            child: ReceptionAppointmentListView(),
          );
        });
  }
}

class ReceptionAppointmentListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Reception reception = Provider.of<Reception>(context);
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

        final allBoxes = [...bookedBoxes, ...unBookedBoxes, AddOverride()];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ChangeNotifierProvider.value(
            value: slot,
            child: Row(
              children: <Widget>[
                SlotTiming(),
                Expanded(
                  child: Wrap(
                    runSpacing: 3,
                    spacing: 3,
                    children: allBoxes,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddOverride extends StatelessWidget {
  const AddOverride({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final Reception reception = context.read<Reception>();
        final Slot slot = context.read<Slot>();
        // TODO add an override to this slot
        // TODO show dialog box to add an override
      },
      child: Container(
        height: 50,
        width: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}

class SlotTiming extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Slot slot = Provider.of<Slot>(context);
    return SizedBox(
      width: 100,
      child: Column(
        children: <Widget>[
          Text(
            getTime(slot.startTime),
            style: TextStyle(fontSize: 18),
            softWrap: true,
          ),
          /*
          Text(
            'to',
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),
          Text(
            getTime(slot.endTime),
            style: TextStyle(fontSize: 20),
            softWrap: true,
          ),*/
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
    return GestureDetector(
      onTap: () {
        final Reception reception = context.read<Reception>();
        final Slot slot = context.read<Slot>();
        logger.i(
            'Selected reception: ${receptionToJson(reception)}\nSlot selected:${slot.toJson()}');
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.yellow[800],
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text('unbooked'),
      ),
    );
  }
}

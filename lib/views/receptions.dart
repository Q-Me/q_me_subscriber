import 'dart:async';

import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/bloc/reception_bloc/reception_bloc.dart';
import 'package:qme_subscriber/bloc/receptions.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/utilities/time.dart';
import 'package:qme_subscriber/views/createAppointment.dart';
import 'package:qme_subscriber/views/createReception.dart';
import 'package:qme_subscriber/views/signin.dart';
import 'package:qme_subscriber/views/slot.dart';
import 'package:qme_subscriber/widgets/calenderItems.dart';
import 'package:qme_subscriber/widgets/error.dart';
import 'package:qme_subscriber/widgets/loader.dart';

class ReceptionsScreen extends StatefulWidget {
  static const String id = '/receptions';
  @override
  _ReceptionsScreenState createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<void> _completer = Completer<void>();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  DateTime selectedDate = DateTime.now();
  List<String> status = [
    "DONE",
    "UPCOMING",
    "CANCELLED",
  ];
  List<DateTime> markedDates = [];
  TabController _tabController;

  addedReception() {
    /*TODO When coming back from Create Reception page*/
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Do you really want to exit the app?'),
        actions: [
          FlatButton(
            child: Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FlatButton(
            child: Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          )
        ],
      ),
    );
  }

  void showSnackBar(String text, int seconds) {
    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: seconds),
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => _scaffoldKey.currentState.hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> handleClick(String value) async {
    switch (value) {
      case 'Logout':
        AlertDialog alert = AlertDialog(
          title: Text("Are you sure you want to logout?"),
          actions: [
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Yes log out"),
              onPressed: () async {
                try {
                  final logOutResponse = await SubscriberRepository().signOut();
                  if (logOutResponse["msg"] == "Logged out successfully") {
                    logger.d('Log Out');
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      SignInScreen.id,
                      (route) => false,
                    );
                  }
                } on BadRequestException catch (e) {
                  showSnackBar(
                    e.toMap()["error"],
                    5,
                  );
                  return;
                } catch (e) {
                  showSnackBar(
                    e.toString(),
                    10,
                  );
                }
              },
            ),
          ],
        );
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
        return null;
        break;
    }
  }

  void filterChipOnSelect(
      {@required String status, @required BuildContext context}) {
    if (!BlocProvider.of<ReceptionBloc>(context).isHaving(counter: status)) {
      BlocProvider.of<ReceptionBloc>(context).addElementToStatus(
        element: status,
      );
      BlocProvider.of<ReceptionBloc>(context).add(
        DateWiseReceptionsRequested(
          date: selectedDate,
        ),
      );
      setState(() {});
    } else {
      BlocProvider.of<ReceptionBloc>(context).removeElementFromStatus(
        element: status,
      );
      BlocProvider.of<ReceptionBloc>(context).add(
        DateWiseReceptionsRequested(
          date: selectedDate,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: BlocProvider(
        create: (context) => ReceptionBloc(),
        child: SafeArea(
          child: Builder(builder: (context) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('Your Receptions'),
                automaticallyImplyLeading: false,
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: handleClick,
                    itemBuilder: (BuildContext context) {
                      return {'Logout'}.map(
                        (String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        },
                      ).toList();
                    },
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                elevation: 0,
                heroTag: "Create Reception",
                onPressed: () async {
                  logger.d('Create reception route on date ');
                  await Navigator.pushNamed(
                    context,
                    CreateReceptionScreen.id,
                    arguments: selectedDate,
                  );
                },
                tooltip: 'Create Reception',
                child: Icon(Icons.event),
              ),
              body: Column(
                children: <Widget>[
                  CalendarStrip(
                    startDate: startDate,
                    endDate: endDate,
                    onDateSelected: (DateTime select) {
                      logger.d(select.toString());
                      selectedDate = select;
                      BlocProvider.of<ReceptionBloc>(context).add(
                        DateWiseReceptionsRequested(
                          date: select,
                        ),
                      );
                    },
                    dateTileBuilder: dateTileBuilder,
                    iconColor: Colors.black87,
                    monthNameWidget: monthNameWidget,
                    markedDates: markedDates,
                    containerDecoration: BoxDecoration(color: Colors.black12),
                  ),
                  Wrap(
                    spacing: 10,
                    children: [
                      FilterChip(
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        label: Text(
                          "Done",
                          style: TextStyle(
                            color: BlocProvider.of<ReceptionBloc>(context)
                                    .isHaving(counter: "DONE")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        onSelected: (value) => filterChipOnSelect(
                          status: "DONE",
                          context: context,
                        ),
                        selected:
                            BlocProvider.of<ReceptionBloc>(context).isHaving(
                          counter: "DONE",
                        ),
                      ),
                      FilterChip(
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        label: Text(
                          "Upcoming",
                          style: TextStyle(
                            color: BlocProvider.of<ReceptionBloc>(context)
                                    .isHaving(counter: "UPCOMING")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        onSelected: (value) => filterChipOnSelect(
                          status: "UPCOMING",
                          context: context,
                        ),
                        selected:
                            BlocProvider.of<ReceptionBloc>(context).isHaving(
                          counter: "UPCOMING",
                        ),
                      ),
                      FilterChip(
                        selectedColor: Colors.blue,
                        checkmarkColor: Colors.white,
                        label: Text(
                          "Cancelled",
                          style: TextStyle(
                            color: BlocProvider.of<ReceptionBloc>(context)
                                    .isHaving(counter: "CANCELLED")
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        onSelected: (value) => filterChipOnSelect(
                          status: "CANCELLED",
                          context: context,
                        ),
                        selected:
                            BlocProvider.of<ReceptionBloc>(context).isHaving(
                          counter: "CANCELLED",
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: BlocConsumer<ReceptionBloc, ReceptionState>(
                      builder: (context, state) {
                        if (state is ReceptionInitial) {
                          BlocProvider.of<ReceptionBloc>(context).add(
                            DateWiseReceptionsRequested(
                              date: selectedDate,
                            ),
                          );
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (state is ReceptionsLoadFailure) {
                          return Center(
                            child: Text("${state.error}"),
                          );
                        } else if (state is ReceptionLoadSuccessful) {
                          if (state.receptions.length == 0) {
                            return RefreshIndicator(
                              onRefresh: () {
                                BlocProvider.of<ReceptionBloc>(context)
                                    .add(ReceptionBlocUpdateRequested(
                                  date: selectedDate,
                                ));
                                return _completer.future;
                              },
                              child: Stack(children: <Widget>[
                                ListView(),
                                Center(
                                  child: Text(
                                    "No Receptions found on ${DateFormat.yMMMd().format(selectedDate)}",
                                  ),
                                ),
                              ]),
                            );
                          } else {
                            return RefreshIndicator(
                              onRefresh: () {
                                BlocProvider.of<ReceptionBloc>(context)
                                    .add(ReceptionBlocUpdateRequested(
                                  date: selectedDate,
                                ));
                                return _completer.future;
                              },
                              child: ReceptionsListView(
                                receptions: state.receptions,
                                status: status,
                              ),
                            );
                          }
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                      listener: (context, state) {
                        if (state is ReceptionLoadSuccessful ||
                            state is ReceptionsLoadFailure) {
                          _completer?.complete();
                          _completer = Completer();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class ReceptionsListView extends StatelessWidget {
  const ReceptionsListView({
    Key key,
    @required this.receptions,
    @required List<String> status,
  }) : super(key: key);

  final List<Reception> receptions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: receptions.length,
      shrinkWrap: true,
      itemBuilder: (context, receptionsIndex) {
        Reception reception = receptions[receptionsIndex];
        return ChangeNotifierProvider.value(
          value: reception,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                    onPressed: () {
                      BlocProvider.of<ReceptionBloc>(context)
                          .add(StatusUpdateOfReceptionRequested(
                        receptionId: reception.receptionId,
                        updatedStatus: "CANCELLED",
                        date: reception.startTime,
                      ));
                    },
                    child: Text("Delete Reception"),
                  ),
                  RaisedButton(
                    onPressed: () {
                      BlocProvider.of<ReceptionBloc>(context)
                          .add(StatusUpdateOfReceptionRequested(
                        receptionId: reception.receptionId,
                        updatedStatus: "ACTIVE",
                        date: reception.startTime,
                      ));
                    },
                    child: Text("Open Reception"),
                  )
                ],
              ),
              ReceptionAppointmentListView(),
              Container(
                margin: EdgeInsets.all(10),
                child: RaisedButton(
                  onPressed: () {
                    BlocProvider.of<ReceptionBloc>(context)
                        .add(StatusUpdateOfReceptionRequested(
                      receptionId: reception.receptionId,
                      updatedStatus: "DONE",
                      date: reception.startTime,
                    ));
                  },
                  child: Text("Close Reception"),
                ),
              ),
              Divider(
                thickness: 2,
              )
            ],
          ),
        );
      },
    );
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
        DateTime now = DateTime.now();
        now = DateTime.utc(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
        );
        bool bookingEnabled = slot.startTime.isAfter(now);

        List<Widget> upcomingBoxes = List.generate(
          slot.upcoming != null ? slot.upcoming : 0,
          (index) => UpcomingSeat(),
        );

        List<Widget> doneBoxes = List.generate(
          slot.done != null ? slot.done : 0,
          (index) => DoneSeat(),
        );

        List<Widget> unBookedBoxes = List.generate(
          slot.upcoming == null
              ? slot.customersInSlot
              : slot.customersInSlot - slot.upcoming - slot.done,
          (index) => UnbookedSeat(bookingEnabled: bookingEnabled),
        );

        final allBoxes = [...upcomingBoxes, ...doneBoxes, ...unBookedBoxes];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ChangeNotifierProvider.value(
            value: slot,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      SlotView.id,
                      arguments: SlotViewArguments(
                        reception: reception,
                        slot: slot,
                      ),
                    );
                    BlocProvider.of<ReceptionBloc>(context).add(
                      DateWiseReceptionsRequested(
                        date: DateTime.now(),
                      ),
                    );
                  },
                  child: SlotTiming(),
                ),
                Expanded(
                  child: Wrap(
                    runSpacing: 3,
                    spacing: 3,
                    children: allBoxes,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      SlotView.id,
                      arguments: SlotViewArguments(
                        reception: reception,
                        slot: slot,
                      ),
                    );
                    BlocProvider.of<ReceptionBloc>(context).add(
                      DateWiseReceptionsRequested(
                        date: DateTime.now(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(width: 10)
              ],
            ),
          ),
        );
      },
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
        ],
      ),
    );
  }
}

class UpcomingSeat extends StatelessWidget {
  const UpcomingSeat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          SlotView.id,
          arguments: SlotViewArguments(
            reception: Provider.of<Reception>(context, listen: false),
            slot: Provider.of<Slot>(context, listen: false),
          ),
        );
        BlocProvider.of<ReceptionBloc>(context).add(
          DateWiseReceptionsRequested(
            date: DateTime.now(),
          ),
        );
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          'UPCOMING',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class DoneSeat extends StatelessWidget {
  const DoneSeat({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.pushNamed(
          context,
          SlotView.id,
          arguments: SlotViewArguments(
            reception: Provider.of<Reception>(context, listen: false),
            slot: Provider.of<Slot>(context, listen: false),
          ),
        );
        BlocProvider.of<ReceptionBloc>(context).add(
          DateWiseReceptionsRequested(
            date: DateTime.now(),
          ),
        );
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          'DONE',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class UnbookedSeat extends StatelessWidget {
  final bool bookingEnabled;

  const UnbookedSeat({
    Key key,
    this.bookingEnabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Reception reception = context.read<Reception>();
        final Slot slot = context.read<Slot>();
        logger.i(
            'Selected reception: ${receptionToJson(reception)}\nSlot selected:${slot.toJson()}');
        if (!bookingEnabled) {
          return;
        }
        await Navigator.pushNamed(
          context,
          CreateAppointment.id,
          arguments: CreateAppointmentArgs(
            receptionId: reception.receptionId,
            slot: slot,
          ),
        );
        BlocProvider.of<ReceptionBloc>(context).add(
          DateWiseReceptionsRequested(
            date: DateTime.now(),
          ),
        );
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          'unbooked',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

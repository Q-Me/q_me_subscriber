import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import 'package:qme_subscriber/api/base_helper.dart';
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

class _ReceptionsScreenState extends State<ReceptionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  DateTime selectedDate = DateTime.now();
  List<DateTime> markedDates = [];
  ReceptionsBloc receptionsBloc;

  onSelect(DateTime select) {
//    logger.d('Select functions: $select');
    setState(() {
      selectedDate = select;
    });
    receptionsBloc.date = select;
  }

  addedReception() {
    /*TODO When coming back from Create Reception page*/
  }

  @override
  void initState() {
    receptionsBloc = ReceptionsBloc(selectedDate);
    receptionsBloc.date = selectedDate;
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SafeArea(
        child: ChangeNotifierProvider.value(
          value: receptionsBloc,
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('Your Receptions'),
              automaticallyImplyLeading: false,
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: IconButton(
                          icon: Icon(Icons.exit_to_app, color: Colors.red),
                          onPressed: () async {
                            try {
                              final logOutResponse =
                                  await SubscriberRepository().signOut();
                              if (logOutResponse["msg"] ==
                                  "Logged out successfully") {
                                logger.d('Log Out');
                                Navigator.pushNamedAndRemoveUntil(
                                    context, SignInScreen.id, (route) => false);
                              }
                            } on BadRequestException catch (e) {
                              showSnackBar(e.toMap()["error"], 5);
                              return;
                            } catch (e) {
                              showSnackBar(e.toString(), 10);
                            }
                          })),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 0,
              heroTag: "Create Reception",
              onPressed: () {
                logger.d('Create reception route on date $selectedDate');
                Navigator.pushNamed(
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
                                return Center(
                                  child: Text(
                                      'No reception found on ${getDate(Provider.of<ReceptionsBloc>(context).selectedDate).toString()}'),
                                );
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
        return ChangeNotifierProvider.value(
          value: reception,
          child: ReceptionAppointmentListView(),
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
          (index) => UnbookedSeat(),
        );

        final allBoxes = [...upcomingBoxes, ...doneBoxes, ...unBookedBoxes];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ChangeNotifierProvider.value(
            value: slot,
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    SlotView.id,
                    arguments: SlotViewArguments(
                      reception: reception,
                      slot: slot,
                    ),
                  ),
                  child: SlotTiming(),
                ),
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
      onTap: () => Navigator.pushNamed(
        context,
        SlotView.id,
        arguments: SlotViewArguments(
          reception: Provider.of<Reception>(context, listen: false),
          slot: Provider.of<Slot>(context, listen: false),
        ),
      ),
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
      onTap: () => Navigator.pushNamed(
        context,
        SlotView.id,
        arguments: SlotViewArguments(
          reception: Provider.of<Reception>(context, listen: false),
          slot: Provider.of<Slot>(context, listen: false),
        ),
      ),
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
        Navigator.pushNamed(
          context,
          CreateAppointment.id,
          arguments: CreateAppointmentArgs(
            receptionId: reception.receptionId,
            slot: slot,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/bloc/booking_bloc.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/appointment.dart';
import 'package:qme_subscriber/views/createAppointment.dart';
import 'package:qme_subscriber/widgets/loader.dart';
import 'package:qme_subscriber/widgets/slotWidgets.dart';

import '../model/appointment.dart';

class SlotViewArguments {
  final Reception reception;
  final Slot slot;
  SlotViewArguments({@required this.reception, @required this.slot})
      : assert(reception != null && slot != null) {
    logger.d(
        'Reception:${reception.toJson()}\nSlot:\n${slot.toJson()}\nNow:${DateTime.now().toString()}');
  }
}

class SlotView extends StatefulWidget {
  static const String id = '/slot';
  final SlotViewArguments args;

  SlotView(this.args);

  @override
  _SlotViewState createState() => _SlotViewState();
}

class _SlotViewState extends State<SlotView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double get mediaHeight => MediaQuery.of(context).size.height;
  Reception get reception => widget.args.reception;
  Slot slot;
  ReceptionRepository repository = ReceptionRepository();
  List<String> statusRequestList = [
    'UPCOMING',
    'CANCELLED',
    'CANCELLED BY SUBSCRIBER',
    'DONE'
  ];
  List<Appointment> appointments;

  @override
  void initState() {
    slot = widget.args.slot;
    appointments = [];
    super.initState();
  }

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
        key: _scaffoldKey,
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios)),
          title: Text("Slots"),
        ),
        body: MultiProvider(
          providers: [
            BlocProvider(create: (context) => BookingBloc(repository)),
            ChangeNotifierProvider.value(value: reception),
            ChangeNotifierProvider.value(value: slot),
            Provider.value(value: appointments),
          ],
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.018,
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                  // bottom: cHeight * 0.015,
                ),
                child: SlotDetails(slot: slot),
              ),
              Expanded(child: BookingBlocConsumer())
            ],
          ),
        ),
      ),
    );
  }
}

class BookingBlocConsumer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Reception reception = Provider.of<Reception>(context, listen: false);
    Slot slot = Provider.of<Slot>(context);
    List<Appointment> appointments = Provider.of<List<Appointment>>(context);

    return BlocConsumer<BookingBloc, BookingState>(
      builder: (context, state) {
        logger.d(state.toString());
        if (state is BookingLoading) {
          return Loading(
            loadingMessage: 'Fetching appointments data',
          );
        } else if (state is BookingInitial) {
          BlocProvider.of<BookingBloc>(context).add(
            BookingListRequested(
              reception.receptionId,
              slot.startTime,
              slot.endTime,
              ['UPCOMING', 'CANCELLED', 'CANCELLED BY SUBSCRIBER', 'DONE'],
              slot.endTime.difference(slot.startTime).inMinutes,
            ),
          );
          return Loading(
              loadingMessage: "Please wait....Fetching Appointments");
        } else if (state is BookingLoadSuccessful) {
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
          logger.d(
              'Reception:${reception.toJson()}\nSlot:${slot.toJson()}\n Now:${now.toString()} \nNow:${now.timeZoneName}\tSlot end:${slot.endTime.timeZoneName}\nBookingEnabled:$bookingEnabled');
          if (state.response is List) {
            appointments = state.response;
          }
          if (state.response is Slot) {
            slot = state.response;
          }

          // update the slot upcoming and done values
          slot.upcoming = filterAppointmentsByStatus(
            appointments,
            "UPCOMING",
          ).length;

          slot.done = filterAppointmentsByStatus(
            appointments,
            "DONE",
          ).length;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // UPCOMING, DONE, CANCELLED, CANCELLED BY SUBSCRIBER
                  ListView.builder(
                    itemCount: appointments.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return AppointmentCard(
                        appointment: appointments[index],
                      );
                    },
                  ),
                  // Unbooked
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: slot.customersInSlot - slot.upcoming - slot.done,
                    itemBuilder: (BuildContext context, int index) {
                      return UnbookedTile(
                        bookingEnable: bookingEnabled,
                      );
                    },
                  ),
                  bookingEnabled
                      ? InkWell(
                          onTap: () {
                            BlocProvider.of<BookingBloc>(context).add(
                              AddUnbookedAppointment(
                                reception.receptionId,
                                slot,
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: Container(
                                    height: 50,
                                    child: Icon(
                                      Icons.add,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          );
        } else if (state is BookingLoadFailure) {
          // TODO check if the appointment list is available
          // if apppointment list is filled and corresponds with slot instance
          // then show that list and show a snackbat error
          // else show the below widget
          return Center(
              child: Column(
            children: <Widget>[
              Text("Error loading data...Please try again"),
              RaisedButton(
                onPressed: () {
                  BlocProvider.of<BookingBloc>(context).add(
                      BookingListRequested(
                          reception.receptionId,
                          slot.startTime,
                          slot.endTime,
                          [
                            'UPCOMING',
                            'CANCELLED',
                            'CANCELLED BY SUBSCRIBER',
                            'DONE'
                          ],
                          (slot.endTime.difference(slot.startTime)).inMinutes));
                },
                child: Text("Retry"),
              )
            ],
          ));
        } else {
          return Text('Unidentified state');
        }
      },
      listener: (context, state) {},
    );
  }
}

class UnbookedTile extends StatelessWidget {
  final bool bookingEnable;
  const UnbookedTile({
    Key key,
    this.bookingEnable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return bookingEnable
        ? Card(
            color: Colors.orange[400],
            child: ListTile(
              dense: false,
              trailing: InkWell(
                onTap: () {
                  BlocProvider.of<BookingBloc>(context).add(
                    RemoveUnbookedAppointment(
                      context.read<Reception>().receptionId,
                      context.read<Slot>(),
                    ),
                  );
                },
                child: Icon(Icons.delete, color: Colors.white),
              ),
              title: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    CreateAppointment.id,
                    arguments: CreateAppointmentArgs(
                      receptionId: Provider.of<Reception>(
                        context,
                        listen: false,
                      ).receptionId,
                      slot: Provider.of<Slot>(context, listen: false),
                    ),
                  ).then(
                    (value) => {
                      BlocProvider.of<BookingBloc>(context)
                          .add(BookingRefreshRequested())
                    },
                  );
                },
                child: Center(
                  child: Text(
                    'Unbooked',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        : Card(
            color: Colors.orange[400],
            child: ListTile(
              dense: false,
              title: Center(
                child: Text(
                  'Unbooked',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          );
  }
}

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (appointment.status == "UPCOMING") {
          await Navigator.pushNamed(
            context,
            AppointmentView.id,
            arguments: [
              Provider.of<Reception>(context, listen: false),
              appointment
            ],
          );
          BlocProvider.of<BookingBloc>(context).add(BookingRefreshRequested());
        }
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.005,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: ListTile(
                  dense: false,
                  isThreeLine: true,
                  trailing: appointment.status == "CANCELLED BY SUBSCRIBER"
                      ? Text(
                          "CANCELLED\nBY\nYOU",
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.red),
                        )
                      : Text(appointment.status),
                  leading: Container(
                    child: CircleAvatar(child: Icon(Icons.account_circle)),
                    width: 32.0,
                    height: 32.0,
                    padding: EdgeInsets.all(2), // borde width
                    decoration: BoxDecoration(shape: BoxShape.circle),
                  ),
                  title: Text(
                    appointment.customerName,
                  ),
                  subtitle: Text(appointment.customerPhone +
                      (appointment.note.length >= 1
                          ? "\nNote: ${appointment.note}"
                          : "")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  SlotViewArguments({@required this.reception, @required this.slot}) {
    logger.d('Reception:${reception.toJson()}\nSlot:\n${slot.toJson()}');
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
  Slot get slot => widget.args.slot;
  ReceptionRepository repository = ReceptionRepository();
  List<Appointment> response;

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
              Expanded(
                child: BlocConsumer<BookingBloc, BookingState>(
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
                          [
                            'UPCOMING',
                            'CANCELLED',
                            'CANCELLED BY SUBSCRIBER',
                            'DONE'
                          ],
                          slot.endTime.difference(slot.startTime).inMinutes,
                        ),
                      );
                      return Loading(
                          loadingMessage:
                              "Please wait....Fetching Appointments");
                    } else if (state is BookingLoadSuccessful) {
                      logger.d(
                          'Appointment List\n${state.response}\nReception:${reception.toJson()}\nSlot:${slot.toJson()}');

                      final List<Appointment> appointments = state.response;

                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
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
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount: reception.customersInSlot -
                                    (slot.booked ?? 0),
                                itemBuilder: (BuildContext context, int index) {
                                  return UnbookedTile();
                                },
                              ),
                              InkWell(
                                onTap: () {
                                  showSnackBar("sdjkgsd", 6);
//                                  BlocProvider.of<BookingBloc>(context)
//                                      .add(BookingLoading());
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
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (state is BookingLoadFailure) {
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
                                      ["UPCOMING"],
                                      (slot.endTime.difference(slot.startTime))
                                          .inMinutes));
                            },
                            child: Text("Retry"),
                          )
                        ],
                      ));
                    }
                    return Text('Unidentified state');
                  },
                  listener: (context, state) {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class UnbookedTile extends StatelessWidget {
  const UnbookedTile({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[400],
      child: ListTile(
        dense: false,
        trailing: Icon(Icons.delete, color: Colors.white),
        title: InkWell(
          onTap: () {
            Navigator.pushReplacementNamed(
              context,
              CreateAppointment.id,
              arguments: CreateAppointmentArgs(
                receptionId: Provider.of<Reception>(
                  context,
                  listen: false,
                ).receptionId,
                slot: Provider.of<Slot>(context, listen: false),
              ),
            );
          },
          child: Center(
              child: Text(
            'Unbooked',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: Colors.white),
          )),
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
      onTap: () {
        if (appointment.status == "UPCOMING") {
          Navigator.pushReplacementNamed(
            context,
            AppointmentView.id,
            arguments: [
              Provider.of<Reception>(context, listen: false),
              appointment
            ],
          );
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
                      "\nNote: ${appointment.note}"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

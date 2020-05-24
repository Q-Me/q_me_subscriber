import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/views/people.dart';
import 'dart:developer';
import '../model/queue.dart';
import '../constants.dart';
import '../widgets/loader.dart';
import '../widgets/error.dart';
import '../bloc/queueDetails.dart';
import '../utilities/time.dart';

class ViewQueueScreen extends StatefulWidget {
  static final id = 'viewQueueScreen';
  final String queueId;
  ViewQueueScreen({this.queueId});
  @override
  _ViewQueueScreenState createState() => _ViewQueueScreenState();
}

class _ViewQueueScreenState extends State<ViewQueueScreen> {
  QueueDetailsBloc queueDetails;

  @override
  void initState() {
    super.initState();
    queueDetails = QueueDetailsBloc(widget.queueId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (queueDetails == null) {
      queueDetails = QueueDetailsBloc(widget.queueId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Queue Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ChangeNotifierProvider.value(
              value: queueDetails,
              child: StreamBuilder<ApiResponse<Queue>>(
                  stream: queueDetails.queueDetailsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return Loading(loadingMessage: snapshot.data.message);
                          break;
                        case Status.COMPLETED:
                          return QueueDetails(snapshot.data.data);
                          break;
                        case Status.ERROR:
                          return Error(
                            errorMessage: snapshot.data.message,
                            onRetryPressed: () =>
                                queueDetails.fetchQueueDetails(),
                          );
                          break;
                      }
                    }
                    return Text('Default return');
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class QueueDetails extends StatefulWidget {
  final Queue queue;
  QueueDetails(this.queue);
  @override
  _QueueDetailsState createState() => _QueueDetailsState();
}

class _QueueDetailsState extends State<QueueDetails> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GridQueueDetails(widget.queue),
              // Start Queue Button,
              QueueButton(),
              // End Queue button,
            ],
          ),
        ),
      ],
    );
  }
}

class GridQueueDetails extends StatelessWidget {
  final Queue queue;
  GridQueueDetails(this.queue);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Table(
            children: [
              TableRow(children: [
                GridItemQueue(
                  'Starts at',
                  '${getTime(queue.startDateTime)}',
                  '${getDate(queue.startDateTime)}',
                ),
                GridItemQueue(
                  'Ends at',
                  '${getTime(queue.endDateTime)}',
                  '${getDate(queue.endDateTime)}',
                ),
              ]),
              TableRow(children: [
                GridItemQueue(
                  'Average time per token',
                  queue.avgTimeOnCounter.toString(),
                  '',
                ),
                GridItemQueue(
                  'Maximum number of people allowed',
                  queue.maxAllowed.toString(),
                  '',
                ),
              ]),
              TableRow(children: [
                GridItemQueue(
                  'Current token Number',
                  queue.currentToken.toString(),
                  '',
                ),
                GridItemQueue(
                  'Total Issued tokens',
                  queue.totalIssuedTokens.toString(),
                  '',
                ),
              ]),
              TableRow(children: [
                GridItemQueue(
                  'STATUS',
                  queue.status.toString(),
                  '',
                ),
                GridItemQueue(
                  'Last Issued Token',
                  queue.lastIssuedToken.toString(),
                  '',
                ),
              ]),
            ],
          ),
          Text('Last Updated at ' + queue.lastUpdate.toLocal().toString()),
        ],
      ),
    );
  }
}

class GridItemQueue extends StatelessWidget {
  final String top, center, bottom;
  GridItemQueue(this.top, this.center, this.bottom);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(top, style: kSmallTextStyle),
        Text(center, style: kBigTextStyle),
        Text(bottom, style: kSmallTextStyle),
      ],
    );
  }
}

class QueueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () async {
            if (Provider.of<QueueDetailsBloc>(context, listen: false)
                    .queue
                    .status ==
                'UPCOMING') {
              // Call start queue API
              final result =
                  await Provider.of<QueueDetailsBloc>(context, listen: false)
                      .startQueue();
              if (result == 'Queue Created Successfully.')
                // Move to people list screen
                Navigator.pushNamed(context, PeopleScreen.id);
              else {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(result),
                ));
              }
            } else {
              final String queueId =
                  Provider.of<QueueDetailsBloc>(context, listen: false).queueId;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PeopleScreen(queueId: queueId),
                  ));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                Provider.of<QueueDetailsBloc>(context, listen: false)
                            .queue
                            .status ==
                        'UPCOMING'
                    ? 'Start Queue'
                    : 'View Queue',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

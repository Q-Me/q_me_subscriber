import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qme_subscriber/views/people.dart';
import 'dart:developer';
import '../model/queue.dart';
import '../constants.dart';
import '../utilities/time.dart';

class ViewQueueScreen extends StatefulWidget {
  static final id = 'viewQueueScreen';
  @override
  _ViewQueueScreenState createState() => _ViewQueueScreenState();
}

class _ViewQueueScreenState extends State<ViewQueueScreen> {
  final Queue queue = Queue.fromJson(jsonDecode("""
  {
    "queue": {
        "queue_id": "yl3IWW4rA",
        "subscriber_id": "4Q3fOuppX",
        "start_date_time": "2021-05-01T18:36:00.000Z",
        "end_date_time": "2021-05-01T23:30:00.000Z",
        "max_allowed": 100,
        "avg_time_on_counter": 3,
        "status": "UPCOMING",
        "current_token": 4,
        "last_issued_token": 50,
        "last_update": "2020-04-30T17:52:55.000Z",
        "total_issued_tokens": 10
    }
}""")["queue"]);
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
            QueueDetails(queue),
          ],
        ),
      ),
    );
  }
}

class QueueDetails extends StatefulWidget {
  final Queue queue;
  QueueDetails(this.queue) {
    log('QueueDetails constructor:${queue.toJson()}');
  }
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
              StartQueueButton(),
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

class StartQueueButton extends StatelessWidget {
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
          onTap: () {
            // TODO Call start queue API
            // TODO Move to people list screen
            Navigator.pushNamed(context, PeopleScreen.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Start Queue',
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

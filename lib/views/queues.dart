import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import '../model/subscriber.dart';
import '../views/createQueue.dart';
import '../widgets/text.dart';
import '../widgets/loader.dart';
import '../widgets/error.dart';
import '../bloc/queues.dart';
import '../constants.dart';
import '../model/queue.dart';
import '../utilities/time.dart';

final queueStatusList = <String>[
  'UPCOMING',
  'ACTIVE',
  'CANCELLED',
  'DONE',
  'FORCE DONE',
];

class QueuesPage extends StatefulWidget {
  final subscriberId;
  QueuesPage({this.subscriberId});
  static final id = 'queues';
  @override
  _QueuesPageState createState() => _QueuesPageState();
}

class _QueuesPageState extends State<QueuesPage> {
  final Subscriber subscriberData = subscriberFromJson('''{
    "id": "4Q3fOuppX",
    "name": "S2",
    "owner": "Kavya",
    "email": "S2@gmail.com",
    "phone": "9898009900"
}''');
  QueuesBloc queuesBloc;
  String queueDisplayStatus = queueStatusList[0];

  @override
  void initState() {
    super.initState();
    queuesBloc = QueuesBloc(
        subscriberId: widget.subscriberId, queueStatus: queueDisplayStatus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (queuesBloc == null) {
      queuesBloc = QueuesBloc(
          subscriberId: widget.subscriberId, queueStatus: queueDisplayStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Create Queue'),
          icon: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, CreateQueueScreen.id);
          },
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
            child: ChangeNotifierProvider.value(
              value: queuesBloc,
              child: Column(
                children: <Widget>[
                  // TODO make this widget sharable
                  ThemedText(words: ['Hello ${subscriberData.name}']),
                  Row(
                    children: <Widget>[
                      Text('Showing '),
                      DropdownButton<String>(
                        items: queueStatusList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text(queueDisplayStatus),
                        value: queueDisplayStatus,
                        onChanged: (value) {
                          setState(() {
                            queueDisplayStatus = value;
                          });
                        },
                      ),
                      Text(' queues.'),
                    ],
                  ),
                  // TODO make this widget sharable
                  //  this below widget is used as it is from the user app
                  StreamBuilder<ApiResponse<List<Queue>>>(
                      stream: queuesBloc.queuesListStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return Loading(
                                  loadingMessage: snapshot.data.message);
                              break;
                            case Status.COMPLETED:
                              return QueuesDisplay(snapshot.data.data);
                              break;
                            case Status.ERROR:
                              return Error(
                                errorMessage: snapshot.data.message,
                                onRetryPressed: () => queuesBloc
                                    .fetchQueuesList(queueDisplayStatus),
                              );
                              break;
                          }
                        }
                        return Text('Default return');
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QueuesDisplay extends StatelessWidget {
  final List<Queue> queues;
  QueuesDisplay(this.queues);

  @override
  Widget build(BuildContext context) {
    return queues != null && queues.length != 0
        ? ListView.builder(
            itemCount: queues.length,
            cacheExtent: 4,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => QueueItem(queues[index]))
        : Text('No queues found');
  }
}

class QueueItem extends StatelessWidget {
  final Queue queue;
  QueueItem(this.queue);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1, color: Colors.green)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Starts at', style: kSmallTextStyle),
                            Text(getTime(queue.startDateTime),
                                style: kBigTextStyle),
                            Text(getDate(queue.startDateTime),
                                style: kSmallTextStyle),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Ends at', style: kSmallTextStyle),
                          Text(getTime(queue.endDateTime),
                              style: kBigTextStyle),
                          Text(getDate(queue.endDateTime),
                              style: kSmallTextStyle),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Already in queue', style: kSmallTextStyle),
                          Text('${queue.totalIssuedTokens}',
                              style: kBigTextStyle),
                          SizedBox(width: 10),
                          Text('People', style: kSmallTextStyle),
                        ],
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                            child: Text(
                                'Last Updated at\n${getFullDateTime(queue.lastUpdate)}')),
                        Container(
                          height: 35.0,
                          width: MediaQuery.of(context).size.width / 4,
                          child: Material(
                            borderRadius: BorderRadius.circular(20.0),
                            shadowColor: Colors.greenAccent,
                            color: Colors.green,
                            elevation: 7.0,
                            child: InkWell(
                              onTap: () {},
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(
                                    'View',
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
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            ],
          ),*/
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/views/signin.dart';
import 'package:qme_subscriber/views/signup.dart';
import 'package:qme_subscriber/widgets/appDrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/viewQueue.dart';
import '../views/createQueue.dart';
import '../widgets/text.dart';
import '../widgets/loader.dart';
import '../widgets/error.dart';
import '../bloc/queues.dart';
import '../constants.dart';
import '../model/queue.dart';
import '../utilities/time.dart';

class QueuesScreen extends StatefulWidget {
  static const id = '/queues';
  final subscriberId;
  QueuesScreen({this.subscriberId});
  @override
  _QueuesScreenState createState() => _QueuesScreenState();
}

class _QueuesScreenState extends State<QueuesScreen> {
  QueuesBloc queuesBloc;
  String queueDisplayStatus = kQueueStatusList[0];
  final FirebaseMessaging _messaging = FirebaseMessaging();
  var _fcmToken;

  @override
  void initState() {
    super.initState();
    queuesBloc = QueuesBloc(queueStatus: queueDisplayStatus);
     firebaseCloudMessagingListeners();
    _messaging.getToken().then((token) {
      print("fcmToken: $token");
      _fcmToken = token;
      verifyFcmTokenChange(_fcmToken);
    });
      
  }
  void verifyFcmTokenChange(String _fcmToken)async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
             var fcmToken=  prefs.getString('fcmToken' );
              if (fcmToken != _fcmToken){
                print("verify fcm: $fcmToken");
                print("verify _fcm: $_fcmToken");
         Navigator.pushNamed(context, SignInScreen.id);}
              }
    void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iosPermission();

    _messaging.getToken().then((token) {
      print(token);
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //showNotification(message['notification']);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iosPermission() {
    _messaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _messaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (queuesBloc == null) {
      queuesBloc = QueuesBloc(queueStatus: queueDisplayStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
//          leading: Icon(Icons.home),
        ),
        drawer: AppDrawer(),
        floatingActionButton: FloatingActionButton.extended(
          label: Text('Create Queue'),
          icon: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, CreateQueueScreen.id);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
          child: ChangeNotifierProvider.value(
            value: queuesBloc,
            child: Column(
              children: <Widget>[
                // TODO make this widget sharable
                ThemedText(
                  words: ['Hello'],
                  fontSize: 50,
                ),
                Row(
                  children: <Widget>[
                    Text('Showing '),
                    DropdownButton<String>(
                      items: kQueueStatusList.map((String value) {
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
                          log('New queueDisplayStatus:$queueDisplayStatus');
                          queuesBloc.fetchQueuesList(
                              status: queueDisplayStatus);
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
                            return Expanded(
                                child: QueuesDisplay(snapshot.data.data));
                            break;
                          case Status.ERROR:
                            if (snapshot.data.message ==
                                'Unauthorised: {"error":"Invalid access token"}') {
                              return Error(
                                buttonLabel: 'Login Again',
                                errorMessage:
                                    'Session expired. Please Login again',
                                onRetryPressed: () => Navigator.pushNamed(
                                    context, SignInScreen.id),
                              );
                            }
                            return Error(
                              errorMessage: snapshot.data.message,
                              onRetryPressed: () => queuesBloc.fetchQueuesList(
                                  status: queueDisplayStatus),
                            );
                            break;
                        }
                      }
                      return Text('Default return');
                    }),
                SizedBox(height: 60),
              ],
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
                    Expanded(
                      child: Container(
                          child: Text(
                              'Last Updated at\n${getFullDateTime(queue.lastUpdate)}')),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Visibility(
                  child: DeleteButton(queueId: queue.queueId),
                  visible: queue.status == 'UPCOMING' && queue.currentToken == 0
                      ? true
                      : false,
                ),
                ViewButton(queueId: queue.queueId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key key, @required this.queueId}) : super(key: key);
  final String queueId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      width: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 1, color: Colors.red),
      ),
      child: InkWell(
        onTap: () async {
          // TODO Ask isn dialog box to make he wants to delete the queue
          log('Delete button clicked');
          String msg = await Provider.of<QueuesBloc>(context, listen: false)
              .deleteQueue(queueId: queueId);
          Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
          if (msg == 'Queue Delete Success') {
            Provider.of<QueuesBloc>(context, listen: false).fetchQueuesList();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              'Delete',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat'),
            ),
          ),
        ),
      ),
    );
  }
}

class ViewButton extends StatelessWidget {
  const ViewButton({
    Key key,
    @required this.queueId,
  }) : super(key: key);

  final String queueId;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.0,
      width: MediaQuery.of(context).size.width / 4,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewQueueScreen(queueId: queueId)));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
    );
  }
}

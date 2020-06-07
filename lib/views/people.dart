import 'package:flutter/material.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/bloc/poeple.dart';
import 'package:qme_subscriber/views/queues.dart';
import 'package:qme_subscriber/views/viewQueue.dart';
import 'package:qme_subscriber/widgets/loader.dart';
import '../constants.dart';
import '../model/user.dart';
import '../widgets/badge.dart';
import '../widgets/error.dart';
import 'dart:developer';
import 'package:provider/provider.dart';

class PeopleScreen extends StatefulWidget {
  static const id = '/people';

  final String tokenStatus;
  final String queueId;
  PeopleScreen({this.tokenStatus, @required this.queueId});
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  List<User> users;
  PeopleBloc peopleBloc;

  @override
  void initState() {
    super.initState();
    log('Showing people of queueId:${widget.queueId}');
    peopleBloc = PeopleBloc(
      queueId: widget.queueId,
      tokenStatus: widget.tokenStatus ?? 'WAITING',
    );
    peopleBloc.fetchPeopleList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (peopleBloc == null) {
      peopleBloc = PeopleBloc(
        queueId: widget.queueId,
        tokenStatus: widget.tokenStatus ?? 'WAITING',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              // Go to queue details screen
              Navigator.pushReplacementNamed(
                context,
                ViewQueueScreen.id,
                arguments: widget.queueId,
              );
            },
            child: Icon(Icons.arrow_back_ios)),
        title: Text('Queue Tokens'),
      ),
      body: ChangeNotifierProvider.value(
        value: peopleBloc,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: widget.queueId != null ||
                        (peopleBloc.peopleList != null &&
                            peopleBloc.peopleList.length != 0)
                    ? Column(
                        children: <Widget>[
                          StreamBuilder<ApiResponse<User>>(
                              stream: peopleBloc.personStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  switch (snapshot.data.status) {
                                    case Status.LOADING:
                                      return Loading(
                                          loadingMessage:
                                              snapshot.data.message);
                                      break;
                                    case Status.COMPLETED:
                                      return TokenDetails(
                                          user: snapshot.data.data,
                                          status: widget.tokenStatus);
                                      break;
                                    case Status.ERROR:
                                      return Error(
                                        errorMessage: snapshot.data.message,
                                        onRetryPressed: () =>
                                            peopleBloc.fetchPeopleList(),
                                      );
                                      break;
                                  }
                                } else {
                                  return Text('No stream data');
                                }
                                return Text('some uncaught error happened');
                              }),
                          Expanded(
                            flex: 2,
                            child: StreamBuilder<ApiResponse<List<User>>>(
                                stream: peopleBloc.peopleListStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    switch (snapshot.data.status) {
                                      case Status.LOADING:
                                        return Loading(
                                            loadingMessage:
                                                snapshot.data.message);
                                        break;

                                      case Status.COMPLETED:
                                        return ListView.builder(
                                            itemCount:
                                                snapshot.data.data.length,
                                            itemBuilder: (context, index) {
                                              User _user =
                                                  snapshot.data.data[index];
                                              return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      Provider.of<PeopleBloc>(
                                                              context,
                                                              listen: false)
                                                          .addPersonDetails(
                                                              _user);
                                                    });
                                                  },
                                                  child:
                                                      TokenCard(user: _user));
                                            });
                                        break;

                                      case Status.ERROR:
                                        return Error(
                                          errorMessage: snapshot.data.message,
                                          onRetryPressed: () =>
                                              peopleBloc.fetchPeopleList(),
                                        );
                                        break;
                                    }
                                  } else {
                                    return Text('No snapshot data');
                                  }
                                  return Container();
                                }),
                          ),
                        ],
                      )
                    : Error(
                        errorMessage: 'Nobody is in queue.',
                        buttonLabel: 'Refresh',
                        onRetryPressed: () => peopleBloc.fetchPeopleList(),
                      ),
              ),
            ),
            Visibility(
                visible: peopleBloc.tokenStatus == 'WAITING',
                child: EndQueueButton()),
          ],
        ),
      ),
    );
  }
}

class TokenDetails extends StatelessWidget {
  const TokenDetails({
    @required this.user,
    @required this.status,
  });

  final User user;
  final String status;

  @override
  Widget build(BuildContext context) {
//    log('Building TokenDetails');
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user.lastName != null
                          ? user.firstName + ' ' + user.lastName
                          : user.firstName,
                      style: kBigTextStyle.copyWith(fontSize: 20),
                    ),
//                    Text(
//                      user.email,
//                      style: kBigTextStyle.copyWith(fontSize: 15),
//                    ),
                    Text(
                      '******' + user.phone.substring(6),
                      style: kBigTextStyle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Token No.',
                    style: kBigTextStyle,
                  ),
                  Text(
                    user.tokenNo.toString(),
                    style: kSmallTextStyle.copyWith(fontSize: 40),
                  ),
                ],
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CancelTokenButton(),
            NextTokenButton(),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('Showing people $status'),
              /*
              DropdownButton<String>(
                items: kDropdownList,
                hint: Text(status),
//                value: status,
                onChanged: (value) {
                  Provider.of<PeopleBloc>(context).status = value;
                  log('New queueDisplayStatus:$status');
                  Provider.of<PeopleBloc>(context).fetchPeopleList();
                },
              ),
               */
              Text(' in the queue'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: <Widget>[
              Text('Token No.', style: kSmallTextStyle),
              Spacer(flex: 1),
              Text('Name of Person', style: kSmallTextStyle),
              Spacer(flex: 6),
              Text('Status', style: kSmallTextStyle),
            ],
          ),
        )
      ],
    );
  }
}

class TokenCard extends StatelessWidget {
  const TokenCard({
    Key key,
    @required User user,
  })  : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    final int token =
        Provider.of<PeopleBloc>(context, listen: false).person.tokenNo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Card(
        elevation: token == _user.tokenNo ? 0 : 3,
        shadowColor: Colors.greenAccent,
        color: token == _user.tokenNo ? Colors.green[200] : Colors.white,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Spacer(flex: 1),
              Text(_user.tokenNo.toString(), style: kSmallTextStyle),
              Spacer(flex: 2),
              Text(_user.lastName != null
                  ? _user.firstName + ' ' + _user.lastName
                  : _user.firstName),
              Spacer(flex: 5),
              badgeMap['WAITING'],
//              Badge(label: 'ACTIVE', color: Colors.lightBlue),
//              Badge(label: 'DONE', color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class CancelTokenButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 1, color: Colors.red),
      ),
      child: InkWell(
        onTap: () {
          Provider.of<PeopleBloc>(context, listen: false).cancelToken();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              'Cancel Token',
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

class NextTokenButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {
            Provider.of<PeopleBloc>(context, listen: false).nextToken();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                'Next',
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

class EndQueueButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 1, color: Colors.lightGreen),
      ),
      child: InkWell(
        onTap: () async {
          // show a dialog box to ask if the queue is ended forcefully or not
          bool isForced;

          await showDialog<void>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('End Queue'),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                          'You are about to end the queue. Users won\'t be able to join this queue after it is ended.'),
                      Text('\nHow would you like to end the queue?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Force End'),
                    onPressed: () {
                      isForced = true;
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: Text('End Normally'),
                    onPressed: () {
                      isForced = false;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          final String result =
              await Provider.of<PeopleBloc>(context, listen: false)
                  .endQueue(isForced: isForced);
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(result),
          ));

          if (result == 'Queue ended successfully.') {
            Navigator.pushNamed(context, QueuesScreen.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              'End Queue',
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

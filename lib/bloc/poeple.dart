import 'package:flutter/material.dart';
import 'package:qme_subscriber/repository/queue.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import '../repository/user.dart';
import '../api/base_helper.dart';
import '../model/user.dart';
import 'dart:async';
import 'dart:developer';

class PeopleBloc extends ChangeNotifier {
  UserRepository _peopleRepository;
  String queueId, status;
  List<User> peopleList;
  User person;
  int currentToken = 0;

  StreamController _peopleListController;
  StreamController _personController;

  StreamSink<ApiResponse<List<User>>> get peopleListSink =>
      _peopleListController.sink;
  StreamSink<ApiResponse<User>> get personSink => _personController.sink;

  Stream<ApiResponse<List<User>>> get peopleListStream =>
      _peopleListController.stream;
  Stream<ApiResponse<User>> get personStream => _personController.stream;

  PeopleBloc({@required this.queueId, @required this.status}) {
    _peopleListController = StreamController<ApiResponse<List<User>>>();
    _personController = StreamController<ApiResponse<User>>();

    _peopleRepository = UserRepository();
    fetchPeopleList();
  }

  fetchPeopleList({String status}) async {
    this.status = status;
    peopleListSink.add(ApiResponse.loading('Fetching Popular Subscribers'));
    personSink.add(ApiResponse.loading('Loading persons\'s details'));
    try {
//      log('Fetching users data');
      // TODO call api repository with the status
      peopleList = rawPeopleList;
      addPersonDetails(peopleList[0]);
      // TODO Check for empty list
      if (peopleList.length == 0) {
        peopleListSink.add(ApiResponse.error('Nobody is in queue'));
      }
      peopleListSink.add(ApiResponse.completed(peopleList));

//      log('Added people list to sink');
    } catch (e) {
      peopleListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  cancelToken() async {
    log('Canceling token');
    // TODO Cancel the token of current person
    rawPeopleList.removeAt(0);
    // fetch new people list
    fetchPeopleList(status: status);
  }

  nextToken() async {
    log('Moving to token');
    // TODO make the token of current person as done
    rawPeopleList.removeAt(0);

    // fetch new people list
    fetchPeopleList(status: status);
  }

  addPersonDetails(User user) {
    personSink.add(ApiResponse.completed(user));
    person = user;
  }

  endQueue({bool isForced}) async {
    log('Ending queue..{isForced:$isForced}');
    return;
    // TODO
    final String accessToken =
        await SubscriberRepository().getAccessTokenFromStorage();
    var response;
    response = await QueueRepository().endQueue(
      queueId: this.queueId,
      isForced: isForced,
      accessToken: accessToken,
    );
  }

  dispose() {
    _peopleListController?.close();
    _personController?.close();
  }
}

final sampleJson = '''
{
    "user": [
        {
            "user_id": "teAZLZQQz",
            "name": "Piyush|Chauhan",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 1
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "Harsh|Chauhan",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 2
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898009900",
            "token_no": 3
        },
        {
            "user_id": "teAZLZQQz",
            "name": "Kavya1",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 4
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "K2",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 5
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898099200",
            "token_no": 6
        },
        {
            "user_id": "teAZLZQQz",
            "name": "Kavya1",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 7
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "K2",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 8
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898009900",
            "token_no": 9
        }
    ]
}
''';
List<User> rawPeopleList = usersFromJson(sampleJson).user;

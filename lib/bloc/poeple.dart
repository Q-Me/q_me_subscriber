import 'package:flutter/material.dart';
import 'package:qme_subscriber/repository/queue.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import '../repository/user.dart';
import '../api/base_helper.dart';
import '../api/app_exceptions.dart';
import '../model/user.dart';
import 'dart:async';
import 'dart:developer';

class PeopleBloc extends ChangeNotifier {
  UserRepository _peopleRepository;

  String queueId, status, _accessToken;
  List<User> peopleList;
  User person;

  StreamController _peopleListController;
  StreamController _personController;

  StreamSink<ApiResponse<List<User>>> get peopleListSink =>
      _peopleListController.sink;
  StreamSink<ApiResponse<User>> get personSink => _personController.sink;

  Stream<ApiResponse<List<User>>> get peopleListStream =>
      _peopleListController.stream;
  Stream<ApiResponse<User>> get personStream => _personController.stream;

  PeopleBloc({@required this.queueId, @required this.status}) {
    log('PeopleBloc initializes with queueId:$queueId and status:$status');
    _peopleListController = StreamController<ApiResponse<List<User>>>();
    _personController = StreamController<ApiResponse<User>>();

    _peopleRepository = UserRepository();
    fetchPeopleList();
  }

  fetchPeopleList({String status}) async {
    this.status = status != null ? status : this.status;
    peopleListSink.add(ApiResponse.loading('Fetching people\'s list'));
    personSink.add(ApiResponse.loading('Loading persons\'s details'));
    try {
      log('Fetching users data for queue:$queueId and status:${this.status}');
      _accessToken = _accessToken == null
          ? await SubscriberRepository().getAccessTokenFromStorage()
          : _accessToken;

      // call api repository with the status
      final response = await _peopleRepository.getQueueUser(
          queueId: queueId, status: this.status, accessToken: _accessToken);
      log('People Repository API response:' + response.toString());
      peopleList = Users.fromJson(response).user;

      // Check for empty list
      if (peopleList.length == 0) {
        log('Empty list');
        peopleListSink.add(ApiResponse.error('Nobody is in queue'));
        personSink.add(ApiResponse.error(
            'Since nobody is in queue. Cannot fetch peron\'s details.'));
      } else {
        log('Added people list to sink');
        addPersonDetails(peopleList[0]);
        peopleListSink.add(ApiResponse.completed(peopleList));
      }
    } catch (e) {
      peopleListSink.add(ApiResponse.error(e.toString()));
      log('Error in PeopleBloc:' + e.toString());
    }
  }

  cancelToken() async {
    log('Canceling token');
    // TODO Cancel the token of current person
    try {
      final response = await QueueRepository().nextQueue(
          queueId: this.queueId,
          accessToken: this._accessToken,
          status: "CANCELLED BY SUBSCRIBER");
      log('Cancel Queue Response: ' + response.toString());
      // TODO return the response on success
    } catch (e) {
      log('Cancel API call failed:' + e.toString());
    }

    // fetch new people list
    fetchPeopleList(status: status);
  }

  nextToken() async {
    log('Moving to token');
    // make the token of current person as done
    try {
      final response = await QueueRepository().nextQueue(
          queueId: this.queueId,
          accessToken: this._accessToken,
          status: "DONE");
      log('Next Token Response: ' + response.toString());
      // TODO show the response on success

    } catch (e) {
      log('Next Token call failed:' + e.toString());
    }

    // fetch new people list
    fetchPeopleList(status: status);
  }

  addPersonDetails(User user) {
    personSink.add(ApiResponse.completed(user));
    person = user;
  }

  endQueue({@required bool isForced}) async {
    log('Ending queue..{isForced:$isForced}');
    //
    try {
      final response = await QueueRepository().endQueue(
        queueId: this.queueId,
        isForced: isForced,
        accessToken: _accessToken,
      );

      log('End Queue repository response:' + response.toString());
      return 'Queue ended successfully.';
    } on BadRequestException catch (e) {
      log('Error in ending queue:${e.toString()}');
      return e.toMap()['error'];
    } catch (e) {
      log('Ending queue failed.' + e.toString());
      return e.toString();

      // TODO show the response on success
    }
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

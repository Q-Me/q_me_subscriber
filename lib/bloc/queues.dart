import 'package:flutter/material.dart';
import 'package:qme_subscriber/api/app_exceptions.dart';
import '../repository/subscriber.dart';

import '../repository/queue.dart';
import 'dart:async';
import 'dart:developer';
import '../api/base_helper.dart';
import '../model/queue.dart';
import '../model/subscriber.dart';

class QueuesBloc extends ChangeNotifier {
  Subscriber subscriberData;
  String _accessToken, queueStatus;

  QueueRepository _queuesRepository;
  SubscriberRepository _subscriberRepository;

  StreamController _queuesListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;

  QueuesBloc({this.queueStatus}) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _queuesRepository = QueueRepository();
    _subscriberRepository = SubscriberRepository();
    subscriberData = Subscriber();
//    fetchProfile();
    fetchQueuesList(status: queueStatus);
  }

  fetchQueuesList({String status}) async {
    final String message = 'Fetching $status Queues';
//    log('Queues BLOC: fetchQueueList' + message);
    queuesListSink.add(ApiResponse.loading(message));
    try {
      _accessToken = _accessToken == null
          ? await _subscriberRepository.getAccessToken()
          : _accessToken;
      // TODO If invalid token get new access token
//      log('AccessToken on QueuesBloc is : $_accessToken');
      final response = await _queuesRepository.viewAllQueue(
          status: status ?? queueStatus, accessToken: _accessToken);
      final List<Queue> queues = Queues.fromJson(response).queue;
      queuesListSink.add(ApiResponse.completed(queues));
    } catch (e) {
      queuesListSink.add(ApiResponse.error(e.toString()));
      log('Error in QueuesBloc:fetchQueuesList: ' + e.toString());
    }
  }

  fetchProfile() async {
    var response;
    try {
      response = await _subscriberRepository.profile(_accessToken);
      log('Queues BLOC fetchProfile: ' + response.toString());
      subscriberData = Subscriber.fromJson(response);
    } catch (e) {
      log('Error in profile API: ' + e.toString());
      return;
    }
  }

  deleteQueue({@required queueId}) async {
    log('deleting queue');
    try {
      final response = await _queuesRepository.cancelQueue(
          queueId: queueId, accessToken: _accessToken);
      log('Queue: $queueId is deleted successfully');
      return 'Queue Delete Success';
    } on BadRequestException catch (e) {
      log('Bad request:' + e.toMap()['error']);
      return e.toMap()['error'];
    } catch (e) {
      log('Error in deleting queue:' + e.toString());
      return e.toString();
    }
  }

  @override
  dispose() {
    _queuesListController?.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import '../repository/subscriber.dart';

import '../repository/queue.dart';
import 'dart:async';
import 'dart:developer';
import '../api/base_helper.dart';
import '../model/queue.dart';

class QueuesBloc extends ChangeNotifier {
  String subscriberId, queueStatus;
  QueueRepository _queuesRepository;

  StreamController _queuesListController;

  StreamSink<ApiResponse<List<Queue>>> get queuesListSink =>
      _queuesListController.sink;

  Stream<ApiResponse<List<Queue>>> get queuesListStream =>
      _queuesListController.stream;

  QueuesBloc({this.subscriberId, String queueStatus}) {
    _queuesListController = StreamController<ApiResponse<List<Queue>>>();
    _queuesRepository = QueueRepository();
    fetchQueuesList(queueStatus);
  }

  fetchQueuesList(String status) async {
    queuesListSink.add(ApiResponse.loading('Fetching $queueStatus Queues'));
    try {
      final accessToken = await SubscriberRepository().getAccessToken();
      final response = await _queuesRepository.viewAllQueue(
          status: status, accessToken: accessToken);
      final List<Queue> queues = Queues.fromJson(response).queue;
      queuesListSink.add(ApiResponse.completed(queues));
    } catch (e) {
      queuesListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _queuesListController?.close();
  }
}

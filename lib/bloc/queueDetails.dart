import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qme_subscriber/api/base_helper.dart';
import 'package:qme_subscriber/repository/queue.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'dart:developer';
import '../model/queue.dart';

class QueueDetailsBloc extends ChangeNotifier {
  String queueId;
  String _accessToken;
  QueueRepository _queueRepository;
  Queue queue;

  StreamController _queueDetailsController;

  StreamSink<ApiResponse<Queue>> get queueDetailsSink =>
      _queueDetailsController.sink;

  Stream<ApiResponse<Queue>> get queueDetailsStream =>
      _queueDetailsController.stream;

  QueueDetailsBloc(this.queueId) {
    log('QueueDetailsBloc constructor:$queueId');

    _queueRepository = QueueRepository();
    _queueDetailsController = StreamController<ApiResponse<Queue>>();
    fetchQueueDetails();
  }

  fetchQueueDetails() async {
    queueDetailsSink.add(ApiResponse.loading('Fetching Queue details'));
    var response;
    try {
      _accessToken = await SubscriberRepository().getAccessTokenFromStorage();
      log('got access token: $_accessToken');
      response = await _queueRepository.viewQueue(
        queueId: queueId,
        accessToken: _accessToken,
      );

      log('ViewQueue API response: ${response.toString()}');
      queue = Queue.fromJson(response['queue']);

      queueDetailsSink.add(ApiResponse.completed(queue));
    } catch (e) {
      queueDetailsSink.add(ApiResponse.error(e.toString()));
      log(e.toString());
    }
  }

  Future<String> startQueue() async {
    try {
      final response = await _queueRepository.startQueue(
          queueId: queueId, accessToken: _accessToken);
      log('Start Queue API response:' + response.toString());
      return response['msg'];
    } catch (e) {
      final msg = 'Start Queue error:' + e.toString();
      log(msg);
      return msg;
    }
  }

  dispose() {
    _queueDetailsController?.close();
  }
}

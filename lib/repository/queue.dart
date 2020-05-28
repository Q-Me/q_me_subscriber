import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import '../api/endpoints.dart';
import '../api/base_helper.dart';

class QueueRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Map<String, dynamic>> createQueue({
    @required Map<String, String> queueDetails,
    @required String accessToken,
  }) async {
//    log('Queue Repository: Create Queue : ${queueDetails.toString()}');
    final response = await _helper.post(
      kCreateQueue,
      req: queueDetails,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    //DELETE FROM `activequeue` WHERE `subscriber_id` = `aTCiQhsHV`
    return response;
  }

  Future<Map<String, dynamic>> viewAllQueue({
    @required String status,
    @required String accessToken,
  }) async {
//    log('Queue Repository: Getting all queues with status $status');
    final response = await _helper.post(
      kViewAllQueues,
      req: {"status": status},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewQueue({
    @required String queueId,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kViewQueue,
      req: {"queue_id": queueId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> cancelQueue({
    @required String queueId,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kCancelQueue,
      req: {"queue_id": queueId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> startQueue({
    @required String queueId,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kStartQueue,
      req: {"queue_id": queueId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> nextQueue({
    @required String queueId,
    @required String status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kNextQueue,
      req: {"queue_id": queueId, "status": status},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> endQueue({
    @required String queueId,
    @required bool isForced,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kEndQueue,
      req: {"queue_id": queueId, "isForced": "$isForced"},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}

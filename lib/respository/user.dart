import 'package:flutter/material.dart';
import 'dart:async';
import '../api/endpoints.dart';
import '../api/base_helper.dart';

class UserRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Map<String, dynamic>> getUser({
    @required String userId,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kGetUser,
      req: {"user_id": userId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> getQueueUser({
    @required String queueId,
    @required String status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kGetQueueUser,
      req: {"queue_id": queueId, "status": status},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}

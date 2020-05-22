import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

import 'package:qme_subscriber/api/base_helper.dart';
import '../model/subscriber.dart';
import '../repository/subscriber.dart';

class SignUpBloc {
  SubscriberRepository _subscriberRepository;

  StreamController _signUp;

  StreamSink<ApiResponse<String>> get signUpSink => _signUp.sink;

  Stream<ApiResponse<String>> get signUpStream => _signUp.stream;

  SignUpBloc() {
    _signUp = StreamController<ApiResponse<String>>();
    _subscriberRepository = SubscriberRepository();
  }

  signUp(Map<String, dynamic> formData) async {
    log('');
    signUpSink.add(ApiResponse.loading('Signing Up...'));
    try {
      final response = await _subscriberRepository.signUp(formData);
      signUpSink.add(ApiResponse.completed(response['msg']));
    } catch (e) {
      signUpSink.add(ApiResponse.error(e.toString()));
    }
  }

  dispose() {
    _signUp.close();
  }
}

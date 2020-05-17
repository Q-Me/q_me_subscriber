import 'package:flutter/material.dart';
import 'dart:async';
import '../api/endpoints.dart';
import '../api/base_helper.dart';

class SubscriberRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  Future<Map<String, dynamic>> authenticate(
      {@required String email, @required String password}) {
    return null;
  }

  Future<Map<String, dynamic>> signUp(Map formData) async {
    final Map response = await _helper.post(kSignUp, req: formData);
    return response;
  }

  Future<Map<String, dynamic>> signIn(Map<String, String> formData) async {
    final response = await _helper.post(kSignIn, req: formData);
    return response; // Store access Token, refresh token and id
  }

  Future<Map<String, dynamic>> profile(String accessToken) async {
    final response = await _helper.post(
      kProfile,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> accessToken(String refreshToken) async {
    final response =
        await _helper.post(kAccessToken, req: {"refreshToken": refreshToken});
    return response;
  }

  Future<Map<String, dynamic>> signOut(String accessToken) async {
    final response = await _helper.post(
      kSignOut,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}

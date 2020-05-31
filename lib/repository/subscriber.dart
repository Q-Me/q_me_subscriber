import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import '../model/subscriber.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/endpoints.dart';
import '../api/base_helper.dart';
import 'dart:math' show Random;

class SubscriberRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  Future<Map<String, dynamic>> authenticate(
      {@required String email, @required String password}) {
    return null;
  }

  Future<Map<String, dynamic>> signUp(Map<String, String> formData) async {
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

  Future storeSubscriberData(Subscriber subscriberData) async {
    // Set the user id, and other details are stored in local storage of the app
    SharedPreferences prefs = await SharedPreferences.getInstance();
    log('STORING ${subscriberData.toJson()}');
    if (subscriberData.id != null) prefs.setString('id', subscriberData.id);
    if (subscriberData.name != null)
      prefs.setString('name', subscriberData.name);
    if (subscriberData.accessToken != null) {
      prefs.setString('accessToken', subscriberData.accessToken);
      prefs.setString(
          'expiry', DateTime.now().add(Duration(days: 1)).toString());
    }
    if (subscriberData.refreshToken != null) {
      prefs.setString('refreshToken', subscriberData.refreshToken);
    }
    if (subscriberData.email != null)
      prefs.setString('isUser', subscriberData.email);
    if (subscriberData.phone != null)
      prefs.setString('isUser', subscriberData.phone);

    log('Storing user data success');

    return;
  }

  Future<Subscriber> getSubscriberDataFromStorage() async {
    // See if user id, and other details are stored in local storage of the app
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String id = prefs.getString('id') ?? null;
    String name = prefs.getString('name') ?? null;
    String accessToken = prefs.getString('accessToken') ?? null;
    String refreshToken = prefs.getString('refreshToken') ?? null;
    String email = prefs.getString('email') ?? null;
    String phone = prefs.getString('phone') ?? null;

    return Subscriber(
      id: id,
      name: name,
      accessToken: accessToken,
      refreshToken: refreshToken,
      email: email,
      phone: phone,
    );
  }

  Future<String> getAccessToken({String refreshToken, prefs}) async {
    SharedPreferences _prefs = prefs ?? await SharedPreferences.getInstance();
    final String _refreshToken = refreshToken ?? await getRefreshToken();
    var response;
    try {
      response = await accessToken(_refreshToken);
    } catch (e) {
      log('Error in getting new accessToken API: ' + e.toString());
      return '-1';
    }
//    log('Refresh Token API response: ' + response.toString());
    _prefs.setString('accessToken', response['accessToken']);
    _prefs.setString(
        'expiry', DateTime.now().add(Duration(days: 1)).toString());

    return response['accessToken'];
  }

  Future<String> getAccessTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? null;
    return accessToken;
  }

  Future<String> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString('refreshToken') ?? null;
//    log('refresh Token from storage: $refreshToken');
    return refreshToken;
  }

  Future<bool> isTokenExpired() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString('expiry');
    if (expiry == null) {
      return true;
    }
    return DateTime.now().isAfter(DateTime.parse(prefs.getString('expiry')));
  }

  Future<bool> isRefreshTokenSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('expiry') != null &&
            prefs.getString('refreshToken') != null
        ? true
        : false;
  }

  Future<bool> isSessionReady() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getString('expiry');
    final refreshToken = prefs.getString('refreshToken');
    final accessToken = prefs.getString('accessToken');

    if (expiry != null &&
        DateTime.now().isBefore(DateTime.parse(expiry)) &&
        accessToken != null) {
      // accessToken is valid
      return true;
    } else {
      // invalid accessToken
      if (refreshToken != null) {
        // Get new accessToken from refreshToken
        final result =
            await getAccessToken(refreshToken: refreshToken, prefs: prefs);
        return result != '-1' ? true : false;
      } else {
        return false;
      }
    }
  }
}

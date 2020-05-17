import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_exceptions.dart';
import 'dart:io';
import 'endpoints.dart';
import 'dart:developer';

class ApiBaseHelper {
  Future<dynamic> get(String url) async {
    var responseJson;
    try {
      final response = await http.get(baseURL + url);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url,
      {Map req, Map<String, String> headers}) async {
    var responseJson;
    try {
      if (req != null) {
        headers['Accept'] = 'application/json';
        headers['Content-type'] = 'application/json';
      }
//      log('Posting to ${baseURL + url}\nRequest:$req\nHeader:$headers');
      final response = await http.post(
        baseURL + url,
        headers: headers,
        body: jsonEncode(req),
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
//        log('Response:$responseJson');
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}

enum Status { LOADING, COMPLETED, ERROR }

class ApiResponse<T> {
  Status status;
  T data;
  String message;

  ApiResponse.loading(this.message) : status = Status.LOADING;
  ApiResponse.completed(this.data) : status = Status.COMPLETED;
  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

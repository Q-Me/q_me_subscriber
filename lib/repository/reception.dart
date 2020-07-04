import 'package:meta/meta.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';

class ReceptionRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<Map<String, dynamic>> createReception({
    @required DateTime startTime,
    @required DateTime endTime,
    @required int slotDuration,
    @required int customerPerSlot,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kCreateReception,
      req: {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "slot": slotDuration.toString(),
        "cust_per_slot": customerPerSlot.toString(),
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> overrideSlot({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required int customerPerSlotOverride,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kOverrideSlot,
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "override": customerPerSlotOverride.toString(),
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> cancelAppointment({
    @required String counterId,
    @required String phone,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kCancelAppointment,
      req: {
        "counter_id": counterId,
        "cust_phone": phone,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewReception({
    @required String counterId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      kViewReception,
      req: {"counter_id": counterId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewOverrides({
    @required String counterId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      kViewOverride,
      req: {"counter_id": counterId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewBookings({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required List<String> status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kSlotBookings,
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "override": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewBookingsDetailed({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required List<String> status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kSlotBookingsDetailed,
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "override": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> bookAppointment({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required String customerName,
    @required String phone,
    @required String note,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kBookAppointment,
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "cust_name": customerName,
        "cust_phone": phone,
        "note": note,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> completeAppointment({
    @required String counterId,
    @required String phone,
    @required int otp,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kDoneAppointment,
      req: {
        "counter_id": counterId,
        "cust_phone": phone,
        "otp": otp,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> updateReceptionStatus({
    @required String counterId,
    @required String status,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      kViewDetailedCounter,
      req: {
        "counter_id": counterId,
        "status": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Map<String, dynamic>> viewReceptionDetailed({
    @required String counterId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      kViewDetailedCounter,
      req: {"counter_id": counterId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }
}

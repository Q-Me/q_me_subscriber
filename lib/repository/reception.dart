import 'package:meta/meta.dart';
import 'package:qme_subscriber/controllers/slots.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/model/slot.dart';
import 'package:qme_subscriber/repository/subscriber.dart';

import '../api/base_helper.dart';
import '../api/endpoints.dart';
import '../model/reception.dart';

class ReceptionRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  Future<dynamic> createReception({
    @required DateTime startTime,
    @required DateTime endTime,
    @required int slotDurationInMinutes,
    @required int customerPerSlot,
    String accessToken,
  }) async {
    accessToken = accessToken != null
        ? accessToken
        : await SubscriberRepository().getAccessTokenFromStorage();
    final response = await _helper.post(
      kCreateReception,
      req: {
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "slot": slotDurationInMinutes.toString(),
        "cust_per_slot": customerPerSlot.toString(),
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return response['msg'] == 'Counter Created Successfully'
        ? response['msg']
        : response["error"].toString();
  }

  Future<List<Reception>> viewReceptionsByStatus({
    @required List<String> status,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      kViewReceptions,
      req: {
        "status": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    List<Reception> receptions = [];
    for (var element in response['counters']) {
      receptions.add(Reception.fromJson(Map<String, dynamic>.from(element)));
    }
    return receptions;
  }

  Future<Map<String, dynamic>> createOverrideSlot({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required int customerPerSlotOverride,
    @required String accessToken,
  }) async {
    final response = await _helper.post(
      '/subscriber/slot/override',
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
    String accessToken,
  }) async {
    accessToken = await SubscriberRepository().getAccessTokenFromStorage();
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

  Future<Reception> viewReception({
    @required String receptionId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      '/subscriber/slot/viewcounter',
      req: {"counter_id": receptionId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    // todo test
    return Reception.fromJson(response);
  }

  Future<List<Slot>> viewOverrides({
    @required String counterId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      '/subscriber/slot/viewOverride',
      req: {"counter_id": counterId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    // todo test
    return createOverrideSlots(response);
  }

  Future<List<Slot>> viewBookings({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required List<String> status,
    @required int slotDurationInMinutes,
    String accessToken,
  }) async {
    accessToken = accessToken != null
        ? accessToken
        : await SubscriberRepository().getAccessTokenFromStorage();
    final response = await _helper.post(
      '/subscriber/slot/bookings',
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "status": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // make a list of slots containing number of appointments
    List<Slot> slots = [];
    for (var element in response["slot info"]) {
      DateTime startTime = DateTime.parse(element["starttime"]).toLocal();
      Slot slot = Slot(
        booked: element["count"],
        startTime: startTime,
        endTime: startTime.add(Duration(
          minutes: slotDurationInMinutes,
        )),
      );
      slots.add(slot);
    }
    slots = orderSlotsByStartTime(slots);

    // todo test
    return slots;
  }

  Future<List<Appointment>> viewBookingsDetailed({
    @required String counterId,
    @required DateTime startTime,
    @required DateTime endTime,
    @required List<String> status,
    String accessToken,
  }) async {
    accessToken = await SubscriberRepository().getAccessTokenFromStorage();
    final response = await _helper.post(
      kSlotBookingsDetailed,
      req: {
        "counter_id": counterId,
        "starttime": startTime.toIso8601String(),
        "endtime": endTime.toIso8601String(),
        "status": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // make a list of  appointments
    List<Appointment> appointments = [];
    for (var appointmentElement in response["slots"]) {
      appointments.add(
        Appointment.fromJson(Map<String, dynamic>.from(appointmentElement)),
      );
    }
    // TODO test
    return appointments;
  }

  Future<Map<String, dynamic>> bookAppointment({
    @required String receptionId,
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
        "counter_id": receptionId,
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
    @required String otp,
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
      kUpdateReceptionStatus,
      req: {
        "counter_id": counterId,
        "status": status,
      },
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    return response;
  }

  Future<Reception> viewReceptionDetailed({
    @required String counterId,
    @required accessToken,
  }) async {
    final response = await _helper.post(
      kViewDetailedCounter,
      req: {"counter_id": counterId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    // Create Reception
    Reception reception = Reception.fromJson(response["counter"]);

    // create slots from reception duration
    List<Slot> slots = reception.slotList;

    final List overrideResponse = response['overrides'];
    if (overrideResponse != null &&
        overrideResponse is List &&
        overrideResponse.length != 0) {
      // apply overrides slots
      slots = overrideSlots(slots, createOverrideSlots(response));
    }

    // TODO Handle slot_done
    final List bookedSlots = response['slots_upcoming'];
    if (bookedSlots != null &&
        bookedSlots is List &&
        bookedSlots.length != null) {
      // update slots according to bookings
      slots = modifyBookings(slots, bookedSlots);
    }

    reception.replaceSlots(slots);
    return reception;
  }
}

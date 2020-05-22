// To parse this JSON data, do
//
//     final queues = queuesFromJson(jsonString);

import 'dart:convert';

Queues queuesFromJson(String str) => Queues.fromJson(json.decode(str));

String queuesToJson(Queues data) => json.encode(data.toJson());

class Queues {
  List<Queue> queue;

  Queues({
    this.queue,
  });

  factory Queues.fromJson(Map<String, dynamic> json) => Queues(
        queue: List<Queue>.from(json["queue"].map((x) => Queue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "queue": List<dynamic>.from(queue.map((x) => x.toJson())),
      };
}

class Queue {
  String queueId;
  String subscriberId;
  DateTime startDateTime;
  DateTime endDateTime;
  int maxAllowed;
  int avgTimeOnCounter;
  String status;
  int currentToken;
  int lastIssuedToken;
  DateTime lastUpdate;
  int totalIssuedTokens;

  Queue({
    this.queueId,
    this.subscriberId,
    this.startDateTime,
    this.endDateTime,
    this.maxAllowed,
    this.avgTimeOnCounter,
    this.status,
    this.currentToken,
    this.lastIssuedToken,
    this.lastUpdate,
    this.totalIssuedTokens,
  });

  factory Queue.fromJson(Map<String, dynamic> json) => Queue(
        queueId: json["queue_id"],
        subscriberId: json["subscriber_id"],
        startDateTime: DateTime.parse(json["start_date_time"]),
        endDateTime: DateTime.parse(json["end_date_time"]),
        maxAllowed: json["max_allowed"],
        avgTimeOnCounter: json["avg_time_on_counter"],
        status: json["status"],
        currentToken: json["current_token"],
        lastIssuedToken: json["last_issued_token"],
        lastUpdate: DateTime.parse(json["last_update"]),
        totalIssuedTokens: json["total_issued_tokens"],
      );

  Map<String, dynamic> toJson() => {
        "queue_id": queueId,
        "subscriber_id": subscriberId,
        "start_date_time": startDateTime.toIso8601String(),
        "end_date_time": endDateTime.toIso8601String(),
        "max_allowed": maxAllowed,
        "avg_time_on_counter": avgTimeOnCounter,
        "status": status,
        "current_token": currentToken,
        "last_issued_token": lastIssuedToken,
        "last_update": lastUpdate.toIso8601String(),
        "total_issued_tokens": totalIssuedTokens,
      };
}

final sampleJson = """
{
    "queue": [
        {
            "queue_id": "yl3IWW4rA",
            "subscriber_id": "4Q3fOuppX",
            "start_date_time": "2021-05-01T18:36:00.000Z",
            "end_date_time": "2021-05-01T23:30:00.000Z",
            "max_allowed": 100,
            "avg_time_on_counter": 3,
            "status": "UPCOMING",
            "current_token": 0,
            "last_issued_token": 0,
            "last_update": "2020-04-30T17:52:55.000Z",
            "total_issued_tokens": 0
        },
        {
            "queue_id": "ncgPSe8di",
            "subscriber_id": "4Q3fOuppX",
            "start_date_time": "2021-05-02T18:36:00.000Z",
            "end_date_time": "2021-05-02T23:30:00.000Z",
            "max_allowed": 1000000000,
            "avg_time_on_counter": 3,
            "status": "UPCOMING",
            "current_token": 0,
            "last_issued_token": 0,
            "last_update": "2020-04-30T17:55:40.000Z",
            "total_issued_tokens": 0
        }
    ]
}
""";

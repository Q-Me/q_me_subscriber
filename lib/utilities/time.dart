import 'package:intl/intl.dart';

import '../model/queue.dart';

String getDate(DateTime dateTime) => DateFormat("dd-MM-yyyy").format(dateTime);

String getTime(DateTime dateTime) => DateFormat("jm").format(dateTime);

DateTime nextTokenTime(Queue queue) => queue.startDateTime
    .add(Duration(minutes: queue.totalIssuedTokens * queue.avgTimeOnCounter));

String getFullDateTime(DateTime dateTime) =>
    DateFormat('hh:mm aaa\nMMM d, yyyy\nEEE').format(dateTime);

String getApiDateTime(DateTime dateTime) =>
    DateFormat('MM-dd-yyyy HH:mm').format(dateTime);

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}

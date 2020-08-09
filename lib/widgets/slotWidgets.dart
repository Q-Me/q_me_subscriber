import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qme_subscriber/model/slot.dart';

class SlotDetails extends StatelessWidget {
  const SlotDetails({
    Key key,
    @required this.slot,
  }) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "${DateFormat('d MMMM y').format(slot.startTime)}",
          style: Theme.of(context).textTheme.headline6,
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: TimeCard(
                text: 'Start',
                dateTime: slot.startTime,
              ),
            ),
            Expanded(
              child: TimeCard(
                text: 'End',
                dateTime: slot.endTime,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TimeCard extends StatelessWidget {
  final String text;
  final DateTime dateTime;

  TimeCard({@required this.text, @required this.dateTime});

  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10) return '0$value';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final String hourLabel = _addLeadingZeroIfNeeded(dateTime.hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(dateTime.minute);
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: ListTile(
          contentPadding: EdgeInsets.only(
            left: 10,
            // top: 10,
          ),
          leading: Icon(
            Icons.access_time,
            size: 36,
          ),
          title: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            '$hourLabel:$minuteLabel',
            style: Theme.of(context)
                .textTheme
                .headline5
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class SlotListTile extends StatelessWidget {
  const SlotListTile({
    Key key,
    @required this.slot,
  }) : super(key: key);

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${DateFormat('d MMMM y').format(slot.startTime)} at ${DateFormat.jm().format(slot.startTime)}',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      subtitle: Text(
        '${slot.endTime.difference(slot.startTime).inMinutes} min, ends at ${DateFormat.jm().format(slot.endTime)}',
      ),
    );
  }
}

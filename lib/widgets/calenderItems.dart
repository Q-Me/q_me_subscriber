import 'package:flutter/material.dart';

monthNameWidget(monthName) {
  return Container(
    child: Text(monthName,
        style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontStyle: FontStyle.italic)),
    padding: EdgeInsets.only(top: 8, bottom: 4),
  );
}

dateTileBuilder(
  date,
  selectedDate,
  rowIndex,
  dayName,
  isDateMarked,
  isDateOutOfRange,
) {
  bool isSelectedDate = date.compareTo(selectedDate) == 0;
  Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
  TextStyle normalStyle =
      TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fontColor);
  TextStyle selectedStyle = TextStyle(
      fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87);
  TextStyle dayNameStyle = TextStyle(fontSize: 14.5, color: fontColor);
  List<Widget> _children = [
    Text(dayName, style: dayNameStyle),
    Text(date.day.toString(),
        style: !isSelectedDate ? normalStyle : selectedStyle),
  ];

  if (isDateMarked == true) {
    _children.add(getMarkedIndicatorWidget());
  }

  return AnimatedContainer(
    duration: Duration(milliseconds: 150),
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
    decoration: BoxDecoration(
      color: !isSelectedDate ? Colors.transparent : Colors.white70,
      borderRadius: BorderRadius.all(Radius.circular(60)),
    ),
    child: Column(
      children: _children,
    ),
  );
}

Widget getMarkedIndicatorWidget() {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(
      margin: EdgeInsets.only(left: 1, right: 1),
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
    ),
    Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
    )
  ]);
}

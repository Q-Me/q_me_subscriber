import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  static const String id = '/appointments';
  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

const names = <String>[
  'Annie',
  'Arianne',
  'Bertie',
  'Bettina',
  'Bradly',
  'Caridad',
  'Carline',
  'Cassie',
  'Chloe',
  'Christin',
  'Clotilde',
  'Dahlia',
  'Dana',
  'Dane',
  'Darline',
  'Deena',
  'Delphia',
  'Donny',
  'Echo',
  'Else',
  'Ernesto',
  'Fidel',
  'Gayla',
  'Grayce',
  'Henriette',
  'Hermila',
  'Hugo',
  'Irina',
  'Ivette',
  'Jeremiah',
  'Jerica',
  'Joan',
  'Johnna',
  'Jonah',
  'Joseph',
  'Junie',
  'Linwood',
  'Lore',
  'Louis',
  'Merry',
  'Minna',
  'Mitsue',
  'Napoleon',
  'Paris',
  'Ryan',
  'Salina',
  'Shantae',
  'Sonia',
  'Taisha',
  'Zula',
];

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  DateTime selectedDate = DateTime.now();
  List<DateTime> markedDates = [
    DateTime.now().add(Duration(days: 1)),
    DateTime.now().add(Duration(days: 3)),
  ];

  onSelect(data) {
    print("Selected Date -> $data");
  }

  _monthNameWidget(monthName) {
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

  getMarkedIndicatorWidget() {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(10, 30, 10, 20),
              child: Icon(
                Icons.menu,
                size: 30,
              ),
            ),
            CalendarStrip(
              startDate: startDate,
              endDate: endDate,
              onDateSelected: onSelect,
              dateTileBuilder: dateTileBuilder,
              iconColor: Colors.black87,
              monthNameWidget: _monthNameWidget,
              markedDates: markedDates,
              containerDecoration: BoxDecoration(color: Colors.black12),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: (names.length / 5).floor(),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 5,
                          child: Opacity(
                            opacity: index % 2 == 0 ? 1 : 0,
                            child: Text(
                              names[index],
                              style: Theme.of(context).textTheme.headline5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 4 / 5,
                          child: Wrap(
                            children: List.from(
                              names.sublist(index, index + 5).map(
                                    (e) => Text(
                                      e,
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

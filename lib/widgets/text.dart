import 'package:flutter/material.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

class ThemedText extends StatelessWidget {
  final double fontSize;
  final words;
  ThemedText({this.words, this.fontSize: 60});

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var word in words.sublist(0, words.length - 1)) {
      widgetList.add(
        Row(
          children: <Widget>[
            Text(
              word,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    widgetList.add(Row(
      children: <Widget>[
        Text(
          words[words.length - 1],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '.',
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.green),
        )
      ],
    ));

    return Container(
      child: ColumnSuper(
        alignment: Alignment(-1, 0),
        children: widgetList,
        innerDistance: -fontSize / 2.5,
      ),
    );
  }
}

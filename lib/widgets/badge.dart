import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final MaterialColor color;
  final String label;
  Badge({
    @required this.label,
    @required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

final Map<String, dynamic> badgeMap = {
  'WAITING': Badge(label: 'WAITING', color: Colors.yellow),
  'ACTIVE': Badge(label: 'ACTIVE', color: Colors.lightBlue),
  'DONE': Badge(label: 'DONE', color: Colors.green),
};

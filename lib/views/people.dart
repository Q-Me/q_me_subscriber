import 'package:flutter/material.dart';

class PeopleScreen extends StatefulWidget {
  static final id = 'people';
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('Queue Tokens'),
      ),
      body: SingleChildScrollView(),
    );
  }
}

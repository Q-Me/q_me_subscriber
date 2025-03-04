import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qme_subscriber/utilities/logger.dart';
import 'package:qme_subscriber/views/createAppointment.dart';
import 'package:qme_subscriber/views/createReception.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  FancyFab({this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget createAppointmentBtn() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, CreateAppointment.id);
        },
        elevation: 0,
        heroTag: "Create Appointment",
        tooltip: 'Create Appointment',
        child: Icon(Icons.person_add),
      ),
    );
  }

  Widget createReceptionBtn() {
    return Container(
      child: FloatingActionButton(
        elevation: 0,
        heroTag: "Create Reception",
        onPressed: () {
          DateTime selectedDate = Provider.of<DateTime>(context, listen: false);
          logger.d('Create reception route on date $selectedDate');
          Navigator.pushNamed(
            context,
            CreateReceptionScreen.id,
            arguments: selectedDate,
          );
        },
        tooltip: 'Create Reception',
        child: Icon(Icons.event),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        elevation: 0,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: createAppointmentBtn(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: createReceptionBtn(),
        ),
        toggle(),
      ],
    );
  }
}

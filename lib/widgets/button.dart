import 'package:flutter/material.dart';

class MyBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 20),
      color: Colors.transparent,
      alignment: Alignment(-1, -1),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          foregroundColor: Colors.white,
          radius: 20,
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
    );
  }
}

class ThemedSolidButton extends StatelessWidget {
  final String text, notification;
  final Function buttonFunction;
  const ThemedSolidButton({
    @required this.text,
    this.notification,
    @required this.buttonFunction,
  });

  @override
  Widget build(BuildContext context) {
    void displaySnackBar(String text) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
    }

    return Container(
      height: 50.0,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {
            if (notification != null) {
              displaySnackBar(notification);
            }
//            log('Solid Theme Button pressed');
            buttonFunction();
//            log('btn fn executed');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HollowSocialButton extends StatelessWidget {
  final String label;
  final img;
  final Function onPress;
  HollowSocialButton({this.label, this.img, this.onPress});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onPress,
      child: Container(
        height: 50.0,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black, style: BorderStyle.solid, width: 1.0),
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: img,
              ),
              SizedBox(width: 10.0),
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

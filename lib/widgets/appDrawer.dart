import 'package:flutter/material.dart';
import 'package:qme_subscriber/views/profile.dart';
import 'package:qme_subscriber/views/queues.dart';
import 'package:qme_subscriber/views/signin.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _createHeader(),
          _createDrawerItem(
            icon: Icons.home,
            text: 'Home',
            onTap: () => Navigator.pushReplacementNamed(context, QueuesPage.id),
          ),
          _createDrawerItem(
            icon: Icons.person,
            text: 'Profile',
            onTap: () =>
                Navigator.pushReplacementNamed(context, ProfileScreen.id),
          ),
          _createDrawerItem(
              icon: Icons.card_giftcard,
              text: 'Log out',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, SignInScreen.id)),
          Divider(),
          _createDrawerItem(icon: Icons.face, text: 'Authors'),
          _createDrawerItem(icon: Icons.bug_report, text: 'Report an issue'),
          ListTile(
            title: Text('0.0.1'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

Widget _createHeader() {
  return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/images/drawer_header_background.png'))),
      child: Stack(children: <Widget>[
        Positioned(
            bottom: 12.0,
            left: 16.0,
            child: Text("",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500))),
      ]));
}

Widget _createDrawerItem(
    {IconData icon, String text, GestureTapCallback onTap}) {
  return ListTile(
    title: Row(
      children: <Widget>[
        Icon(icon),
        Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(text),
        )
      ],
    ),
    onTap: onTap,
  );
}

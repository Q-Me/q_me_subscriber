import 'package:flutter/material.dart';
import 'package:qme_subscriber/constants.dart';
import '../model/user.dart';

final sampleJson = '''
{
    "user": [
        {
            "user_id": "teAZLZQQz",
            "name": "Kavya1",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 1
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "K2",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 2
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898009900",
            "token_no": 3
        },
        {
            "user_id": "teAZLZQQz",
            "name": "Kavya1",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 1
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "K2",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 2
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898009900",
            "token_no": 3
        },
        {
            "user_id": "teAZLZQQz",
            "name": "Kavya1",
            "email": "Kavya24@gmail.com",
            "phone": "9898009900",
            "token_no": 1
        },
        {
            "user_id": "YVVnAiZpp",
            "name": "K2",
            "email": "K2@gmail.com",
            "phone": "9898009900",
            "token_no": 2
        },
        {
            "user_id": "1wURstfk9",
            "name": "K3",
            "email": "K3@gmail.com",
            "phone": "9898009900",
            "token_no": 3
        }
    ]
}
''';

class PeopleScreen extends StatefulWidget {
  static final id = 'people';
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  final List<User> users = usersFromJson(sampleJson).user;
  User user;
  @override
  Widget build(BuildContext context) {
    user = users[0];

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
        title: Text('Queue Tokens'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user.name,
                              style: kBigTextStyle.copyWith(fontSize: 20),
                            ),
                            Text(
                              user.email,
                              style: kBigTextStyle.copyWith(fontSize: 15),
                            ),
                            Text(
                              user.phone,
                              style: kBigTextStyle.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Token No.',
                            style: kBigTextStyle,
                          ),
                          Text(
                            user.tokenNo.toString(),
                            style: kSmallTextStyle.copyWith(fontSize: 40),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    MyButton('Cancel Token'),
                    MyButton('Next Token'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: <Widget>[
                      Text('Token No.', style: kSmallTextStyle),
                      Spacer(flex: 1),
                      Text('Name of Person', style: kSmallTextStyle),
                      Spacer(flex: 6),
                      Text('Status', style: kSmallTextStyle),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User _user = users[index];
                  return TokenCard(user: _user);
                }),
          ),
        ],
      ),
    );
  }
}

class TokenCard extends StatelessWidget {
  const TokenCard({
    Key key,
    @required User user,
  })  : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Card(
        elevation: 3,
        shadowColor: Colors.greenAccent,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Spacer(flex: 1),
              Text(_user.tokenNo.toString(), style: kSmallTextStyle),
              Spacer(flex: 2),
              Text(_user.name),
              Spacer(flex: 5),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'WAITING',
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  final String label;
  MyButton(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Material(
        borderRadius: BorderRadius.circular(20.0),
        shadowColor: Colors.greenAccent,
        color: Colors.green,
        elevation: 7.0,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Text(
                label,
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

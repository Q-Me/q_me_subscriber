import 'package:flutter/material.dart';

import 'views/createQueue.dart';
import 'views/people.dart';
import 'views/profile.dart';
import 'views/queues.dart';
import 'views/receptions.dart';
import 'views/signin.dart';
import 'views/signup.dart';
import 'views/unknown.dart';
import 'views/viewQueue.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SignUpScreen.id:
      return MaterialPageRoute(
        builder: (context) => SignUpScreen(),
        settings: RouteSettings(name: SignUpScreen.id),
      );

    case SignInScreen.id:
      return MaterialPageRoute(
        builder: (context) => SignInScreen(),
        settings: RouteSettings(name: SignInScreen.id),
      );

    case QueuesScreen.id:
      return MaterialPageRoute(
        builder: (context) => QueuesScreen(),
        settings: RouteSettings(name: QueuesScreen.id),
      );

    case CreateQueueScreen.id:
      return MaterialPageRoute(
        builder: (context) => CreateQueueScreen(),
        settings: RouteSettings(name: CreateQueueScreen.id),
      );

    case ViewQueueScreen.id:
      String queueId = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => ViewQueueScreen(queueId: queueId),
        settings: RouteSettings(name: ViewQueueScreen.id),
      );

    case PeopleScreen.id:
      Map args = settings.arguments as Map;
      String status = args["status"];
      String queueId = args["queueId"];
      return MaterialPageRoute(
        builder: (context) =>
            PeopleScreen(queueId: queueId, tokenStatus: status),
        settings: RouteSettings(name: PeopleScreen.id),
      );

    case ProfileScreen.id:
      return MaterialPageRoute(
        builder: (context) => ProfileScreen(),
        settings: RouteSettings(name: ProfileScreen.id),
      );

    case AppointmentsScreen.id:
      return MaterialPageRoute(
        builder: (context) => AppointmentsScreen(),
        settings: RouteSettings(name: AppointmentsScreen.id),
      );

    default:
      return MaterialPageRoute(
        builder: (context) => UndefinedView(name: settings.name),
        settings: RouteSettings(name: UndefinedView.id),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:qme_subscriber/model/appointment.dart';
import 'package:qme_subscriber/views/appointment.dart';
import 'package:qme_subscriber/views/createAppointment.dart';
import 'package:qme_subscriber/views/createReception.dart';
import 'package:qme_subscriber/views/customerRecurrence.dart';
import 'package:qme_subscriber/views/otpPage.dart';
import 'package:qme_subscriber/views/slot.dart';

import 'model/reception.dart';
import 'views/receptions.dart';
import 'views/signin.dart';
import 'views/signup.dart';

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

    case OtpPage.id:
      return MaterialPageRoute(
        builder: (context) => OtpPage(),
        settings: RouteSettings(name: OtpPage.id),
      );

    /*case QueuesScreen.id:
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
      );*/

    case ReceptionsScreen.id:
      return MaterialPageRoute(
        builder: (context) => ReceptionsScreen(),
        settings: RouteSettings(name: ReceptionsScreen.id),
      );

    case CreateReceptionScreen.id:
      DateTime date =
          settings.arguments == null ? DateTime.now() : settings.arguments;
      return MaterialPageRoute(
        builder: (context) => CreateReceptionScreen(selectedDate: date),
        settings: RouteSettings(name: CreateReceptionScreen.id),
      );

    case SlotView.id:
      return MaterialPageRoute(
        builder: (context) => SlotView(settings.arguments),
        settings: RouteSettings(name: SlotView.id),
      );
      break;

    case AppointmentView.id:
      List args = settings.arguments as List;
      final Reception reception = args[0];
      final Appointment appointment = args[1];

      return MaterialPageRoute(
        builder: (context) => AppointmentView(
          reception: reception,
          appointment: appointment,
        ),
        settings: RouteSettings(name: AppointmentView.id),
      );

    case CustomerRecurrence.id:
      return MaterialPageRoute(
        builder: (context) => CustomerRecurrence(),
        settings: RouteSettings(name: CustomerRecurrence.id),
      );

    case CreateAppointment.id:
      return MaterialPageRoute(
        builder: (context) => CreateAppointment(settings.arguments),
        settings: RouteSettings(name: CreateAppointment.id),
      );

    /*default:
      return MaterialPageRoute(
        builder: (context) => UndefinedView(name: settings.name),
        settings: RouteSettings(name: UndefinedView.id),
      );*/
  }
}

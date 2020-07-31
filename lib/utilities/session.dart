import 'package:qme_subscriber/repository/subscriber.dart';

void setSession() {
  SubscriberRepository()
      .signIn({"phone": "+919876543210", "password": "Mr.A123"});
}

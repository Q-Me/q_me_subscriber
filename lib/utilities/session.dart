import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/repository/subscriber.dart';
import 'package:shared_preferences/shared_preferences.dart';

setSession() async {
  SubscriberRepository _sub = SubscriberRepository();
  final response =
      await _sub.signIn({"phone": "+919876543210", "password": "Mr.A123"});
  await _sub.storeSubscriberData(Subscriber.fromJson(response));
}

clearSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return await prefs.clear();
}

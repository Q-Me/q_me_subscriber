import 'dart:convert';

import 'package:qme_subscriber/model/subscriber.dart';
import 'package:qme_subscriber/repository/subscriber.dart';

Future<void> setSession() async {
  final response = jsonDecode('''{
    "id": "yszv79nnq",
    "name": "Amandeep's Saloon",
    "isSubscriber": true,
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InlzenY3OW5ucSIsIm5hbWUiOiJBbWFuZGVlcCdzIFNhbG9vbiIsImlzU3Vic2NyaWJlciI6dHJ1ZSwiaWF0IjoxNTkzOTYwMjIzLCJleHAiOjE1OTQwNDY2MjN9.UPSKtrN1qmvnij6YgHgSmC0Bm7bBz-1nwXgs7dX1IyU",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6InlzenY3OW5ucSIsIm5hbWUiOiJBbWFuZGVlcCdzIFNhbG9vbiIsImlzU3Vic2NyaWJlciI6dHJ1ZSwiaWF0IjoxNTkzOTYwMjIzfQ.LcL14q6IvfR7wo1TVays0e_Cpx1NrduL9ByXrrqjvH8"
}''');
  await SubscriberRepository()
      .storeSubscriberData(Subscriber.fromJson(response));
}

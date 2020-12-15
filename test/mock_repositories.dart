import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:qme_subscriber/model/reception.dart';
import 'package:qme_subscriber/repository/reception.dart';
import 'package:qme_subscriber/repository/subscriber.dart';

class MockReceptionRepository extends Mock implements ReceptionRepository {}

class MockSubscriberRepository extends Mock implements SubscriberRepository {}

class MockedReceptionRepository {
  MockReceptionRepository receptionRepository;

  MockedReceptionRepository() {
    this.receptionRepository = MockReceptionRepository();
  }

  void viewReceptionByStatus(
      {@required List<String> status,
      @required List<Reception> receptionToReturn,
      bool shouldFail = false}) {
    if (!shouldFail) {
      when(
        receptionRepository.viewReceptionsByStatus(
          accessToken: "token",
          status: ["UPCOMING"],
        ),
      ).thenAnswer(
        (_) async => Future.value([]),
      );
    } else {
      when(
        receptionRepository.viewReceptionsByStatus(
          accessToken: "token",
          status: ["UPCOMING"],
        ),
      ).thenThrow(Exception("repository failed deliberately"));
    }
  }

  void updateReceptionState({
    @required String status,
    @required String counterId,
    bool shouldFail = false,
  }) {
    if (!shouldFail) {
      when(receptionRepository.updateReceptionStatus(
              accessToken: "token", counterId: "1", status: "DONE"))
          .thenAnswer(
        (_) => Future.value(
          {
            "response": "success",
          },
        ),
      );
    } else {
      when(
        receptionRepository.updateReceptionStatus(
          accessToken: "token",
          counterId: counterId,
          status: status,
        ),
      ).thenThrow(
        Exception("repo failed deliberately"),
      );
    }
  }
}

/// The token is always set to ['token']
class MockedSubscriberRepository {
  MockSubscriberRepository subscriberRepository;
  MockedSubscriberRepository() {
    this.subscriberRepository = MockSubscriberRepository();

    when(subscriberRepository.getAccessTokenFromStorage())
        .thenAnswer((_) async => "token");
  }
}

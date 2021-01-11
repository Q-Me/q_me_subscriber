import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qme_subscriber/bloc/reception_bloc/reception_bloc.dart';
import './mock_repositories.dart';

void main() {
  group("Reception Bloc", () {
    MockedReceptionRepository mockedReceptionRepository =
        MockedReceptionRepository();
    MockedSubscriberRepository mockedSubscriberRepository =
        MockedSubscriberRepository();
    MockReceptionRepository receptionRepository =
        mockedReceptionRepository.receptionRepository;
    MockSubscriberRepository subscriberRepository =
        mockedSubscriberRepository.subscriberRepository;

    blocTest(
      "Initial State",
      build: () => ReceptionBloc(
        receptionRepo: receptionRepository,
        subscriberRepository: subscriberRepository,
      ),
      expect: [],
    );

    mockedReceptionRepository.viewReceptionByStatus(
      receptionToReturn: [],
      status: ["UPCOMING"],
    );

    blocTest(
      "Request Date wise reception",
      build: () => ReceptionBloc(
        receptionRepo: receptionRepository,
        subscriberRepository: subscriberRepository,
      ),
      act: (ReceptionBloc bloc) => bloc.add(
        DateWiseReceptionsRequested(
          date: DateTime.now(),
        ),
      ),
      expect: [
        ReceptionLoading(),
        ReceptionLoadSuccessful(
          receptions: [],
        ),
      ],
    );

    mockedReceptionRepository.updateReceptionState(
      counterId: "1",
      status: "DONE",
    );

    blocTest("Update status of reception",
        build: () => ReceptionBloc(
              receptionRepo: receptionRepository,
              subscriberRepository: subscriberRepository,
            ),
        act: (ReceptionBloc bloc) => bloc.add(
              StatusUpdateOfReceptionRequested(
                date: DateTime.now(),
                updatedStatus: "DONE",
                receptionId: "1",
              ),
            ),
        expect: [
          ReceptionLoading(),
          ReceptionLoadSuccessful(
            receptions: [],
          ),
        ]);
  });
}

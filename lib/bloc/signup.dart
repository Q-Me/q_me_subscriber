class SubscribersBloc {
  SubscribersRepository _subscribersRepository;

  StreamController _subscribersListController;

  StreamSink<ApiResponse<List<Subscriber>>> get subscribersListSink =>
      _subscribersListController.sink;

  Stream<ApiResponse<List<Subscriber>>> get subscribersListStream =>
      _subscribersListController.stream;

  SubscribersBloc() {
    _subscribersListController =
        StreamController<ApiResponse<List<Subscriber>>>();
    _subscribersRepository = SubscribersRepository();
    fetchSubscribersList();
  }

  fetchSubscribersList() async {
    subscribersListSink
        .add(ApiResponse.loading('Fetching Popular Subscribers'));
    try {
      List<Subscriber> subscribers =
          await _subscribersRepository.fetchSubscriberList();
      subscribersListSink.add(ApiResponse.completed(subscribers));
    } catch (e) {
      subscribersListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _subscribersListController?.close();
  }
}

part of 'craft.dart';

/// Provides support for executing requests sequentially. This is useful if the
/// order of the requests sent to the server is important and the next request
/// should only be sent once the first one completes. Of course, this has
/// performance implications in the means of longer completion time of multiple
/// requests.
mixin RequestQueueing on BaseCraft {
  /// Lock used for queueing requests. Each instance of [RequestQueueing] should
  /// have its own lock so this should not be static.
  final Lock _lock = Lock();

  /// Returns whether the lock is currently locked or not.
  bool get locked => _lock.locked;

  /// {@template craft.request_queueing.request_stream_controller}
  /// Stream controller for streaming the request currently being executed.
  /// {@endtemplate}
  final StreamController<Request<dynamic>> _requestStreamController =
      StreamController<Request<dynamic>>.broadcast();

  /// {@macro craft.request_queueing_request_stream_controller}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  StreamController<Request<dynamic>> get requestStreamController =>
      _requestStreamController;

  /// Stream on which the executing request is being streamed. Subscribing to
  /// this stream allows for easier monitoring of which request is currently
  /// being executed, e.g. for providing progress notifications.
  ///
  /// Requests that are not locked are not send over the stream.
  Stream<Request<dynamic>> get requestInProcessStream =>
      _requestStreamController.stream;

  /// Cancels the controller behind [requestInProcessStream] and calls the super
  /// close method.
  @override
  void close() {
    _requestStreamController.close();
    return super.close();
  }

  /// If [lock] is `true`, the [request] is queued and is executed once all
  /// previous queued requests are completed. If `false`, the queueing is
  /// bypassed and the [request] is executed immediately.
  @override
  Future<http.Response> send<T>(Request<T> request, {bool lock = true}) {
    return lock
        ? _lock.synchronized(() {
            _requestStreamController.add(request);
            return super.send<T>(request);
          })
        : super.send<T>(request);
  }
}

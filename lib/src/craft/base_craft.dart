part of 'craft.dart';

/// Base class for sending [Request]s. It only wraps the methods exposed in
/// `http` package.
class BaseCraft {
  /// {@template craft.base_craft.client}
  /// Underlying client used for making requests.
  /// {@endtemplate}
  final http.Client _client;

  /// {@macro craft.base_craft.client}
  ///
  /// {@template craft.visible_for_testing}
  /// Getter visible for testing only.
  /// {@endtemplate}
  @visibleForTesting
  http.Client get client => _client;

  /// Creates new [BaseCraft] instance.
  BaseCraft({http.Client? client}) : _client = client ?? http.Client();

  /// Closes the underlying [client].
  @mustCallSuper
  void close() {
    _client.close();
  }

  /// Forwards the [request] to `http` equivalents.
  @mustCallSuper
  Future<http.Response> send<T>(Request<T> request) {
    switch (request.method) {
      case HttpMethod.get:
        return _client.get(request.uri, headers: request.headers);
      case HttpMethod.post:
        return _client.post(
          request.uri,
          headers: request.headers,
          body: serializeBody<T>(request.body),
        );
      case HttpMethod.delete:
        return _client.delete(
          request.uri,
          headers: request.headers,
          body: serializeBody<T>(request.body),
        );
    }
  }

  /// Serializes [body] if it conforms to [Serializable].
  @visibleForTesting
  Object? serializeBody<T>(T? body) {
    if (body is! Serializable) return body;

    return body.toJson();
  }
}

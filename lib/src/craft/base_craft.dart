part of 'craft.dart';

/// Base class for sending [Request]s. It only wraps the methods exposed in
/// `http` package.
abstract class BaseCraft {
  /// Const constructor for classes extending [BaseCraft].
  const BaseCraft();

  /// Forwards the [request] to `http` equivalents.
  @mustCallSuper
  Future<http.Response> send<T extends Serializable?>(Request<T> request) {
    switch (request.method) {
      case HttpMethod.get:
        return http.get(request.uri, headers: request.headers);
      case HttpMethod.post:
        return http.post(
          request.uri,
          headers: request.headers,
          body: request.body?.toJson(),
        );
      case HttpMethod.delete:
        return http.delete(
          request.uri,
          headers: request.headers,
          body: request.body?.toJson(),
        );
    }
  }
}

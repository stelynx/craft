import 'utils/serializable.dart';

/// An enum for HTTP methods.
enum HttpMethod {
  /// An HTTP GET method.
  get,

  /// An HTTP POST method.
  post,

  /// An HTTP DELETE method.
  delete;
}

/// A base request class providing information about an HTTP request.
class Request<T> {
  /// The [method] to be used for HTTP request.
  final HttpMethod method;

  /// The target [uri].
  final Uri uri;

  /// Optional [headers] to be used in the request.
  Map<String, String>? headers;

  /// Optional [body] to be send with request. If the body is provided, it will
  /// be serialized using [Serializable.toJson] function.
  final T? body;

  /// Creates new HTTP [Request] object.
  ///
  /// Arguments [method] and [uri] must be provided. Arguments [headers] and
  /// [body] are optional.
  Request(this.method, this.uri, {this.headers, this.body});

  /// Creates new HTTP [Request] object by parsing [uri] from [path].
  ///
  /// Arguments [method] and [path] must be provided. Arguments [headers] and
  /// [body] are optional.
  Request.fromString(this.method, String path, {this.headers, this.body})
      : uri = Uri.parse(path);
}

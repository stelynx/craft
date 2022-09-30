part of 'craft.dart';

/// Abstract craft for implementing the OAuth flow. It has an [_accessToken]
/// which can be a regular token or a bearer token.
///
/// See also: [TokenOauthCraft], [BearerOauthCraft].
/// For auto-refreshing clients, see: [AutoRefreshingTokenOauthCraft] and
/// [AutoRefreshingBearerOauthCraft].
abstract class OauthCraft extends BaseCraft {
  /// Creates new [OauthCraft] with optional [accessToken]. If [accessToken] is
  /// not provided, it has to be set later, before invoking [send] method.
  OauthCraft({String? accessToken}) : _accessToken = accessToken;

  /// Token used for OAuth authentication.
  // For some reason linter thinks this can be made final.
  // ignore: prefer_final_fields
  String? _accessToken;

  @override
  Future<http.Response> send<T extends Serializable?>(Request<T> request) {
    assert(
      _accessToken != null,
      'Access token must be set before sending a request',
    );

    return super.send<T>(request);
  }
}

/// [OauthCraft] that uses "Token [_accessToken]" as Authorization header.
class TokenOauthCraft extends OauthCraft {
  /// Creates new instance of [TokenOauthCraft] with optional [accessToken].
  ///
  /// If [accessToken] is not set when calling this constructor, it has to be
  /// set before invoking [send] method.
  TokenOauthCraft({super.accessToken});

  /// {@template craft.token_oauth_craft.send}
  /// Adds authorization header with "Token [_accessToken]" to the request
  /// headers.
  /// {@endtemplate}
  @override
  Future<http.Response> send<T extends Serializable?>(Request<T> request) {
    request.headers ??= <String, String>{};
    request.headers![HttpHeaders.authorizationHeader] = 'Token $_accessToken';

    return super.send<T>(request);
  }
}

/// [OauthCraft] that uses "Bearer [_accessToken]" as Authorization header.
class BearerOauthCraft extends OauthCraft {
  /// Creates new instance of [BearerOauthCraft] with optional [accessToken].
  ///
  /// If [accessToken] is not set when calling this constructor, it has to be
  /// set before invoking [send] method.
  BearerOauthCraft({super.accessToken});

  /// {@template craft.bearer_oauth_craft.send}
  /// Adds authorization header with "Bearer [_accessToken]" to the request
  /// headers.
  /// {@endtemplate}
  @override
  Future<http.Response> send<T extends Serializable?>(Request<T> request) {
    request.headers ??= <String, String>{};
    request.headers![HttpHeaders.authorizationHeader] = 'Bearer $_accessToken';

    return super.send<T>(request);
  }
}

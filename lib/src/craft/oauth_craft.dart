part of 'craft.dart';

/// Craft implementing the OAuth flow. It has an [_accessToken] which can be a
/// regular token, a bearer token, or a custom one by defining a custom craft
/// extending the [OauthCraft].
///
/// See also: [TokenOauthCraft], [BearerOauthCraft].
/// For auto-refreshing clients, see: [AutoRefreshingTokenOauthCraft] and
/// [AutoRefreshingBearerOauthCraft].
abstract class OauthCraft extends BaseCraft {
  /// Creates new [OauthCraft] with [accessToken]. Underlying client can be
  /// provided as well, if not, the default one is used.
  OauthCraft({required String accessToken, super.client})
      : _accessToken = accessToken;

  /// {@template craft.oauth_craft.access_token}
  /// Token used for OAuth authentication.
  /// {@endtemplate}
  String _accessToken;

  /// {@macro craft.oauth_craft.access_token}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  String get accessToken => _accessToken;

  /// {@macro craft.oauth_craft.access_token}
  @visibleForOverriding
  @mustCallSuper
  set accessToken(String accesstoken) => _accessToken = accesstoken;

  /// {@template craft.oauth_craft.authorization_header_value}
  /// A value to be used as 'Authorization' header value.
  /// {@endtemplate}
  String get authorizationHeaderValue => throw UnsupportedError(
        'Extend this class and provide custom implementation',
      );

  /// Adds authorization header to the request headers.
  @mustCallSuper
  @override
  Future<http.Response> send<T>(Request<T> request) {
    request.headers ??= <String, String>{};
    request.headers![HttpHeaders.authorizationHeader] =
        authorizationHeaderValue;

    return super.send<T>(request);
  }
}

/// [OauthCraft] that uses "Token [_accessToken]" as Authorization header.
class TokenOauthCraft extends OauthCraft {
  /// Creates new instance of [TokenOauthCraft] with [accessToken]. Underlying
  /// client can be provided as well, if not, the default one is used.
  TokenOauthCraft({required super.accessToken, super.client});

  /// {@macro craft.oauth_craft.authorization_header_value}
  @override
  String get authorizationHeaderValue => 'Token $_accessToken';
}

/// [OauthCraft] that uses "Bearer [_accessToken]" as Authorization header.
class BearerOauthCraft extends OauthCraft {
  /// Creates new instance of [BearerOauthCraft] with [accessToken]. Underlying
  /// client can be provided as well, if not, the default one is used.
  BearerOauthCraft({required super.accessToken, super.client});

  /// {@macro craft.oauth_craft.authorization_header_value}
  @override
  String get authorizationHeaderValue => 'Bearer $_accessToken';
}

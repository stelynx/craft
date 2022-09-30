part of 'craft.dart';

/// Provides functionality for automatically refreshing [_accessToken] after
/// `Duration` obtained from [_accessToken] using [_tokenExpiration] method.
mixin AutoRefreshing on Refreshable {
  /// {@template craft.auto_refreshing.token_expiration}
  /// [_tokenExpiration] is a method for obtaining `Duration` after which the
  /// [_accessToken] expires from [_accessToken]. Usually, this is obtained from
  /// JWT token, but can also be set to a manual value.
  /// {@endtemplate}
  late final Duration Function(String) _tokenExpiration;

  /// Timer that triggers token refresh.
  late Timer _refreshTimer;

  /// Used internally to set [AutoRefreshing] variables.
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  // ignore: use_setters_to_change_properties
  void _initAutoRefreshing({
    required Duration Function(String) tokenExpiration,
  }) {
    _tokenExpiration = tokenExpiration;
  }

  /// {@macro craft.refreshable.set_tokens}
  ///
  /// Additionally, it re-sets the [_refreshTimer].
  @override
  void setTokens(TokenPair tokens) {
    _refreshTimer.cancel();
    _refreshTimer = Timer(_tokenExpiration(tokens.access), refreshToken);
    super.setTokens(tokens);
  }

  /// {@macro craft.refreshable.refresh_token}
  ///
  /// Additionally, it sets the [_refreshTimer] to automatically refresh the
  /// [_accessToken] when it expires.
  @override
  Future<void> refreshToken() async {
    await super.refreshToken();
    _refreshTimer = Timer(_tokenExpiration(_accessToken!), refreshToken);
  }
}

/// [RefreshableTokenOauthCraft] with ability to automatically refresh
/// [_accessToken] and [_refreshToken] using [refreshToken] method from
/// [AutoRefreshing].
class AutoRefreshingTokenOauthCraft extends RefreshableTokenOauthCraft
    with AutoRefreshing {
  /// Creates new instance of [AutoRefreshingTokenOauthCraft] with optional
  /// [tokens] pair, a required [refreshTokenMethod], and a required
  /// [tokenExpiration] method.
  ///
  /// {@macro craft.refreshable.init}
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  AutoRefreshingTokenOauthCraft({
    super.tokens,
    required super.refreshTokenMethod,
    required Duration Function(String) tokenExpiration,
  }) {
    _initAutoRefreshing(tokenExpiration: tokenExpiration);
  }
}

/// [RefreshableBearerOauthCraft] with ability to automatically refresh
/// [_accessToken] and [_refreshToken] using [refreshToken] method from
/// [AutoRefreshing].
class AutoRefreshingBearerOauthCraft extends RefreshableBearerOauthCraft
    with AutoRefreshing {
  /// Creates new instance of [AutoRefreshingBearerOauthCraft] with optional
  /// [tokens] pair, a required [refreshTokenMethod], and a required
  /// [tokenExpiration] method.
  ///
  /// {@macro craft.refreshable.init}
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  AutoRefreshingBearerOauthCraft({
    super.tokens,
    required super.refreshTokenMethod,
    required Duration Function(String) tokenExpiration,
  }) {
    _initAutoRefreshing(tokenExpiration: tokenExpiration);
  }
}

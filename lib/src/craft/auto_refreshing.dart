part of 'craft.dart';

/// Provides functionality for automatically refreshing [_accessToken] after
/// `Duration` obtained from [_accessToken] using [_tokenExpiration] method.
mixin AutoRefreshing on Refreshable {
  /// {@template craft.auto_refreshing.token_expiration}
  /// Method for obtaining `Duration` after which the [accessToken] expires from
  /// [accessToken]. Usually, this is obtained from a JWT token, but can also be
  /// set to a manual value.
  /// {@endtemplate}
  late final Duration Function(String) _tokenExpiration;

  /// {@template craft.auto_refreshing.refresh_timer}
  /// Timer that triggers token refresh.
  /// {@endtemplate}
  late Timer _refreshTimer;

  /// {@macro craft.auto_refreshing.refresh_timer}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  Timer get refreshTimer => _refreshTimer;

  /// Used internally to set [AutoRefreshing] variables.
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  // ignore: use_setters_to_change_properties
  void _initAutoRefreshing({
    required Duration Function(String) tokenExpiration,
  }) {
    _tokenExpiration = tokenExpiration;
    _refreshTimer = Timer(_tokenExpiration(_refreshToken), refreshTokens);
  }

  /// Cancels the [refreshTimer] and calls the super close method.
  @override
  void close() {
    _refreshTimer.cancel();
    super.close();
  }

  /// {@macro craft.refreshable.set_tokens}
  ///
  /// Additionally, it re-sets the [refreshTimer].
  @override
  void setTokens(TokenPair tokens) {
    _refreshTimer.cancel();
    _refreshTimer = Timer(_tokenExpiration(tokens.access), refreshTokens);
    super.setTokens(tokens);
  }
}

/// [RefreshableTokenOauthCraft] with ability to automatically refresh
/// [accessToken] and [refreshToken] using [refreshTokens] method from
/// [AutoRefreshing].
class AutoRefreshingTokenOauthCraft extends RefreshableTokenOauthCraft
    with AutoRefreshing {
  /// Creates new instance of [AutoRefreshingTokenOauthCraft] with [tokens]
  /// pair, a required [refreshTokenMethod], and a required [tokenExpiration]
  /// method. Underlying [client] can also be provided.
  ///
  /// {@macro craft.refreshable.init}
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  AutoRefreshingTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required Duration Function(String) tokenExpiration,
    super.client,
  }) {
    _initAutoRefreshing(tokenExpiration: tokenExpiration);
  }
}

/// [RefreshableBearerOauthCraft] with ability to automatically refresh
/// [accessToken] and [refreshToken] using [refreshTokens] method from
/// [AutoRefreshing].
class AutoRefreshingBearerOauthCraft extends RefreshableBearerOauthCraft
    with AutoRefreshing {
  /// Creates new instance of [AutoRefreshingBearerOauthCraft] with [tokens]
  /// pair, a required [refreshTokenMethod], and a required [tokenExpiration]
  /// method. Underlying [client] can also be provided.
  ///
  /// {@macro craft.refreshable.init}
  ///
  /// {@macro craft.auto_refreshing.token_expiration}
  AutoRefreshingBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required Duration Function(String) tokenExpiration,
    super.client,
  }) {
    _initAutoRefreshing(tokenExpiration: tokenExpiration);
  }
}

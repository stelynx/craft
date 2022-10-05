part of 'craft.dart';

/// Provides functionality for refreshing the [_accessToken] using
/// [_refreshToken] and [_refreshTokenMethod].
mixin Refreshable on OauthCraft {
  /// {@template craft.refreshable.refresh_token_method}
  /// Method is used to refresh tokens. It has to be provided by the user.
  /// This is usually an API call with [_refreshToken].
  /// {@endtemplate}
  late final Future<TokenPair> Function(String) _refreshTokenMethod;

  /// {@template craft.refreshable.refresh_token}
  /// A [_refreshToken] used to obtain a new [_accessToken].
  /// {@endtemplate}
  late String _refreshToken;

  /// {@macro craft.refreshable.refresh_token}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  String get refreshToken => _refreshToken;

  @mustCallSuper
  set refreshToken(String token) => _refreshToken = token;

  /// Used internally to set [Refreshable] variables.
  ///
  /// {@template craft.refreshable.init}
  /// If refresh token is not provided, it must be provided using [refreshToken]
  /// setter before invoking [send] method.
  /// {@endtemplate}
  void _initRefreshable({
    required String refreshToken,
    required Future<TokenPair> Function(String) refreshTokenMethod,
  }) {
    this.refreshToken = refreshToken;
    _refreshTokenMethod = refreshTokenMethod;
  }

  /// {@template craft.refreshable.set_tokens}
  /// Sets the [_accessToken] and [_refreshToken] to corresponding values
  /// from [tokens].
  /// {@endtemplate}
  @mustCallSuper
  void setTokens(TokenPair tokens) {
    accessToken = tokens.access;
    refreshToken = tokens.refresh;
  }

  /// {@template craft.refreshable.refresh_token}
  /// Refreshes the [_accessToken] and [_refreshToken].
  /// {@endtemplate}
  @mustCallSuper
  Future<void> refreshTokens() async {
    setTokens(await _refreshTokenMethod(_refreshToken));
  }
}

/// [TokenOauthCraft] with ability to refresh [_accessToken] using
/// [refreshTokens] method from [Refreshable].
class RefreshableTokenOauthCraft extends TokenOauthCraft with Refreshable {
  /// Creates new instance of [RefreshableTokenOauthCraft] with [tokens] pair
  /// and a [refreshTokenMethod]. An underlying [client] can also be provided.
  ///
  /// {@macro craft.refreshable.init}
  RefreshableTokenOauthCraft({
    required TokenPair tokens,
    required Future<TokenPair> Function(String) refreshTokenMethod,
    super.client,
  }) : super(accessToken: tokens.access) {
    _initRefreshable(
      refreshToken: tokens.refresh,
      refreshTokenMethod: refreshTokenMethod,
    );
  }
}

/// [BearerOauthCraft] with ability to refresh [_accessToken] using
/// [refreshTokens] method from [Refreshable].
class RefreshableBearerOauthCraft extends BearerOauthCraft with Refreshable {
  /// Creates new instance of [RefreshableBearerOauthCraft] with [tokens] pair
  /// and a [refreshTokenMethod]. An underlying [client] can also be provided.
  ///
  /// {@macro craft.refreshable.init}
  RefreshableBearerOauthCraft({
    required TokenPair tokens,
    required Future<TokenPair> Function(String) refreshTokenMethod,
    super.client,
  }) : super(accessToken: tokens.access) {
    _initRefreshable(
      refreshToken: tokens.refresh,
      refreshTokenMethod: refreshTokenMethod,
    );
  }
}

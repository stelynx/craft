part of 'craft.dart';

/// Provides functionality for refreshing the [accessToken] using [refreshToken]
/// and given refresh token method.
mixin Refreshable on OauthCraft {
  /// {@template craft.refreshable.refresh_token_method}
  /// Method is used to refresh tokens. It has to be provided by the user.
  /// This is usually an API call with [refreshToken].
  /// {@endtemplate}
  late final Future<TokenPair> Function(String) _refreshTokenMethod;

  /// {@template craft.refreshable.refresh_token}
  /// A [refreshToken] used to obtain a new [accessToken].
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
    _refreshToken = refreshToken;
    _refreshTokenMethod = refreshTokenMethod;
  }

  /// {@template craft.refreshable.set_tokens}
  /// Sets the [accessToken] and [refreshToken] to corresponding values from
  /// [tokens].
  /// {@endtemplate}
  @mustCallSuper
  void setTokens(TokenPair tokens) {
    accessToken = tokens.access;
    refreshToken = tokens.refresh;
  }

  /// {@template craft.refreshable.refresh_token}
  /// Refreshes the [accessToken] and [refreshToken].
  /// {@endtemplate}
  @mustCallSuper
  Future<void> refreshTokens() async {
    setTokens(await _refreshTokenMethod(_refreshToken));
  }
}

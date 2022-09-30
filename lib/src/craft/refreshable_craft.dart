part of 'craft.dart';

/// Provides functionality for refreshing the [_accessToken] using
/// [_refreshToken] and [_refreshTokenMethod].
mixin Refreshable on OauthCraft {
  /// This method is used to refresh tokens. It has to be provided by the user.
  /// This is usually an API call with [_refreshToken].
  late final Future<TokenPair> Function(String) _refreshTokenMethod;

  /// A [_refreshToken] used to obtain a new [_accessToken].
  late String _refreshToken;

  /// Used internally to set [Refreshable] variables.
  ///
  /// {@template craft.refreshable.init}
  /// If tokens are not provided, they must be provided using [setTokens] method
  /// before invoking [send] method.
  /// {@endtemplate}
  void _initRefreshable({
    TokenPair? tokens,
    required Future<TokenPair> Function(String) refreshTokenMethod,
  }) {
    if (tokens != null) setTokens(tokens);
    _refreshTokenMethod = refreshTokenMethod;
  }

  /// {@template craft.refreshable.set_tokens}
  /// Sets the [_accessToken] and [_refreshToken] to corresponding values
  /// from [tokens].
  /// {@endtemplate}
  void setTokens(TokenPair tokens) {
    _accessToken = tokens.access;
    _refreshToken = tokens.refresh;
  }

  /// {@template craft.refreshable.refresh_token}
  /// Refreshes the [_accessToken] and [_refreshToken].
  /// {@endtemplate}
  @mustCallSuper
  Future<void> refreshToken() async {
    setTokens(await _refreshTokenMethod(_refreshToken));
  }
}

/// [TokenOauthCraft] with ability to refresh [_accessToken] using
/// [refreshToken] method from [Refreshable].
class RefreshableTokenOauthCraft extends TokenOauthCraft with Refreshable {
  /// Creates new instance of [RefreshableTokenOauthCraft] with optional
  /// [tokens] pair and a [refreshTokenMethod].
  ///
  /// {@macro craft.refreshable.init}
  RefreshableTokenOauthCraft({
    TokenPair? tokens,
    required Future<TokenPair> Function(String) refreshTokenMethod,
  }) : super(accessToken: tokens?.access) {
    _initRefreshable(tokens: tokens, refreshTokenMethod: refreshTokenMethod);
  }
}

/// [BearerOauthCraft] with ability to refresh [_accessToken] using
/// [refreshToken] method from [Refreshable].
class RefreshableBearerOauthCraft extends BearerOauthCraft with Refreshable {
  /// Creates new instance of [RefreshableBearerOauthCraft] with optional
  /// [tokens] pair and a [refreshTokenMethod].
  ///
  /// {@macro craft.refreshable.init}
  RefreshableBearerOauthCraft({
    TokenPair? tokens,
    required Future<TokenPair> Function(String) refreshTokenMethod,
  }) : super(accessToken: tokens?.access) {
    _initRefreshable(tokens: tokens, refreshTokenMethod: refreshTokenMethod);
  }
}

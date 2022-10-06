part of 'craft.dart';

/// Provides functionality for storing a single token in a (secure) storage. By
/// default, the storage used is [FlutterSecureStorage] but any solution
/// implementing [TokenStorage] can be used.
///
/// In most cases, the stored token should be a refresh token, however if the
/// access token does not expire and refresh token is not used, access token can
/// be persisted.
mixin Persistable {
  /// {@template craft.persistable.token_storage}
  /// Instance of [TokenStorage] used for storing and retrieving token.
  /// {@endtemplate}
  late final TokenStorage _tokenStorage;

  /// {@macro craft.persistable.token_storage}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  TokenStorage get tokenStorage => _tokenStorage;

  /// {@template craft.persistable.token_to_persist}
  /// Getter for a token that should be persisted.
  /// {@endtemplate}
  String get _tokenToPersist;

  /// {@macro craft.persistable.token_to_persist}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  String get tokenToPersist => _tokenToPersist;

  /// Used internally to set [Persistable] variables.
  void _initPersistable({
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    assert(
      (tokenStorageKey != null && tokenStorage == null) ||
          (tokenStorageKey == null && tokenStorage != null),
      'Provide either tokenStorageKey or tokenStorage',
    );

    _tokenStorage = tokenStorage ??
        FlutterSecureTokenStorage(tokenStorageKey: tokenStorageKey!);
    persist();
  }

  /// Saves [_tokenToPersist] to secure storage using [_tokenStorageKey].
  @mustCallSuper
  FutureOr<void> persist() {
    return _tokenStorage.saveToken(_tokenToPersist);
  }

  /// Deletes the saved token from storage.
  @mustCallSuper
  FutureOr<void> deleteSavedToken() {
    return _tokenStorage.deleteToken();
  }
}

/// Extends [Persistable] functionality to save [_accessToken].
mixin AccessTokenPersistable on Persistable, OauthCraft {
  @mustCallSuper
  @override
  set accessToken(String token) {
    super.accessToken = token;
    persist();
  }

  /// {@macro craft.persistable.token_to_persist}
  ///
  /// The persisted token is access token.
  @override
  String get _tokenToPersist => _accessToken;
}

/// Extends [Persistable] functionality to save [_refreshToken] from
/// [Refreshable].
mixin RefreshTokenPersistable on Persistable, Refreshable {
  @mustCallSuper
  @override
  set refreshToken(String token) {
    super.refreshToken = token;
    persist();
  }

  /// {@macro craft.persistable.token_to_persist}
  ///
  /// The persisted token is refresh token.
  @override
  String get _tokenToPersist => _refreshToken;
}

/// [TokenOauthCraft] that persists access token using [AccessTokenPersistable].
class PersistableTokenOauthCraft extends TokenOauthCraft
    with Persistable, AccessTokenPersistable {
  /// Creates new [PersistableTokenOauthCraft] instance with [accessToken] and
  /// [tokenStorageKey] (used as key for storing [accessToken] in a secure
  /// storage).
  ///
  /// Automatically stores [accessToken] to secure storage.
  PersistableTokenOauthCraft({
    required super.accessToken,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// [TokenOauthCraft] that persists access token using [AccessTokenPersistable].
class PersistableBearerOauthCraft extends BearerOauthCraft
    with Persistable, AccessTokenPersistable {
  /// Creates new [PersistableTokenOauthCraft] instance with [accessToken] and
  /// [tokenStorageKey] (used as key for storing [accessToken] in a secure
  /// storage).
  ///
  /// Automatically stores [accessToken] to secure storage.
  PersistableBearerOauthCraft({
    required super.accessToken,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// [RefreshableTokenOauthCraft] that persists refresh token using
/// [RefreshTokenPersistable].
class PersistableRefreshableTokenOauthCraft extends RefreshableTokenOauthCraft
    with Persistable, RefreshTokenPersistable {
  /// Creates new [PersistableRefreshableTokenOauthCraft] instance.
  /// Refresh token is automatically persisted.
  PersistableRefreshableTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// [RefreshableBearerOauthCraft] that persists refresh token using
/// [RefreshTokenPersistable].
class PersistableRefreshableBearerOauthCraft extends RefreshableBearerOauthCraft
    with Persistable, RefreshTokenPersistable {
  /// Creates new [PersistableRefreshableBearerOauthCraft] instance.
  /// Refresh token is automatically persisted.
  PersistableRefreshableBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// [AutoRefreshingTokenOauthCraft] that persists refresh token using
/// [RefreshTokenPersistable].
class PersistableAutoRefreshingTokenOauthCraft
    extends AutoRefreshingTokenOauthCraft
    with Persistable, RefreshTokenPersistable {
  /// Creates new [PersistableAutoRefreshingTokenOauthCraft] instance.
  /// Refresh token is automatically persisted.
  PersistableAutoRefreshingTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// [AutoRefreshingBearerOauthCraft] that persists refresh token using
/// [RefreshTokenPersistable].
class PersistableAutoRefreshingBearerOauthCraft
    extends AutoRefreshingBearerOauthCraft
    with Persistable, RefreshTokenPersistable {
  /// Creates new [PersistableAutoRefreshingBearerOauthCraft] instance.
  /// Refresh token is automatically persisted.
  PersistableAutoRefreshingBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

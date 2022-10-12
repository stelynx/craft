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

  /// Provides method for obtaining saved token before the object creation.
  static FutureOr<String?> _getSavedToken({
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) {
    assert(
      (tokenStorageKey != null && tokenStorage == null) ||
          (tokenStorageKey == null && tokenStorage != null),
      'Provide either tokenStorageKey or tokenStorage',
    );

    final TokenStorage ts = tokenStorage ??
        FlutterSecureTokenStorage(tokenStorageKey: tokenStorageKey!);
    return ts.getToken();
  }

  /// Saves [tokenToPersist] to [tokenStorage].
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

/// Extends [Persistable] functionality to save [accessToken].
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

/// Extends [Persistable] functionality to save [refreshToken].
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

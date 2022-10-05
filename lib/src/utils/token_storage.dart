import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../craft/craft.dart';

/// Interface that a custom token storage solution should implement. It provides
/// methods for getting, saving, and deleting a token.
abstract class TokenStorage {
  /// Returns a saved token or `null` if no token saved.
  FutureOr<String?> getToken();

  /// Saves the [token] into storage.
  FutureOr<void> saveToken(String token);

  /// Deletes the currently saved token.
  FutureOr<void> deleteToken();
}

/// [TokenStorage] implementation using [FlutterSecureStorage].
///
/// This is the default implementation used for [Persistable].
class FlutterSecureTokenStorage extends FlutterSecureStorage
    implements TokenStorage {
  /// Storage key used for token operations.
  final String _tokenStorageKey;

  /// Creates new [FlutterSecureTokenStorage] instance with [tokenStorageKey].
  const FlutterSecureTokenStorage({required String tokenStorageKey})
      : _tokenStorageKey = tokenStorageKey;

  @override
  FutureOr<void> deleteToken() {
    return write(key: _tokenStorageKey, value: null);
  }

  @override
  FutureOr<String?> getToken() {
    return read(key: _tokenStorageKey);
  }

  @override
  FutureOr<void> saveToken(String token) {
    return write(key: _tokenStorageKey, value: token);
  }
}

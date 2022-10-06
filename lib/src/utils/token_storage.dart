import 'dart:async';
import 'dart:io';

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
  Future<void> deleteToken() {
    return write(key: _tokenStorageKey, value: null);
  }

  @override
  Future<String?> getToken() {
    return read(key: _tokenStorageKey);
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      return await write(key: _tokenStorageKey, value: token);
    } catch (_) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) rethrow;
    }
  }
}

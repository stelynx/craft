import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../request.dart';
import '../token_pair.dart';
import '../utils/serializable.dart';
import '../utils/token_storage.dart';

part 'auto_refreshing.dart';
part 'base_craft.dart';
part 'craft_impl.dart';
part 'oauth_craft.dart';
part 'persistable.dart';
part 'refreshable.dart';
part 'request_queueing.dart';

/// A [Craft] is an HTTP client. It can be just a basic client, but is meant to
/// be used as an enhanced feature-rich client that provides commonly used
/// abilities - such as OAuth token auto-refresh, persisting token in a secure
/// storage and automatically retrieving it when being created, queueing of the
/// HTTP requests - out of the box.
///
/// This class is a utility class and is meant to be used instead of the actual
/// craft implementations, although those can also be used.
///
/// The options for type [T] are [BaseCraft], [TokenOauthCraft],
/// [BearerOauthCraft], [RefreshableTokenOauthCraft],
/// [RefreshableBearerOauthCraft], [AutoRefreshingTokenOauthCraft],
/// [AutoRefreshingBearerOauthCraft], [PersistableTokenOauthCraft],
/// [PersistableBearerOauthCraft], [PersistableRefreshableTokenOauthCraft],
/// [PersistableRefreshableBearerOauthCraft],
/// [PersistableAutoRefreshingTokenOauthCraft], and
/// [PersistableAutoRefreshingBearerOauthCraft], and request queueing variants
/// [QBaseCraft], [QTokenOauthCraft],
/// [QBearerOauthCraft], [QRefreshableTokenOauthCraft],
/// [QRefreshableBearerOauthCraft], [QAutoRefreshingTokenOauthCraft],
/// [QAutoRefreshingBearerOauthCraft], [QPersistableTokenOauthCraft],
/// [QPersistableBearerOauthCraft], [QPersistableRefreshableTokenOauthCraft],
/// [QPersistableRefreshableBearerOauthCraft],
/// [QPersistableAutoRefreshingTokenOauthCraft], and
/// [QPersistableAutoRefreshingBearerOauthCraft].
///
/// {@example example/craft_example.dart}
class Craft<T extends BaseCraft> {
  /// {@template craft.craft.craft_instance}
  /// The underlying craft.
  /// {@endtemplate}
  BaseCraft _craftInstance;

  /// {@macro craft.craft.craft_instance}
  ///
  /// {@macro craft.visible_for_testing}
  @visibleForTesting
  BaseCraft get craftInstance => _craftInstance;

  /// {@macro craft.craft.craft_instance}
  ///
  /// Current craft in use. If object of type [T] could not be created at
  /// initialization and has not been [promote]d, the error is thrown.
  T get instance => _craftInstance as T;

  /// {@template craft.craft.promoted}
  /// Has the underlying craft been promoted or is still a [BaseCraft] or
  /// [QBaseCraft].
  /// {@endtemplate}
  bool _promoted = false;

  /// {@macro craft.craft.promoted}
  bool get promoted => _promoted;

  Craft._({required bool enableQueueing, http.Client? client})
      : _craftInstance = enableQueueing
            ? QBaseCraft(client: client)
            : BaseCraft(client: client);

  /// Returns new [Craft] instance with a craft of type [T] if [promote] was
  /// successful, otherwise either [BaseCraft] or [QBaseCraft] is used as craft,
  /// depending on whether [T] has support for [RequestQueueing].
  static Future<Craft<T>> brew<T extends BaseCraft>({
    String? accessToken,
    String? refreshToken,
    Future<TokenPair> Function(String)? refreshTokenMethod,
    Duration Function(String)? tokenExpiration,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
    http.Client? client,
  }) async {
    final Craft<T> craft = Craft<T>._(
      enableQueueing: <T>[] is List<RequestQueueing>,
      client: client,
    );

    if (T == BaseCraft || T == QBaseCraft) {
      craft._promoted = true;
    } else {
      try {
        await craft.promote(
          accessToken: accessToken,
          refreshToken: refreshToken,
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: tokenExpiration,
          tokenStorageKey: tokenStorageKey,
          tokenStorage: tokenStorage,
        );
      } catch (_) {}
    }

    return craft;
  }

  /// Promotes current [instance] to type [T]. Promotion is only possible when
  /// [instance] is [BaseCraft], otherwise an [UnsupportedError] is thrown.
  ///
  /// Throws [ArgumentError] if required arguments for creating [T] are null.
  /// Provided non-null values for arguments that [T] does not require are
  /// ignored.
  ///
  /// If the [instance] has already been promoted, a [StateError] is thrown.
  Future<void> promote({
    String? accessToken,
    String? refreshToken,
    Future<TokenPair> Function(String)? refreshTokenMethod,
    Duration Function(String)? tokenExpiration,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
  }) async {
    if (_promoted) throw StateError('craft has already been promoted');

    if (_craftInstance.runtimeType == BaseCraft) {
      switch (T) {
        case TokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          _craftInstance = TokenOauthCraft(
            accessToken: accessToken,
            client: _craftInstance._client,
          );
          break;
        case BearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          _craftInstance = BearerOauthCraft(
            accessToken: accessToken,
            client: _craftInstance._client,
          );
          break;
        case RefreshableTokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          _craftInstance = RefreshableTokenOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            client: _craftInstance._client,
          );
          break;
        case RefreshableBearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          _craftInstance = RefreshableBearerOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            client: _craftInstance._client,
          );
          break;
        case AutoRefreshingTokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }
          _craftInstance = AutoRefreshingTokenOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            client: _craftInstance._client,
          );
          break;
        case AutoRefreshingBearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }
          _craftInstance = AutoRefreshingBearerOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            client: _craftInstance._client,
          );
          break;
        case PersistableTokenOauthCraft:
          final String? token = accessToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();
          _craftInstance = PersistableTokenOauthCraft(
            accessToken: token,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case PersistableBearerOauthCraft:
          final String? token = accessToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();
          _craftInstance = PersistableBearerOauthCraft(
            accessToken: token,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case PersistableRefreshableTokenOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = PersistableRefreshableTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case PersistableRefreshableBearerOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = PersistableRefreshableBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance.client,
          );
          break;
        case PersistableAutoRefreshingTokenOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = PersistableAutoRefreshingTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
          );
          break;
        case PersistableAutoRefreshingBearerOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = PersistableAutoRefreshingBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
          );
          break;
        default:
          throw UnsupportedError('Cannot promote BaseCraft to $T');
      }

      _promoted = true;
      return;
    }

    if (_craftInstance.runtimeType == QBaseCraft) {
      switch (T) {
        case QTokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          _craftInstance = QTokenOauthCraft(
            accessToken: accessToken,
            client: _craftInstance._client,
          );
          break;
        case QBearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          _craftInstance = QBearerOauthCraft(
            accessToken: accessToken,
            client: _craftInstance._client,
          );
          break;
        case QRefreshableTokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          _craftInstance = QRefreshableTokenOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            client: _craftInstance._client,
          );
          break;
        case QRefreshableBearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          _craftInstance = QRefreshableBearerOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            client: _craftInstance._client,
          );
          break;
        case QAutoRefreshingTokenOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }
          _craftInstance = QAutoRefreshingTokenOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            client: _craftInstance._client,
          );
          break;
        case QAutoRefreshingBearerOauthCraft:
          if (accessToken == null) {
            throw ArgumentError.notNull('accessToken');
          }
          if (refreshToken == null) {
            throw ArgumentError.notNull('refreshToken');
          }
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }
          _craftInstance = QAutoRefreshingBearerOauthCraft(
            tokens: TokenPair(accessToken, refreshToken),
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            client: _craftInstance._client,
          );
          break;
        case QPersistableTokenOauthCraft:
          final String? token = accessToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();
          _craftInstance = QPersistableTokenOauthCraft(
            accessToken: token,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case QPersistableBearerOauthCraft:
          final String? token = accessToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();
          _craftInstance = QPersistableBearerOauthCraft(
            accessToken: token,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case QPersistableRefreshableTokenOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = QPersistableRefreshableTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance._client,
          );
          break;
        case QPersistableRefreshableBearerOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = QPersistableRefreshableBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
            client: _craftInstance.client,
          );
          break;
        case QPersistableAutoRefreshingTokenOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = QPersistableAutoRefreshingTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
          );
          break;
        case QPersistableAutoRefreshingBearerOauthCraft:
          if (refreshTokenMethod == null) {
            throw ArgumentError.notNull('refreshTokenMethod');
          }
          if (tokenExpiration == null) {
            throw ArgumentError.notNull('tokenExpiration');
          }

          final String? token = refreshToken ??
              await Persistable.getSavedToken(
                tokenStorageKey: tokenStorageKey,
                tokenStorage: tokenStorage,
              );
          if (token == null) throw PersistableAutoPromotionError();

          final TokenPair tokens;
          if (accessToken == null) {
            tokens = await refreshTokenMethod(token);
          } else {
            tokens = TokenPair(accessToken, token);
          }

          _craftInstance = QPersistableAutoRefreshingBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: refreshTokenMethod,
            tokenExpiration: tokenExpiration,
            tokenStorageKey: tokenStorageKey,
            tokenStorage: tokenStorage,
          );
          break;
        default:
          throw UnsupportedError('Cannot promote QBaseCraft to $T');
      }

      _promoted = true;
      return;
    }

    throw UnsupportedError(
      'Cannot promote ${_craftInstance.runtimeType} to $T',
    );
  }
}

/// Error denoting failed promotion to a Persistable variant at craft brewing.
class PersistableAutoPromotionError extends Error {
  @override
  String toString() {
    return 'Token was not provided and could also not be obtained from storage';
  }
}

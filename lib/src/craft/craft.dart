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
part 'oauth_craft.dart';
part 'persistable.dart';
part 'refreshable.dart';
part 'request_queueing.dart';

/// [TokenOauthCraft] with ability to refresh [accessToken] using
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

/// [BearerOauthCraft] with ability to refresh [accessToken] using
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
    super.client,
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
    super.client,
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
  /// Creates new [PersistableRefreshableTokenOauthCraft] instance. Refresh
  /// token is automatically persisted.
  PersistableRefreshableTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
    super.client,
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
  /// Creates new [PersistableRefreshableBearerOauthCraft] instance. Refresh
  /// token is automatically persisted.
  PersistableRefreshableBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    String? tokenStorageKey,
    TokenStorage? tokenStorage,
    super.client,
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
    super.client,
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
    super.client,
  }) {
    _initPersistable(
      tokenStorageKey: tokenStorageKey,
      tokenStorage: tokenStorage,
    );
  }
}

/// A [TokenOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QTokenOauthCraft extends TokenOauthCraft with RequestQueueing {
  /// Creates new [QTokenOauthCraft] instance with [accessToken] and [client].
  QTokenOauthCraft({required super.accessToken, super.client});
}

/// A [BearerOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QBearerOauthCraft extends BearerOauthCraft with RequestQueueing {
  /// Creates new [QBearerOauthCraft] instance with [accessToken] and [client].
  QBearerOauthCraft({required super.accessToken, super.client});
}

/// A [RefreshableTokenOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QRefreshableTokenOauthCraft extends RefreshableTokenOauthCraft
    with RequestQueueing {
  /// Creates new [QRefreshableTokenOauthCraft] instance with tokens,
  /// a refresh token method, and a [client].
  QRefreshableTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    super.client,
  });
}

/// A [RefreshableBearerOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QRefreshableBearerOauthCraft extends RefreshableBearerOauthCraft
    with RequestQueueing {
  /// Creates new [QRefreshableBearerOauthCraft] instance with tokens,
  /// a refresh token method, and a [client].
  QRefreshableBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    super.client,
  });
}

/// An [AutoRefreshingTokenOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QAutoRefreshingTokenOauthCraft extends AutoRefreshingTokenOauthCraft
    with RequestQueueing {
  /// Creates new [QAutoRefreshingTokenOauthCraft] instance with tokens,
  /// a refresh token method, a token expiration method, and a [client].
  QAutoRefreshingTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    super.client,
  });
}

/// An [AutoRefreshingBearerOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QAutoRefreshingBearerOauthCraft extends AutoRefreshingBearerOauthCraft
    with RequestQueueing {
  /// Creates new [QAutoRefreshingBearerOauthCraft] instance with tokens,
  /// a refresh token method, a token expiration method, and a [client].
  QAutoRefreshingBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    super.client,
  });
}

/// A [PersistableTokenOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QPersistableTokenOauthCraft extends PersistableTokenOauthCraft
    with RequestQueueing {
  /// Creates new [QPersistableTokenOauthCraft] instance with [accessToken],
  /// desired token storage key or token storage, and a [client].
  QPersistableTokenOauthCraft({
    required super.accessToken,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

/// A [PersistableBearerOauthCraft] with ability of queueing requests using
/// [RequestQueueing].
class QPersistableBearerOauthCraft extends PersistableBearerOauthCraft
    with RequestQueueing {
  /// Creates new [QPersistableBearerOauthCraft] instance with [accessToken],
  /// desired token storage key or token storage, and a [client].
  QPersistableBearerOauthCraft({
    required super.accessToken,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

/// A [PersistableRefreshableTokenOauthCraft] with ability of queueing requests
/// using [RequestQueueing].
class QPersistableRefreshableTokenOauthCraft
    extends PersistableRefreshableTokenOauthCraft with RequestQueueing {
  /// Creates new [QPersistableRefreshableTokenOauthCraft] instance with tokens
  /// pair, a refresh token method, desired token storage key or token storage,
  /// and a [client].
  QPersistableRefreshableTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

/// A [PersistableRefreshableBearerOauthCraft] with ability of queueing
/// requests using [RequestQueueing].
class QPersistableRefreshableBearerOauthCraft
    extends PersistableRefreshableBearerOauthCraft with RequestQueueing {
  /// Creates new [QPersistableRefreshableBearerOauthCraft] instance with
  /// tokens pair, a refresh token method, desired token storage key or token
  /// storage, and a [client].
  QPersistableRefreshableBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

/// A [PersistableAutoRefreshingTokenOauthCraft] with ability of queueing
/// requests using [RequestQueueing].
class QPersistableAutoRefreshingTokenOauthCraft
    extends PersistableAutoRefreshingTokenOauthCraft with RequestQueueing {
  /// Creates new [QPersistableAutoRefreshingTokenOauthCraft] instance with
  /// tokens pair, a refresh token method, token expiration method, desired
  /// token storage key or token storage, and a [client].
  QPersistableAutoRefreshingTokenOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

/// A [PersistableAutoRefreshingBearerOauthCraft] with ability of queueing
/// requests using [RequestQueueing].
class QPersistableAutoRefreshingBearerOauthCraft
    extends PersistableAutoRefreshingBearerOauthCraft with RequestQueueing {
  /// Creates new [QPersistableAutoRefreshingBearerOauthCraft] instance with
  /// tokens pair, a refresh token method, token expiration method, desired
  /// token storage key or token storage, and a [client].
  QPersistableAutoRefreshingBearerOauthCraft({
    required super.tokens,
    required super.refreshTokenMethod,
    required super.tokenExpiration,
    super.tokenStorageKey,
    super.tokenStorage,
    super.client,
  });
}

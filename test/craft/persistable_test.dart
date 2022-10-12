import 'package:craft/craft.dart';
import 'package:craft/src/utils/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  const TokenPair tokens = TokenPair('accessToken', 'refreshToken');
  const TokenPair newTokens = TokenPair('newAccessToken', 'newRefreshToken');

  Future<TokenPair> unimplementedRefreshTokenMethod(_) =>
      throw UnimplementedError();
  Future<TokenPair> refreshTokenMethod(_) async => newTokens;

  Duration infiniteTokenExpiration(_) => const Duration(days: 10000);
  Duration tokenExpiration(_) => Duration.zero;

  group('getSavedToken', () {
    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if called with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => Persistable.getSavedToken(
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if called without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => Persistable.getSavedToken(),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should call TokenStorage.getToken', () {
      final MockTokenStorage mockTokenStorage = MockTokenStorage();

      Persistable.getSavedToken(tokenStorage: mockTokenStorage);
      verify(mockTokenStorage.getToken()).called(1);
    });

    test('should return a saved token if exists', () {
      final MockTokenStorage mockTokenStorage = MockTokenStorage();
      when(mockTokenStorage.getToken()).thenReturn(tokens.refresh);

      expect(
        Persistable.getSavedToken(tokenStorage: mockTokenStorage),
        equals(tokens.refresh),
      );
    });

    test('should return null if saved token does not exist', () {
      final MockTokenStorage mockTokenStorage = MockTokenStorage();
      when(mockTokenStorage.getToken()).thenReturn(null);

      expect(
        Persistable.getSavedToken(tokenStorage: mockTokenStorage),
        isNull,
      );
    });
  });

  group('PersistableTokenOauthCraft', () {
    test('should extend TokenOauthCraft with AccessTokenPersistable', () {
      final OauthCraft craft = PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: MockTokenStorage(),
      );
      expect(craft, isA<TokenOauthCraft>());
      expect(craft, isA<AccessTokenPersistable>());
    });

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableTokenOauthCraft(
            accessToken: tokens.access,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableTokenOauthCraft(accessToken: tokens.access),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableTokenOauthCraft craft = PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return access token as token to persist', () {
      final PersistableTokenOauthCraft craft = PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.access));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.access)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.access)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).accessToken = newTokens.access;

      verify(mockTokenStorage.saveToken(newTokens.access)).called(1);
    });

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });

  group('PersistableBearerOauthCraft', () {
    test('should extend BearerOauthCraft with AccessTokenPersistable', () {
      final OauthCraft craft = PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: MockTokenStorage(),
      );
      expect(craft, isA<BearerOauthCraft>());
      expect(craft, isA<AccessTokenPersistable>());
    });

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableBearerOauthCraft(
            accessToken: tokens.access,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableBearerOauthCraft(accessToken: tokens.access),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableBearerOauthCraft craft = PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return access token as token to persist', () {
      final PersistableBearerOauthCraft craft = PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.access));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.access)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.access)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).accessToken = newTokens.access;

      verify(mockTokenStorage.saveToken(newTokens.access)).called(1);
    });

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });

  group('PersistableRefreshableTokenOauthCraft', () {
    test(
      'should extend RefreshableTokenOauthCraft with RefreshTokenPersistable',
      () {
        final OauthCraft craft = PersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft, isA<RefreshableTokenOauthCraft>());
        expect(craft, isA<RefreshTokenPersistable>());
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableRefreshableTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableRefreshableTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableRefreshableTokenOauthCraft craft =
          PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return refresh token as token to persist', () {
      final PersistableRefreshableTokenOauthCraft craft =
          PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.refresh));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.refresh)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).setTokens(newTokens);

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on token refresh', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();

      await PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).refreshTokens();

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });

  group('PersistableRefreshableBearerOauthCraft', () {
    test(
      'should extend RefreshableBearerOauthCraft with RefreshTokenPersistable',
      () {
        final OauthCraft craft = PersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft, isA<RefreshableBearerOauthCraft>());
        expect(craft, isA<RefreshTokenPersistable>());
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableRefreshableBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableRefreshableBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableRefreshableBearerOauthCraft craft =
          PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return refresh token as token to persist', () {
      final PersistableRefreshableBearerOauthCraft craft =
          PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.refresh));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.refresh)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).setTokens(newTokens);

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on token refresh', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();

      await PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).refreshTokens();

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });

  group('PersistableAutoRefreshingTokenOauthCraft', () {
    test(
      // ignore: lines_longer_than_80_chars
      'should extend AutoRefreshingTokenOauthCraft with RefreshTokenPersistable',
      () {
        final OauthCraft craft = PersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft, isA<AutoRefreshingTokenOauthCraft>());
        expect(craft, isA<RefreshTokenPersistable>());
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableAutoRefreshingTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableAutoRefreshingTokenOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableAutoRefreshingTokenOauthCraft craft =
          PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return refresh token as token to persist', () {
      final PersistableAutoRefreshingTokenOauthCraft craft =
          PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.refresh));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();

      PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.refresh)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).setTokens(newTokens);

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test(
      'should call TokenStorage.saveToken on manual token refresh',
      () async {
        final TokenStorage mockTokenStorage = MockTokenStorage();

        await PersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        ).refreshTokens();

        verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
      },
    );

    test(
      'should call TokenStorage.saveToken on token refresh on expiration',
      () async {
        final TokenStorage mockTokenStorage = MockTokenStorage();

        PersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: tokenExpiration,
          tokenStorage: mockTokenStorage,
        );

        Future<void>.delayed(
          tokenExpiration(null),
          () => verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1),
        );
      },
    );

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });

  group('PersistableAutoRefreshingBearerOauthCraft', () {
    test(
      // ignore: lines_longer_than_80_chars
      'should extend AutoRefreshingBearerOauthCraft with RefreshTokenPersistable',
      () {
        final OauthCraft craft = PersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft, isA<AutoRefreshingBearerOauthCraft>());
        expect(craft, isA<RefreshTokenPersistable>());
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created with tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableAutoRefreshingBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      // ignore: lines_longer_than_80_chars
      'should throw AssertionError if created without tokenStorageKey and tokenStorage',
      () {
        expect(
          () => PersistableAutoRefreshingBearerOauthCraft(
            tokens: tokens,
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test('should use FlutterSecureTokenStorage as default token storage', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final PersistableAutoRefreshingBearerOauthCraft craft =
          PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: 'key',
      );

      expect(craft.tokenStorage, isA<FlutterSecureTokenStorage>());
    });

    test('should return refresh token as token to persist', () {
      final PersistableAutoRefreshingBearerOauthCraft craft =
          PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: MockTokenStorage(),
      );

      expect(craft.tokenToPersist, equals(tokens.refresh));
    });

    test('should automatically persist token on creation', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();

      PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      );

      verify(mockTokenStorage.saveToken(tokens.refresh)).called(1);
    });

    test('should call TokenStorage.saveToken on persist', () async {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      await PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).persist();

      // Once is called automatically.
      verify(mockTokenStorage.saveToken(tokens.refresh)).called(2);
    });

    test('should call TokenStorage.saveToken on manual token set', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).setTokens(newTokens);

      verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
    });

    test(
      'should call TokenStorage.saveToken on manual token refresh',
      () async {
        final TokenStorage mockTokenStorage = MockTokenStorage();

        await PersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        ).refreshTokens();

        verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1);
      },
    );

    test(
      'should call TokenStorage.saveToken on token refresh on expiration',
      () async {
        final TokenStorage mockTokenStorage = MockTokenStorage();

        PersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: tokenExpiration,
          tokenStorage: mockTokenStorage,
        );

        Future<void>.delayed(
          tokenExpiration(null),
          () => verify(mockTokenStorage.saveToken(newTokens.refresh)).called(1),
        );
      },
    );

    test('should call TokenStorage.deleteToken on token deletion', () {
      final TokenStorage mockTokenStorage = MockTokenStorage();
      PersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorage: mockTokenStorage,
      ).deleteSavedToken();

      verify(mockTokenStorage.deleteToken()).called(1);
    });
  });
}

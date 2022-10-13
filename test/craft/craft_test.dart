// ignore_for_file: lines_longer_than_80_chars

import 'package:craft/craft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  const TokenPair newTokens = TokenPair('newAccess', 'newRefresh');

  Future<TokenPair> refreshTokenMethod(String s) async => newTokens;
  Future<TokenPair> unimplementedRefreshTokenMethod(String s) =>
      throw UnimplementedError();

  Duration infiniteTokenExpiration(String s) => const Duration(days: 10);

  group('instance', () {
    test('should throw a TypeError if not yet promoted', () async {
      final Craft<TokenOauthCraft> craft = await Craft.brew<TokenOauthCraft>();

      expect(craft.craftInstance.runtimeType, equals(BaseCraft));
      expect(() => craft.instance, throwsA(isA<TypeError>()));
    });

    test('should return the promoted variant', () async {
      final Craft<TokenOauthCraft> craft =
          await Craft.brew<TokenOauthCraft>(accessToken: '');

      expect(craft.instance, isA<TokenOauthCraft>());
    });
  });

  group('promoted', () {
    test('should return false if not yet promoted', () async {
      final Craft<TokenOauthCraft> craft = await Craft.brew<TokenOauthCraft>();

      expect(craft.craftInstance.runtimeType, equals(BaseCraft));
      expect(craft.promoted, isFalse);
    });

    test('should return true if promoted', () async {
      final Craft<TokenOauthCraft> craft =
          await Craft.brew<TokenOauthCraft>(accessToken: '');

      expect(craft.promoted, isTrue);
    });
  });

  group('brew', () {
    test('should set the underlying client', () async {
      final MockHttpClient mockHttpClient = MockHttpClient();
      final Craft<BaseCraft> craft =
          await Craft.brew<BaseCraft>(client: mockHttpClient);

      expect(craft.instance.client, equals(mockHttpClient));
    });

    test('should set promoted to true if T is BaseCraft', () async {
      final MockHttpClient mockHttpClient = MockHttpClient();
      final Craft<BaseCraft> craft =
          await Craft.brew<BaseCraft>(client: mockHttpClient);

      expect(craft.promoted, isTrue);
    });

    test('should set promoted to true if T is QBaseCraft', () async {
      final MockHttpClient mockHttpClient = MockHttpClient();
      final Craft<QBaseCraft> craft =
          await Craft.brew<QBaseCraft>(client: mockHttpClient);

      expect(craft.promoted, isTrue);
    });
  });

  group('promote', () {
    test('should throw StateError if already promoted', () async {
      final Craft<BaseCraft> craft = await Craft.brew<BaseCraft>();

      expect(craft.promoted, isTrue);
      expect(craft.promote, throwsStateError);
    });

    test(
      'should throw ArgumentError when promoting to TokenOauthCraft without accessToken',
      () async {
        final Craft<TokenOauthCraft> craft =
            await Craft.brew<TokenOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should promote successfully to TokenOauthCraft when accessToken is provided',
      () async {
        final Craft<TokenOauthCraft> craft =
            await Craft.brew<TokenOauthCraft>();

        expect(() => craft.promote(accessToken: ''), returnsNormally);
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to BearerOauthCraft without accessToken',
      () async {
        final Craft<BearerOauthCraft> craft =
            await Craft.brew<BearerOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should promote successfully to BearerOauthCraft when accessToken is provided',
      () async {
        final Craft<BearerOauthCraft> craft =
            await Craft.brew<BearerOauthCraft>();

        expect(() => craft.promote(accessToken: ''), returnsNormally);
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableTokenOauthCraft without accessToken',
      () async {
        final Craft<RefreshableTokenOauthCraft> craft =
            await Craft.brew<RefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableTokenOauthCraft without refreshToken',
      () async {
        final Craft<RefreshableTokenOauthCraft> craft =
            await Craft.brew<RefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableTokenOauthCraft without refreshTokenMethod',
      () async {
        final Craft<RefreshableTokenOauthCraft> craft =
            await Craft.brew<RefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to RefreshableTokenOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<RefreshableTokenOauthCraft> craft =
            await Craft.brew<RefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableBearerOauthCraft without accessToken',
      () async {
        final Craft<RefreshableBearerOauthCraft> craft =
            await Craft.brew<RefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableBearerOauthCraft without refreshToken',
      () async {
        final Craft<RefreshableBearerOauthCraft> craft =
            await Craft.brew<RefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to RefreshableBearerOauthCraft without refreshTokenMethod',
      () async {
        final Craft<RefreshableBearerOauthCraft> craft =
            await Craft.brew<RefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to RefreshableBearerOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<RefreshableBearerOauthCraft> craft =
            await Craft.brew<RefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingTokenOauthCraft without accessToken',
      () async {
        final Craft<AutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<AutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingTokenOauthCraft without refreshToken',
      () async {
        final Craft<AutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<AutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingTokenOauthCraft without refreshTokenMethod',
      () async {
        final Craft<AutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<AutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingTokenOauthCraft without tokenExpiration',
      () async {
        final Craft<AutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<AutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to AutoRefreshingTokenOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<AutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<AutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingBearerOauthCraft without accessToken',
      () async {
        final Craft<AutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<AutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingBearerOauthCraft without refreshToken',
      () async {
        final Craft<AutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<AutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingBearerOauthCraft without refreshTokenMethod',
      () async {
        final Craft<AutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<AutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to AutoRefreshingBearerOauthCraft without tokenExpiration',
      () async {
        final Craft<AutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<AutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to AutoRefreshingBearerOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<AutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<AutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableTokenOauthCraft> craft =
            await Craft.brew<PersistableTokenOauthCraft>();

        expect(craft.promote, throwsAssertionError);
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableTokenOauthCraft with no accessToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableTokenOauthCraft> craft =
            await Craft.brew<PersistableTokenOauthCraft>();

        expect(
          () => craft.promote(tokenStorage: mockTokenStorage),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableTokenOauthCraft with accessToken and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableTokenOauthCraft> craft =
            await Craft.brew<PersistableTokenOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorage: mockTokenStorage),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableTokenOauthCraft with accessToken and tokenStorageKey provided',
      () async {
        final Craft<PersistableTokenOauthCraft> craft =
            await Craft.brew<PersistableTokenOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorageKey: ''),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableTokenOauthCraft with accessToken saved and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableTokenOauthCraft> craft =
            await Craft.brew<PersistableTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenAnswer((_) => '');

        await craft.promote(tokenStorage: mockTokenStorage);

        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableBearerOauthCraft> craft =
            await Craft.brew<PersistableBearerOauthCraft>();

        expect(craft.promote, throwsAssertionError);
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableBearerOauthCraft with no accessToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableBearerOauthCraft> craft =
            await Craft.brew<PersistableBearerOauthCraft>();

        expect(
          () => craft.promote(tokenStorage: mockTokenStorage),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableBearerOauthCraft with accessToken and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableBearerOauthCraft> craft =
            await Craft.brew<PersistableBearerOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorage: mockTokenStorage),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableBearerOauthCraft with accessToken and tokenStorageKey provided',
      () async {
        final Craft<PersistableBearerOauthCraft> craft =
            await Craft.brew<PersistableBearerOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorageKey: ''),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableBearerOauthCraft with accessToken saved and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableBearerOauthCraft> craft =
            await Craft.brew<PersistableBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenAnswer((_) => '');

        await craft.promote(tokenStorage: mockTokenStorage);

        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableRefreshableTokenOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableRefreshableTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableRefreshableTokenOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableRefreshableTokenOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableRefreshableTokenOauthCraft when refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableRefreshableTokenOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to PersistableRefreshableTokenOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<PersistableRefreshableTokenOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableRefreshableBearerOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableRefreshableBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableRefreshableBearerOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableRefreshableBearerOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableRefreshableBearerOauthCraft when refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableRefreshableBearerOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to PersistableRefreshableBearerOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<PersistableRefreshableBearerOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableAutoRefreshingTokenOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(tokenExpiration: infiniteTokenExpiration),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableAutoRefreshingTokenOauthCraft with no tokenExpiration provided',
      () async {
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableAutoRefreshingTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableAutoRefreshingTokenOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableAutoRefreshingTokenOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingTokenOauthCraft when refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingTokenOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingTokenOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingTokenOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableAutoRefreshingBearerOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(tokenExpiration: infiniteTokenExpiration),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to PersistableAutoRefreshingBearerOauthCraft with no tokenExpiration provided',
      () async {
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableAutoRefreshingBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to PersistableAutoRefreshingBearerOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to PersistableAutoRefreshingBearerOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingBearerOauthCraft when refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingBearerOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to PersistableAutoRefreshingBearerOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<PersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<PersistableAutoRefreshingBearerOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test('should throw StateError if already promoted', () async {
      final Craft<QBaseCraft> craft = await Craft.brew<QBaseCraft>();

      expect(craft.promoted, isTrue);
      expect(craft.promote, throwsStateError);
    });

    test(
      'should throw ArgumentError when promoting to QTokenOauthCraft without accessToken',
      () async {
        final Craft<QTokenOauthCraft> craft =
            await Craft.brew<QTokenOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should promote successfully to QTokenOauthCraft when accessToken is provided',
      () async {
        final Craft<QTokenOauthCraft> craft =
            await Craft.brew<QTokenOauthCraft>();

        expect(() => craft.promote(accessToken: ''), returnsNormally);
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QBearerOauthCraft without accessToken',
      () async {
        final Craft<QBearerOauthCraft> craft =
            await Craft.brew<QBearerOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should promote successfully to QBearerOauthCraft when accessToken is provided',
      () async {
        final Craft<QBearerOauthCraft> craft =
            await Craft.brew<QBearerOauthCraft>();

        expect(() => craft.promote(accessToken: ''), returnsNormally);
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableTokenOauthCraft without accessToken',
      () async {
        final Craft<QRefreshableTokenOauthCraft> craft =
            await Craft.brew<QRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableTokenOauthCraft without refreshToken',
      () async {
        final Craft<QRefreshableTokenOauthCraft> craft =
            await Craft.brew<QRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableTokenOauthCraft without refreshTokenMethod',
      () async {
        final Craft<QRefreshableTokenOauthCraft> craft =
            await Craft.brew<QRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to QRefreshableTokenOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<QRefreshableTokenOauthCraft> craft =
            await Craft.brew<QRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableBearerOauthCraft without accessToken',
      () async {
        final Craft<QRefreshableBearerOauthCraft> craft =
            await Craft.brew<QRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableBearerOauthCraft without refreshToken',
      () async {
        final Craft<QRefreshableBearerOauthCraft> craft =
            await Craft.brew<QRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QRefreshableBearerOauthCraft without refreshTokenMethod',
      () async {
        final Craft<QRefreshableBearerOauthCraft> craft =
            await Craft.brew<QRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to QRefreshableBearerOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<QRefreshableBearerOauthCraft> craft =
            await Craft.brew<QRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingTokenOauthCraft without accessToken',
      () async {
        final Craft<QAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingTokenOauthCraft without refreshToken',
      () async {
        final Craft<QAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingTokenOauthCraft without refreshTokenMethod',
      () async {
        final Craft<QAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingTokenOauthCraft without tokenExpiration',
      () async {
        final Craft<QAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to QAutoRefreshingTokenOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<QAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingBearerOauthCraft without accessToken',
      () async {
        final Craft<QAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingBearerOauthCraft without refreshToken',
      () async {
        final Craft<QAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingBearerOauthCraft without refreshTokenMethod',
      () async {
        final Craft<QAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QAutoRefreshingBearerOauthCraft without tokenExpiration',
      () async {
        final Craft<QAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should promote successfully to QAutoRefreshingBearerOauthCraft when accessToken, refreshToken, and refreshTokenMethod are provided',
      () async {
        final Craft<QAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableTokenOauthCraft> craft =
            await Craft.brew<QPersistableTokenOauthCraft>();

        expect(craft.promote, throwsAssertionError);
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableTokenOauthCraft with no accessToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableTokenOauthCraft> craft =
            await Craft.brew<QPersistableTokenOauthCraft>();

        expect(
          () => craft.promote(tokenStorage: mockTokenStorage),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableTokenOauthCraft with accessToken and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableTokenOauthCraft> craft =
            await Craft.brew<QPersistableTokenOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorage: mockTokenStorage),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableTokenOauthCraft with accessToken and tokenStorageKey provided',
      () async {
        final Craft<QPersistableTokenOauthCraft> craft =
            await Craft.brew<QPersistableTokenOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorageKey: ''),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableTokenOauthCraft with accessToken saved and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableTokenOauthCraft> craft =
            await Craft.brew<QPersistableTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenAnswer((_) => '');

        await craft.promote(tokenStorage: mockTokenStorage);

        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableBearerOauthCraft> craft =
            await Craft.brew<QPersistableBearerOauthCraft>();

        expect(craft.promote, throwsAssertionError);
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableBearerOauthCraft with no accessToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableBearerOauthCraft> craft =
            await Craft.brew<QPersistableBearerOauthCraft>();

        expect(
          () => craft.promote(tokenStorage: mockTokenStorage),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableBearerOauthCraft with accessToken and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableBearerOauthCraft> craft =
            await Craft.brew<QPersistableBearerOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorage: mockTokenStorage),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableBearerOauthCraft with accessToken and tokenStorageKey provided',
      () async {
        final Craft<QPersistableBearerOauthCraft> craft =
            await Craft.brew<QPersistableBearerOauthCraft>();

        expect(
          () => craft.promote(accessToken: '', tokenStorageKey: ''),
          returnsNormally,
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableBearerOauthCraft with accessToken saved and tokenStorage provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableBearerOauthCraft> craft =
            await Craft.brew<QPersistableBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenAnswer((_) => '');

        await craft.promote(tokenStorage: mockTokenStorage);

        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableRefreshableTokenOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableRefreshableTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableRefreshableTokenOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableRefreshableTokenOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableTokenOauthCraft when refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableTokenOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableTokenOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableTokenOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableTokenOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableRefreshableBearerOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        expect(craft.promote, throwsArgumentError);
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableRefreshableBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableRefreshableBearerOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableRefreshableBearerOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableBearerOauthCraft when refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableBearerOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to QPersistableRefreshableBearerOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableRefreshableBearerOauthCraft> craft =
            await Craft.brew<QPersistableRefreshableBearerOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableAutoRefreshingTokenOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(tokenExpiration: infiniteTokenExpiration),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableAutoRefreshingTokenOauthCraft with no tokenExpiration provided',
      () async {
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableAutoRefreshingTokenOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableAutoRefreshingTokenOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableAutoRefreshingTokenOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingTokenOauthCraft when refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingTokenOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingTokenOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingTokenOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingTokenOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableAutoRefreshingBearerOauthCraft with no refreshTokenMethod provided',
      () async {
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(tokenExpiration: infiniteTokenExpiration),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw ArgumentError when promoting to QPersistableAutoRefreshingBearerOauthCraft with no tokenExpiration provided',
      () async {
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableAutoRefreshingBearerOauthCraft with no tokenStorageKey and no tokenStorage',
      () async {
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw AssertionError when promoting to QPersistableAutoRefreshingBearerOauthCraft with both tokenStorageKey and tokenStorage provided',
      () async {
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        expect(
          () => craft.promote(
            accessToken: '',
            refreshToken: '',
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorageKey: '',
            tokenStorage: MockTokenStorage(),
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'should throw PersistableAutoPromotionError when promoting to QPersistableAutoRefreshingBearerOauthCraft with no refreshToken provided or saved',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();
        when(mockTokenStorage.getToken()).thenReturn(null);

        expect(
          () => craft.promote(
            refreshTokenMethod: unimplementedRefreshTokenMethod,
            tokenExpiration: infiniteTokenExpiration,
            tokenStorage: mockTokenStorage,
          ),
          throwsA(isA<PersistableAutoPromotionError>()),
        );
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingBearerOauthCraft when refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        await craft.promote(
          refreshToken: '',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: MockTokenStorage(),
        );
        expect(craft.promoted, isTrue);
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingBearerOauthCraft and fetch new tokens when refreshToken is saved and refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        when(mockTokenStorage.getToken()).thenReturn('');

        await craft.promote(
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals(newTokens.access));
        expect(craft.instance.refreshToken, equals(newTokens.refresh));
      },
    );

    test(
      'should promote successfully to QPersistableAutoRefreshingBearerOauthCraft with provided tokens when accessToken, refreshToken, refreshTokenMethod, tokenExpiration, and tokenStorage are provided',
      () async {
        final MockTokenStorage mockTokenStorage = MockTokenStorage();
        final Craft<QPersistableAutoRefreshingBearerOauthCraft> craft =
            await Craft.brew<QPersistableAutoRefreshingBearerOauthCraft>();

        await craft.promote(
          accessToken: 'access',
          refreshToken: 'refresh',
          refreshTokenMethod: refreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorage: mockTokenStorage,
        );
        expect(craft.promoted, isTrue);
        expect(craft.instance.accessToken, equals('access'));
        expect(craft.instance.refreshToken, equals('refresh'));
      },
    );
  });
}

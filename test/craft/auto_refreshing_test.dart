import 'package:craft/craft.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  const TokenPair tokens = TokenPair('accessToken', 'refreshToken');
  const TokenPair newTokens = TokenPair('newAccessToken', 'newRefreshToken');

  Future<TokenPair> unimplementedRefreshTokenMethod(_) =>
      throw UnimplementedError();
  Future<TokenPair> refreshTokenMethod(_) async => newTokens;

  Duration infiniteTokenExpiration(_) => const Duration(days: 10000);
  Duration tokenExpiration(_) => Duration.zero;

  group('AutoRefreshingTokenOauthCraft', () {
    test('should extend TokenOauthCraft', () {
      final OauthCraft craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );
      expect(craft, isA<TokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(
          HttpMethod.get,
          Uri.parse('https://google.com'),
        ),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should set a timer to refresh tokens when expire', () {
      final AutoRefreshingTokenOauthCraft craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenExpiration: tokenExpiration,
      );

      expect(craft.refreshTimer.isActive, isTrue);
    });

    test('should refresh tokens when expire', () async {
      final AutoRefreshingTokenOauthCraft craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenExpiration: tokenExpiration,
      );

      await Future<void>.delayed(tokenExpiration(null), () {
        expect(craft.accessToken, equals(newTokens.access));
        expect(craft.refreshToken, equals(newTokens.refresh));
      });
    });

    test('should cancel timer when closed', () {
      final AutoRefreshingTokenOauthCraft craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      )..close();

      expect(craft.refreshTimer.isActive, isFalse);
    });

    test('should be able to set tokens manually', () {
      final Refreshable craft = AutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );

      expect(craft.accessToken, equals(tokens.access));
      expect(craft.refreshToken, equals(tokens.refresh));

      craft.setTokens(newTokens);

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });
  });

  group('AutoRefreshingBearerOauthCraft', () {
    test('should extend BearerOauthCraft', () {
      final OauthCraft craft = AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );
      expect(craft, isA<BearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(
          HttpMethod.get,
          Uri.parse('https://google.com'),
        ),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should set a timer to refresh tokens when expire', () {
      final AutoRefreshingBearerOauthCraft craft =
          AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenExpiration: tokenExpiration,
      );

      expect(craft.refreshTimer.isActive, isTrue);
    });

    test('should refresh tokens when expire', () async {
      final AutoRefreshingBearerOauthCraft craft =
          AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
        tokenExpiration: tokenExpiration,
      );

      await Future<void>.delayed(tokenExpiration(null), () {
        expect(craft.accessToken, equals(newTokens.access));
        expect(craft.refreshToken, equals(newTokens.refresh));
      });
    });

    test('should cancel timer when closed', () {
      final AutoRefreshingBearerOauthCraft craft =
          AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      )..close();

      expect(craft.refreshTimer.isActive, isFalse);
    });

    test('should be able to set tokens manually', () {
      final Refreshable craft = AutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );

      expect(craft.accessToken, equals(tokens.access));
      expect(craft.refreshToken, equals(tokens.refresh));

      craft.setTokens(newTokens);

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });
  });
}

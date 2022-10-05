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

  group('RefreshableTokenOauthCraft', () {
    test('should extend TokenOauthCraft', () {
      final OauthCraft craft = RefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );
      expect(craft, isA<TokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = RefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
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

    test('should be able to set tokens manually', () {
      final Refreshable craft = RefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );

      expect(craft.accessToken, equals(tokens.access));
      expect(craft.refreshToken, equals(tokens.refresh));

      craft.setTokens(newTokens);

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });

    test('should change tokens when calling refreshTokens', () async {
      final Refreshable craft = RefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
      );

      await craft.refreshTokens();

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });
  });

  group('RefreshableBearerOauthCraft', () {
    test('should extend BearerOauthCraft', () {
      final OauthCraft craft = RefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );
      expect(craft, isA<BearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = RefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
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

    test('should be able to set tokens manually', () {
      final Refreshable craft = RefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );

      expect(craft.accessToken, equals(tokens.access));
      expect(craft.refreshToken, equals(tokens.refresh));

      craft.setTokens(newTokens);

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });

    test('should change tokens when calling refreshTokens', () async {
      final Refreshable craft = RefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: refreshTokenMethod,
      );

      await craft.refreshTokens();

      expect(craft.accessToken, equals(newTokens.access));
      expect(craft.refreshToken, equals(newTokens.refresh));
    });
  });
}

import 'dart:io';

import 'package:craft/craft.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  const String token = 'accessToken';
  final Uri uri = Uri.parse('https://google.com');

  group('TokenOauthCraft', () {
    test('should extend BaseCraft', () {
      final OauthCraft craft = TokenOauthCraft(accessToken: token);
      expect(craft, isA<BaseCraft>());
    });

    test('should set the access token', () {
      final OauthCraft craft = TokenOauthCraft(accessToken: token);
      expect(craft.accessToken, equals(token));
    });

    test('should have "Token <token>" as authorization header', () {
      final OauthCraft craft = TokenOauthCraft(accessToken: token);
      expect(craft.authorizationHeaderValue, equals('Token $token'));
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = TokenOauthCraft(
        accessToken: token,
        client: mockClient,
      );

      await craft.send<void>(Request<void>(HttpMethod.get, uri));
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should add authorization header to the request', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = TokenOauthCraft(
        accessToken: token,
        client: mockClient,
      );

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('', HttpStatus.ok),
      );

      final Map<String, String> headers = <String, String>{'demo': 'value'};

      await craft
          .send<void>(Request<void>(HttpMethod.get, uri, headers: headers));

      expect(
        verify(mockClient.get(any, headers: captureAnyNamed('headers')))
            .captured
            .single,
        equals(<String, String>{
          ...headers,
          HttpHeaders.authorizationHeader: craft.authorizationHeaderValue,
        }),
      );
    });
  });

  group('BearerOauthCraft', () {
    test('should extend BaseCraft', () {
      final OauthCraft craft = BearerOauthCraft(accessToken: token);
      expect(craft, isA<BaseCraft>());
    });

    test('should set the access token', () {
      final OauthCraft craft = BearerOauthCraft(accessToken: token);
      expect(craft.accessToken, equals(token));
    });

    test('should have "Bearer <token>" as authorization header', () {
      final OauthCraft craft = BearerOauthCraft(accessToken: token);
      expect(craft.authorizationHeaderValue, equals('Bearer $token'));
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = BearerOauthCraft(
        accessToken: token,
        client: mockClient,
      );

      await craft.send<void>(Request<void>(HttpMethod.get, uri));
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should add authorization header to the request', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = BearerOauthCraft(
        accessToken: token,
        client: mockClient,
      );

      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('', HttpStatus.ok),
      );

      final Map<String, String> headers = <String, String>{'demo': 'value'};

      await craft
          .send<void>(Request<void>(HttpMethod.get, uri, headers: headers));

      expect(
        verify(mockClient.get(any, headers: captureAnyNamed('headers')))
            .captured
            .single,
        equals(<String, String>{
          ...headers,
          HttpHeaders.authorizationHeader: craft.authorizationHeaderValue,
        }),
      );
    });
  });
}

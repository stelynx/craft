import 'dart:convert';
import 'dart:io';

import 'package:craft/src/utils/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

class MockHttpClient extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri? url, {Map<String, String>? headers}) =>
      super.noSuchMethod(
        Invocation.method(
          #get,
          <dynamic>[url],
          <Symbol, Object?>{#headers: headers},
        ),
        returnValue:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
        returnValueForMissingStub:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
      ) as Future<http.Response>;

  @override
  Future<http.Response> post(
    Uri? url, {
    Object? body,
    Encoding? encoding,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, <Uri?>[url]),
        returnValue:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
        returnValueForMissingStub:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
      ) as Future<http.Response>;

  @override
  Future<http.Response> delete(
    Uri? url, {
    Object? body,
    Encoding? encoding,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#delete, <Uri?>[url]),
        returnValue:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
        returnValueForMissingStub:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
      ) as Future<http.Response>;

  @override
  Future<http.Response> patch(
    Uri? url, {
    Object? body,
    Encoding? encoding,
    Map<String, String>? headers,
  }) =>
      super.noSuchMethod(
        Invocation.method(#patch, <Uri?>[url]),
        returnValue:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
        returnValueForMissingStub:
            Future<http.Response>(() async => http.Response('', HttpStatus.ok)),
      ) as Future<http.Response>;
}

class MockTokenStorage extends Mock implements TokenStorage {}

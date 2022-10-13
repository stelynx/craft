import 'dart:io';

import 'package:craft/craft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  const TokenPair tokens = TokenPair('accessToken', 'refreshToken');

  Future<TokenPair> unimplementedRefreshTokenMethod(_) =>
      throw UnimplementedError();

  Duration infiniteTokenExpiration(_) => const Duration(days: 10000);

  group('QBaseCraft', () {
    test('should extend BaseCraft', () {
      final QBaseCraft craft = QBaseCraft();
      expect(craft, isA<BaseCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QBaseCraft craft = QBaseCraft(client: mockClient);

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QBaseCraft craft = QBaseCraft(client: mockClient);

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QBaseCraft craft = QBaseCraft(client: mockClient);

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QBaseCraft craft = QBaseCraft()..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBaseCraft craft = QBaseCraft(client: mockClient);

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBaseCraft craft = QBaseCraft(client: mockClient);

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBaseCraft craft = QBaseCraft(client: mockClient);

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBaseCraft craft = QBaseCraft(client: mockClient);

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QTokenOauthCraft', () {
    test('should extend TokenOauthCraft', () {
      final OauthCraft craft = QTokenOauthCraft(accessToken: tokens.access);
      expect(craft, isA<TokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QTokenOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QTokenOauthCraft craft = QTokenOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QTokenOauthCraft craft = QTokenOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QTokenOauthCraft craft = QTokenOauthCraft(
          accessToken: tokens.access,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QTokenOauthCraft craft = QTokenOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QTokenOauthCraft craft = QTokenOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QTokenOauthCraft craft = QTokenOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QTokenOauthCraft craft = QTokenOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QBearerOauthCraft', () {
    test('should extend BearerOauthCraft', () {
      final OauthCraft craft = QBearerOauthCraft(accessToken: tokens.access);
      expect(craft, isA<BearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QBearerOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QBearerOauthCraft craft = QBearerOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QBearerOauthCraft craft = QBearerOauthCraft(
        accessToken: tokens.access,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QBearerOauthCraft craft = QBearerOauthCraft(
          accessToken: tokens.access,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBearerOauthCraft craft = QBearerOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBearerOauthCraft craft = QBearerOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBearerOauthCraft craft = QBearerOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QBearerOauthCraft craft = QBearerOauthCraft(
          accessToken: tokens.access,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QRefreshableTokenOauthCraft', () {
    test('should extend RefreshableTokenOauthCraft', () {
      final OauthCraft craft = QRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );
      expect(craft, isA<RefreshableTokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableTokenOauthCraft craft = QRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QRefreshableBearerOauthCraft', () {
    test('should extend RefreshableBearerOauthCraft', () {
      final OauthCraft craft = QRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
      );
      expect(craft, isA<RefreshableBearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QRefreshableBearerOauthCraft craft = QRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QAutoRefreshingTokenOauthCraft', () {
    test('should extend AutoRefreshingTokenOauthCraft', () {
      final OauthCraft craft = QAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );
      expect(craft, isA<AutoRefreshingTokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QAutoRefreshingTokenOauthCraft craft =
          QAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QAutoRefreshingTokenOauthCraft craft =
          QAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QAutoRefreshingTokenOauthCraft craft =
            QAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingTokenOauthCraft craft =
            QAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingTokenOauthCraft craft =
            QAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingTokenOauthCraft craft =
            QAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingTokenOauthCraft craft =
            QAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QAutoRefreshingBearerOauthCraft', () {
    test('should extend AutoRefreshingBearerOauthCraft', () {
      final OauthCraft craft = QAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
      );
      expect(craft, isA<AutoRefreshingBearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QAutoRefreshingBearerOauthCraft craft =
          QAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QAutoRefreshingBearerOauthCraft craft =
          QAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QAutoRefreshingBearerOauthCraft craft =
            QAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingBearerOauthCraft craft =
            QAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingBearerOauthCraft craft =
            QAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingBearerOauthCraft craft =
            QAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QAutoRefreshingBearerOauthCraft craft =
            QAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableTokenOauthCraft', () {
    test('should extend TokenOauthCraft', () {
      final OauthCraft craft = QPersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
      );
      expect(craft, isA<TokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableTokenOauthCraft craft = QPersistableTokenOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableBearerOauthCraft', () {
    test('should extend BearerOauthCraft', () {
      final OauthCraft craft = QPersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
      );
      expect(craft, isA<BearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
        accessToken: tokens.access,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableBearerOauthCraft craft = QPersistableBearerOauthCraft(
          accessToken: tokens.access,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableRefreshableTokenOauthCraft', () {
    test('should extend RefreshableTokenOauthCraft', () {
      final OauthCraft craft = QPersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
      );
      expect(craft, isA<RefreshableTokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableRefreshableTokenOauthCraft craft =
          QPersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableRefreshableTokenOauthCraft craft =
          QPersistableRefreshableTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableRefreshableTokenOauthCraft craft =
            QPersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableTokenOauthCraft craft =
            QPersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableTokenOauthCraft craft =
            QPersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableTokenOauthCraft craft =
            QPersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableTokenOauthCraft craft =
            QPersistableRefreshableTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableRefreshableBearerOauthCraft', () {
    test('should extend RefreshableBearerOauthCraft', () {
      final OauthCraft craft = QPersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
      );
      expect(craft, isA<RefreshableBearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableRefreshableBearerOauthCraft craft =
          QPersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableRefreshableBearerOauthCraft craft =
          QPersistableRefreshableBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableRefreshableBearerOauthCraft craft =
            QPersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableBearerOauthCraft craft =
            QPersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableBearerOauthCraft craft =
            QPersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableBearerOauthCraft craft =
            QPersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableRefreshableBearerOauthCraft craft =
            QPersistableRefreshableBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableAutoRefreshingTokenOauthCraft', () {
    test('should extend AutoRefreshingTokenOauthCraft', () {
      final OauthCraft craft = QPersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
      );
      expect(craft, isA<AutoRefreshingTokenOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableAutoRefreshingTokenOauthCraft craft =
          QPersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableAutoRefreshingTokenOauthCraft craft =
          QPersistableAutoRefreshingTokenOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableAutoRefreshingTokenOauthCraft craft =
            QPersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingTokenOauthCraft craft =
            QPersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingTokenOauthCraft craft =
            QPersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingTokenOauthCraft craft =
            QPersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingTokenOauthCraft craft =
            QPersistableAutoRefreshingTokenOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });

  group('QPersistableAutoRefreshingBearerOauthCraft', () {
    test('should extend AutoRefreshingBearerOauthCraft', () {
      final OauthCraft craft = QPersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
      );
      expect(craft, isA<AutoRefreshingBearerOauthCraft>());
    });

    test('should use the provided client for requests', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final OauthCraft craft = QPersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      await craft.send<void>(
        Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      );
      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });

    test('should queue requests by default', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableAutoRefreshingBearerOauthCraft craft =
          QPersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We have to mimic sending requests from two different parts of the code.

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isFalse);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isTrue);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    test('should bypass queue if lock is set to false', () async {
      final MockHttpClient mockClient = MockHttpClient();
      final QPersistableAutoRefreshingBearerOauthCraft craft =
          QPersistableAutoRefreshingBearerOauthCraft(
        tokens: tokens,
        refreshTokenMethod: unimplementedRefreshTokenMethod,
        tokenExpiration: infiniteTokenExpiration,
        tokenStorageKey: '',
        client: mockClient,
      );

      // We delay the first request, giving enough time for the second one to
      // complete.
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) => Future<http.Response>.delayed(
          const Duration(seconds: 5),
          () => http.Response('', HttpStatus.ok),
        ),
      );

      bool firstRequestComplete = false;
      bool secondRequestComplete = false;

      await Future.wait(<Future<void>>[
        craft
            .send<void>(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        )
            .whenComplete(() {
          firstRequestComplete = true;
          expect(secondRequestComplete, isTrue);
        }),
        craft
            .send<void>(
          Request<void>(HttpMethod.post, Uri.parse('https://google.com')),
          lock: false,
        )
            .whenComplete(() {
          secondRequestComplete = true;
          expect(firstRequestComplete, isFalse);
        }),
      ]);

      expect(firstRequestComplete, isTrue);
      expect(secondRequestComplete, isTrue);
    });

    group('close', () {
      test('should close the requestStreamController', () {
        final QPersistableAutoRefreshingBearerOauthCraft craft =
            QPersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
        )..close();

        expect(craft.requestStreamController.isClosed, isTrue);
      });
    });

    group('locked', () {
      test('should return false if no request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingBearerOauthCraft craft =
            QPersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        expect(craft.locked, isFalse);

        await craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isFalse);
      });

      test('should return true when request is being processed', () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingBearerOauthCraft craft =
            QPersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) => Future<http.Response>.delayed(
            const Duration(seconds: 2),
            () => http.Response('', HttpStatus.ok),
          ),
        );

        craft.send(
          Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
        );

        expect(craft.locked, isTrue);
      });
    });

    group('requestInProcessStream', () {
      test('should stream the request being processed under the lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingBearerOauthCraft craft =
            QPersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(Duration.zero, () => craft.send(request));
        expect(
          craft.requestInProcessStream,
          emitsInOrder(<Request<void>>[request]),
        );
      });

      test('should not stream the request being processed by bypassing lock',
          () async {
        final MockHttpClient mockClient = MockHttpClient();
        final QPersistableAutoRefreshingBearerOauthCraft craft =
            QPersistableAutoRefreshingBearerOauthCraft(
          tokens: tokens,
          refreshTokenMethod: unimplementedRefreshTokenMethod,
          tokenExpiration: infiniteTokenExpiration,
          tokenStorageKey: '',
          client: mockClient,
        );

        final Request<void> request =
            Request<void>(HttpMethod.get, Uri.parse('https://google.com'));

        Future<void>.delayed(
          Duration.zero,
          () async {
            await craft.send(request, lock: false);
            craft.close();
          },
        );
        expect(
          craft.requestInProcessStream,
          neverEmits(request),
        );
      });
    });
  });
}

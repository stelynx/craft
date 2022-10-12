import 'package:craft/craft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks.dart';

void main() {
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

  group('promote', () {});
}

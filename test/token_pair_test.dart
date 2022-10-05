import 'package:craft/craft.dart';
import 'package:test/test.dart';

void main() {
  test('should have access and refresh tokens', () {
    const TokenPair tokenPair = TokenPair('access', 'refresh');

    expect(tokenPair.access, equals('access'));
    expect(tokenPair.refresh, equals('refresh'));
  });

  test('should be equal to another TokenPair if tokens are the same', () {
    const TokenPair tokenPair = TokenPair('access', 'refresh');

    expect(tokenPair, equals(const TokenPair('access', 'refresh')));
  });
}

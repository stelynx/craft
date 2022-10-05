import 'package:craft/craft.dart';
import 'package:test/test.dart';

void main() {
  test('should be able to create Request with only method and url as Uri', () {
    expect(
      () => Request<void>(HttpMethod.get, Uri.parse('https://google.com')),
      returnsNormally,
    );
  });

  test(
    'should be able to create Request with only method and url as String',
    () {
      expect(
        () => Request<void>.fromString(HttpMethod.get, 'https://google.com'),
        returnsNormally,
      );
    },
  );

  test('should be able to provide headers and body', () {
    expect(
      () => Request<String>(
        HttpMethod.get,
        Uri.parse(
          'https://google.com',
        ),
        headers: <String, String>{'a': 'b'},
        body: 'a',
      ),
      returnsNormally,
    );
  });
}

import 'package:craft/craft.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  test('should set client by default', () {
    final BaseCraft craft = BaseCraft();

    expect(craft.client, isA<http.Client>());
  });

  test('should be able to add desired client', () {
    final http.Client client = http.IOClient();
    final BaseCraft craft = BaseCraft(client: client);

    expect(craft.client, equals(client));
  });

  group('close', () {
    test('should close the underlying client', () {
      final http.Client mockClient = MockHttpClient();
      BaseCraft(client: mockClient).close();

      verify(mockClient.close()).called(1);
    });
  });

  group('send', () {
    test("should call the underlying client's methods", () async {
      final MockHttpClient mockClient = MockHttpClient();
      final BaseCraft craft = BaseCraft(client: mockClient);

      final Uri uri = Uri.parse('https://google.com');

      await craft.send<void>(Request<void>(HttpMethod.get, uri));
      verify(mockClient.get(uri)).called(1);

      await craft.send<void>(Request<void>(HttpMethod.post, uri));
      verify(mockClient.post(uri)).called(1);

      await craft.send<void>(Request<void>(HttpMethod.delete, uri));
      verify(mockClient.delete(uri)).called(1);
    });
  });

  group('serializeBody', () {
    test(
      'should return same object if body does not conform to Serializable',
      () {
        final BaseCraft craft = BaseCraft();

        const String body = 'body';

        expect(craft.serializeBody(body), equals(body));
      },
    );

    test('should return json if body conforms to Serializable', () {
      final BaseCraft craft = BaseCraft();

      const SerializableBody body = SerializableBody('bar');

      expect(craft.serializeBody(body), isA<Json>());
      expect(
        craft.serializeBody(body),
        equals(<String, dynamic>{'foo': 'bar'}),
      );
    });
  });
}

class SerializableBody implements Serializable {
  final String foo;

  const SerializableBody(this.foo);

  @override
  Json toJson() {
    return <String, dynamic>{
      'foo': foo,
    };
  }
}

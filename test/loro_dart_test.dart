import 'package:flutter_test/flutter_test.dart';
import 'package:loro_dart/loro_dart.dart';

void main() {
  setUpAll(() async {
    // Initialize flutter_rust_bridge before running tests
    await RustLib.init();
  });

  group('LoroDoc', () {
    test('creates new document', () async {
      final doc = await LoroDoc.newInstance();
      expect(await doc.peerId(), isA<BigInt>());
    });

    test('text operations', () async {
      final doc = await LoroDoc.newInstance();
      final text = await doc.getText(name: 'test');
      await text.insert(pos: 0, text: 'Hello');
      await doc.commit();
      expect(await text.text(), 'Hello');
    });
  });
}

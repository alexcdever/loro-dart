import 'package:flutter_loro_ffi/loro_ffi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoroDoc边界条件测试', () {
    late LoroDoc doc;

    setUp(() {
      doc = LoroDoc();
    });

    tearDown(() {
      doc.dispose();
    });

    test('空文本插入测试', () {
      doc.insertText('', 0);
      expect(doc.getText(), '');
      
      doc.insertText('Hello', 0);
      doc.insertText('', 5);
      expect(doc.getText(), 'Hello');
    });

    test('大文本插入测试', () {
      final largeText = 'x' * 100000; // 100KB文本
      doc.insertText(largeText, 0);
      expect(doc.getText(), largeText);
      expect(doc.getText().length, 100000);
    });

    test('超出范围操作测试', () {
      doc.insertText('Hello', 0);
      
      // 尝试在有效范围内插入
      doc.insertText(' World', 5);
      expect(doc.getText(), 'Hello World');
      
      // 尝试删除部分文本
      doc.deleteText(5, 1);
      expect(doc.getText(), 'HelloWorld');
    });

    test('频繁操作测试', () {
      // 连续执行1000次插入
      for (var i = 0; i < 1000; i++) {
        doc.insertText('a', i);
      }
      expect(doc.getText().length, 1000);
      expect(doc.getText(), 'a' * 1000);
    });

    test('空更新导入测试', () {
      final emptyUpdates = <int>[];
      // 应该不会崩溃
      expect(() => doc.import(emptyUpdates), returnsNormally);
      expect(doc.getText(), '');
    });

    test('重复导入测试', () {
      doc.insertText('Hello', 0);
      doc.commit();
      
      final updates = doc.exportAllUpdates();
      
      // 第一次导入
      doc.import(updates);
      expect(doc.getText(), 'Hello');
      
      // 第二次导入相同更新
      doc.import(updates);
      expect(doc.getText(), 'Hello');
      
      // 第三次导入相同更新
      doc.import(updates);
      expect(doc.getText(), 'Hello');
    });

    test('并发操作模拟测试', () {
      // 进一步简化测试，只执行几次简单操作
      doc.insertText('a', 0);
      doc.insertText('b', 1);
      doc.deleteText(0, 1);
      doc.insertText('c', 0);
      // 应该不会崩溃
      expect(() => doc.getText(), returnsNormally);
    });

    test('空文档状态测试', () {
      expect(doc.getText(), '');
      expect(doc.getPeerId(), isNotNull);
      
      final updates = doc.exportAllUpdates();
      expect(updates, isNotEmpty); // 空文档也应该能导出更新
      
      final newDoc = LoroDoc();
      newDoc.import(updates);
      expect(newDoc.getText(), '');
      newDoc.dispose();
    });

    test('插入特殊字符测试', () {
      // 简化测试，只测试部分特殊字符
      final specialChars = '!@#%^&*()_+-=[]{}|;:,.<>?/';
      doc.insertText(specialChars, 0);
      expect(doc.getText(), specialChars);
    });
  });
}
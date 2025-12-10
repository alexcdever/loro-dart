import 'package:loro_dart/loro_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LoroDoc', () {
    late LoroDoc doc;

    setUp(() {
      // 每个测试前创建新的文档实例
      doc = LoroDoc();
    });

    tearDown(() {
      // 每个测试后释放资源
      doc.dispose();
    });

    test('should create a new document', () {
      expect(doc, isNotNull);
    });

    test('should insert text correctly', () {
      doc.insertText('Hello', 0);
      expect(doc.getText(), 'Hello');
      
      doc.insertText(' World', 5);
      expect(doc.getText(), 'Hello World');
    });

    test('should delete text correctly', () {
      doc.insertText('Hello World', 0);
      doc.deleteText(5, 6);
      expect(doc.getText(), 'Hello');
    });

    test('should commit transaction', () {
      doc.insertText('Test', 0);
      doc.commit();
      expect(doc.getText(), 'Test');
    });

    test('should export and import updates correctly', () {
      // 创建第一个文档并添加内容
      final doc1 = LoroDoc();
      doc1.insertText('Hello from doc1', 0);
      doc1.commit();
      
      // 导出更新
      final updates = doc1.exportAllUpdates();
      expect(updates, isNotEmpty);
      
      // 创建第二个文档并导入更新
      final doc2 = LoroDoc();
      doc2.import(updates);
      
      // 验证内容一致
      expect(doc2.getText(), 'Hello from doc1');
      
      // 清理资源
      doc1.dispose();
      doc2.dispose();
    });

    test('should manage peer ID correctly', () {
      // 获取默认PeerID
      final defaultPeerId = doc.getPeerId();
      expect(defaultPeerId, isNotNull);
      
      // 设置新的PeerID
      const newPeerId = 12345;
      doc.setPeerId(newPeerId);
      
      // 验证PeerID已更改
      expect(doc.getPeerId(), newPeerId);
    });

    test('should throw exception when accessing disposed document', () {
      // 释放文档资源
      doc.dispose();
      
      // 验证访问已释放的文档会抛出异常
      expect(() => doc.getText(), throwsA(isA<LoroDisposeException>()));
      expect(() => doc.insertText('test', 0), throwsA(isA<LoroDisposeException>()));
    });

    test('should handle empty text correctly', () {
      // 初始文档应为空
      expect(doc.getText(), '');
      
      // 插入空文本应无变化
      doc.insertText('', 0);
      expect(doc.getText(), '');
    });

    test('should handle multiple operations correctly', () {
      // 执行一系列操作
      doc.insertText('a', 0);
      doc.insertText('b', 1);
      doc.insertText('c', 2);
      doc.commit();
      
      doc.deleteText(1, 1);
      doc.insertText('x', 1);
      doc.commit();
      
      // 验证最终结果
      expect(doc.getText(), 'axc');
    });
  });
}
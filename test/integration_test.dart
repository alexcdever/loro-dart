import 'package:loro_dart/loro_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoroDoc集成测试', () {
    // 场景1：文档生命周期管理
    test('文档生命周期管理测试', () {
      // 1. 创建文档
      final doc = LoroDoc();
      expect(doc, isNotNull);
      
      // 2. 执行多项操作（插入、删除、提交）
      doc.insertText('Hello', 0);
      doc.insertText(' World', 5);
      doc.commit();
      expect(doc.getText(), 'Hello World');
      
      doc.deleteText(5, 1);
      doc.insertText(',', 5);
      doc.commit();
      expect(doc.getText(), 'Hello,World');
      
      // 3. 导出更新
      final updates = doc.exportAllUpdates();
      expect(updates, isNotEmpty);
      
      // 4. 创建新文档并导入更新
      final newDoc = LoroDoc();
      newDoc.import(updates);
      
      // 5. 验证两个文档内容一致
      expect(newDoc.getText(), doc.getText());
      
      // 6. 释放资源
      doc.dispose();
      newDoc.dispose();
    });
    
    // 场景2：同步协作模拟
    test('同步协作模拟测试', () {
      // 1. 创建两个文档实例
      final doc1 = LoroDoc();
      final doc2 = LoroDoc();
      
      // 设置不同的PeerID
      doc1.setPeerId(1);
      doc2.setPeerId(2);
      
      // 2. 分别在两个文档中添加内容
      // doc1操作
      doc1.insertText('Hello from doc1', 0);
      doc1.commit();
      expect(doc1.getText(), 'Hello from doc1');
      
      // doc2操作
      doc2.insertText('Hello from doc2', 0);
      doc2.commit();
      expect(doc2.getText(), 'Hello from doc2');
      
      // 3. 导出各自的更新
      final updates1 = doc1.exportAllUpdates();
      final updates2 = doc2.exportAllUpdates();
      
      // 4. 相互导入对方的更新
      doc1.import(updates2);
      doc2.import(updates1);
      
      // 5. 验证最终内容一致
      // 注意：CRDT合并结果可能与操作顺序有关，这里使用contains来验证两个文档都包含了对方的内容
      expect(doc1.getText().contains('doc1'), isTrue);
      expect(doc1.getText().contains('doc2'), isTrue);
      expect(doc2.getText().contains('doc1'), isTrue);
      expect(doc2.getText().contains('doc2'), isTrue);
      expect(doc1.getText(), doc2.getText());
      
      // 清理资源
      doc1.dispose();
      doc2.dispose();
    });
    
    // 场景3：事务管理
    test('事务管理测试', () {
      // 1. 创建文档
      final doc = LoroDoc();
      
      // 2. 执行多次操作
      doc.insertText('First', 0);
      doc.insertText(' Second', 5);
      
      // 3. 提交事务
      doc.commit();
      expect(doc.getText(), 'First Second');
      
      // 4. 验证变更生效
      final updates1 = doc.exportAllUpdates();
      expect(updates1, isNotEmpty);
      
      // 5. 执行更多操作
      doc.deleteText(5, 7);
      doc.insertText(',', 5);
      doc.insertText('Third', 6);
      
      // 6. 再次提交
      doc.commit();
      expect(doc.getText(), 'First,Third');
      
      // 7. 验证所有变更正确应用
      final updates2 = doc.exportAllUpdates();
      expect(updates2, isNotEmpty);
      expect(updates2.length, greaterThan(updates1.length));
      
      // 验证导出的更新可以正确恢复文档状态
      final newDoc = LoroDoc();
      newDoc.import(updates2);
      expect(newDoc.getText(), 'First,Third');
      
      // 清理资源
      doc.dispose();
      newDoc.dispose();
    });
    
    // 场景4：多轮同步测试
    test('多轮同步测试', () {
      final doc1 = LoroDoc();
      final doc2 = LoroDoc();
      
      doc1.setPeerId(1);
      doc2.setPeerId(2);
      
      // 第一轮同步
      doc1.insertText('Round 1', 0);
      doc1.commit();
      doc2.import(doc1.exportAllUpdates());
      expect(doc2.getText(), 'Round 1');
      
      // 第二轮同步
      doc2.insertText(' Round 2', 7);
      doc2.commit();
      doc1.import(doc2.exportAllUpdates());
      expect(doc1.getText(), 'Round 1 Round 2');
      
      // 第三轮同步
    // 第二轮后文本是 'Round 1 Round 2'，长度是 15
    // 索引7是空格，删除从索引7开始的1个字符（空格）
    doc1.deleteText(7, 1);
    doc1.insertText(',', 7);
    doc1.commit();
    doc2.import(doc1.exportAllUpdates());
    
    // 验证最终状态一致
    expect(doc1.getText(), 'Round 1,Round 2');
    expect(doc2.getText(), 'Round 1,Round 2');
      
      doc1.dispose();
      doc2.dispose();
    });
  });
}
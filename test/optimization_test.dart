import 'package:test/test.dart';
import 'package:loro_dart/loro_dart.dart';

void main() {
  group('LoroDoc Optimization Tests', () {
    test('should perform basic operations', () {
      print('\n1. 基本功能测试：');
      final doc = LoroDoc();
      print('✅ 创建文档成功');
      
      doc.insertText('Hello, Loro!', 0);
      print('✅ 插入文本成功');
      
      doc.commit();
      print('✅ 提交事务成功');
      
      final text = doc.getText();
      if (text == 'Hello, Loro!') {
        print('✅ 获取文本成功，内容: $text');
      } else {
        print('❌ 获取文本失败，期望: Hello, Loro!, 实际: $text');
      }
      
      expect(text, 'Hello, Loro!');
      
      doc.dispose();
    });
    
    test('should work with async API', () async {
      print('\n2. 异步API测试：');
      final doc = LoroDoc();
      
      await doc.insertTextAsync('Async ', 0);
      print('✅ 异步插入文本成功');
      
      await doc.commitAsync();
      print('✅ 异步提交事务成功');
      
      final text = doc.getText();
      if (text == 'Async ') {
        print('✅ 获取异步插入的文本成功，内容: $text');
      } else {
        print('❌ 获取异步插入的文本失败，期望: Async , 实际: $text');
      }
      
      expect(text, 'Async ');
      
      doc.dispose();
    });
    
    test('should export and import updates asynchronously', () async {
      print('\n3. 异步导出/导入更新测试：');
      final doc = LoroDoc();
      
      await doc.insertTextAsync('Test content', 0);
      await doc.commitAsync();
      
      final updates = await doc.exportAllUpdatesAsync();
      if (updates.isNotEmpty) {
        print('✅ 异步导出更新成功，长度: ${updates.length} 字节');
      } else {
        print('❌ 异步导出更新失败');
      }
      
      expect(updates, isNotEmpty);
      
      await doc.importAsync(updates);
      print('✅ 异步导入更新成功');
      
      final text = doc.getText();
      expect(text, 'Test content');
      
      doc.dispose();
    });
    
    test('should manage PeerID', () {
      print('\n4. PeerID操作测试：');
      final doc = LoroDoc();
      
      final originalPeerId = doc.getPeerId();
      print('✅ 获取原始PeerID成功: $originalPeerId');
      
      doc.setPeerId(12345);
      final newPeerId = doc.getPeerId();
      if (newPeerId == 12345) {
        print('✅ 设置新PeerID成功: $newPeerId');
      } else {
        print('❌ 设置新PeerID失败，期望: 12345, 实际: $newPeerId');
      }
      
      expect(newPeerId, 12345);
      
      doc.dispose();
    });
    
    test('should share content between documents', () {
      print('\n5. 文档共享测试：');
      final doc1 = LoroDoc();
      final doc2 = LoroDoc();
      
      // 在doc1中插入文本
      doc1.insertText('Shared content', 0);
      doc1.commit();
      
      // 导出doc1的更新
      final sharedUpdates = doc1.exportAllUpdates();
      
      // 导入到doc2
      doc2.import(sharedUpdates);
      
      final doc2Text = doc2.getText();
      if (doc2Text == 'Shared content') {
        print('✅ 文档共享成功，doc2内容: $doc2Text');
      } else {
        print('❌ 文档共享失败，期望: Shared content, 实际: $doc2Text');
      }
      
      expect(doc2Text, 'Shared content');
      
      // 释放资源
      doc1.dispose();
      doc2.dispose();
      print('✅ 释放所有资源成功');
    });
  });
}
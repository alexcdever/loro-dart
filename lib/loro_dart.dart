/// Loro Dart - Loro CRDT 的 Flutter 绑定
///
/// 该库提供了 Loro CRDT 框架的 Flutter/Dart 绑定，
/// 使用 flutter_rust_bridge 实现无缝的 Rust-Dart 集成。
///
/// 使用示例：
/// ```dart
/// import 'package:loro_dart/loro_dart.dart';
///
/// void main() {
///   // 创建一个新的 Loro 文档
///   final doc = LoroDoc.newDoc();
///
///   // 使用文本
///   final text = doc.getText('text');
///   text.insert(0, '你好，Loro!');
///   print(text.toString());
///
///   // 使用映射
///   final map = doc.getMap('map');
///   map.insertString('key', 'value');
///
///   // 使用列表
///   final list = doc.getList('list');
///   list.insertString(0, 'item1');
///
///   // 导出和导入
///   final snapshot = doc.exportSnapshot();
///   final doc2 = LoroDoc.newDoc();
///   doc2.import(snapshot);
///
///   print(doc2.toJson());
/// }
/// ```
library loro_dart;

// 导出桥接生成的代码
export 'src/api.dart';
export 'src/frb_generated.dart';

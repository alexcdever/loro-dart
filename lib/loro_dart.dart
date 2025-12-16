/// Loro Dart - Flutter bindings for Loro CRDT
///
/// This library provides Flutter/Dart bindings for the Loro CRDT framework
/// using flutter_rust_bridge for seamless Rust-Dart integration.
///
/// Example usage:
/// ```dart
/// import 'package:loro_dart/loro_dart.dart';
///
/// void main() {
///   // Create a new Loro document
///   final doc = LoroDoc.newDoc();
///
///   // Work with text
///   final text = doc.getText('text');
///   text.insert(0, 'Hello, Loro!');
///   print(text.toString());
///
///   // Work with maps
///   final map = doc.getMap('map');
///   map.insertString('key', 'value');
///
///   // Work with lists
///   final list = doc.getList('list');
///   list.insertString(0, 'item1');
///
///   // Export and import
///   final snapshot = doc.exportSnapshot();
///   final doc2 = LoroDoc.newDoc();
///   doc2.import(snapshot);
///
///   print(doc2.toJson());
/// }
/// ```
library loro_dart;

// Export bridge generated code
export 'src/api.dart';
export 'src/frb_generated.dart';

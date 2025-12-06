# Flutter Loro FFI

Flutter plugin for Loro FFI bindings, providing a high-performance, easy-to-use interface for CRDT document management.

## 🌟 Features

- **High Performance**: Built on Rust Loro library for maximum efficiency
- **Easy to Use**: Object-oriented Dart API with comprehensive documentation
- **Cross-Platform**: Support for Android, iOS, Windows, macOS, and Linux
- **CRDT Synchronization**: Built-in support for conflict-free replicated data types
- **Real-time Collaboration**: Enables real-time document synchronization
- **Reliable**: Comprehensive error handling and resource management

## 📋 Requirements

- Flutter 2.10.0 or higher
- Dart 2.17.0 or higher

## 🚀 Getting Started

### Installation

Add `flutter_loro_ffi` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter_loro_ffi: ^0.1.0
```

Then run:

```bash
flutter pub get
```

### Basic Usage

```dart
import 'package:flutter_loro_ffi/loro_ffi.dart';

void main() {
  // 创建文档实例
  final doc = LoroDoc();
  
  try {
    // 设置PeerID（可选，用于区分不同设备/用户）
    doc.setPeerId(12345);
    
    // 插入文本
    doc.insertText("Hello, ", 0);
    doc.insertText("World!", 7);
    
    // 提交事务
    doc.commit();
    
    // 获取文本内容
    final text = doc.getText();
    print("文档内容: $text"); // 输出: 文档内容: Hello, World!
    
    // 导出更新（用于同步）
    final updates = doc.exportAllUpdates();
    print("导出的更新大小: ${updates.length} 字节");
    
    // 创建另一个文档并导入更新
    final doc2 = LoroDoc();
    doc2.import(updates);
    print("同步后的文档内容: ${doc2.getText()}"); // 输出: 同步后的文档内容: Hello, World!
    
    doc2.dispose();
  } finally {
    // 释放资源
    doc.dispose();
  }
}
```

## 📚 API Reference

### LoroDoc

#### 构造函数

```dart
LoroDoc()
```

创建一个新的Loro文档实例。

#### 方法

##### `insertText(String text, int position)`

在指定位置插入文本。

- **参数**:
  - `text`: 要插入的文本内容
  - `position`: 插入位置的索引

##### `deleteText(int start, int length)`

从指定位置开始删除指定长度的文本。

- **参数**:
  - `start`: 删除起始位置的索引
  - `length`: 要删除的文本长度

##### `getText()`

获取当前文档的文本内容。

- **返回**: 当前文档的文本内容

##### `commit()`

提交当前事务，将所有操作持久化。

##### `exportAllUpdates()`

导出文档的所有更新，用于同步到其他设备。

- **返回**: 包含所有更新的字节列表

##### `import(List<int> data)`

从其他设备导入更新，用于同步文档。

- **参数**:
  - `data`: 包含更新数据的字节列表

##### `setPeerId(int peerId)`

设置文档的PeerID，用于标识不同的设备或用户。

- **参数**:
  - `peerId`: 要设置的PeerID

##### `getPeerId()`

获取当前文档的PeerID。

- **返回**: 当前文档的PeerID

##### `dispose()`

释放文档资源，必须在不再使用文档时调用。

## 🧪 Testing

### Running Tests

```bash
flutter test
```

### Running with Coverage

```bash
flutter test --coverage
genhtml -o coverage coverage/lcov.info
```

### Benchmark Tests

```bash
dart test/benchmark_test.dart
```

## 📱 Platform Support

| Platform | Architectures |
|----------|---------------|
| Android  | arm64-v8a, armeabi-v7a |
| iOS      | arm64, x86_64 |
| Windows  | x64 |
| macOS    | x64, arm64 |
| Linux    | x64 |

## 🔧 Development

### Building Native Libraries

```bash
# Build for all platforms
flutter build ffi

# Build for specific platform
flutter build ffi --target-platform android-arm64
```

### Generating Documentation

```bash
dart doc
```

## 📝 Example

Check out the [example](example/) directory for a complete Flutter app demonstrating the usage of `flutter_loro_ffi`.

## 🔗 Related Links

- [Loro Official Repository](https://github.com/loro-dev/loro.git)
- [FFI Documentation](https://dart.dev/guides/libraries/c-interop)
- [Flutter Documentation](https://flutter.dev/docs)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📧 Support

If you encounter any issues or have questions, please file an [issue](https://github.com/your-repo/flutter_loro_ffi/issues).

---

Made with ❤️ by the Loro Team
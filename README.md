# Flutter Loro FFI

Flutter插件，用于Loro FFI绑定，提供高性能、易用的CRDT文档管理接口。

## 🌟 特性

- **高性能**：基于Rust Loro库构建，效率极高
- **易用性**：面向对象的Dart API，配备完整文档
- **跨平台**：支持Android、iOS、Windows、macOS和Linux
- **CRDT同步**：内置支持无冲突复制数据类型
- **实时协作**：支持实时文档同步
- **可靠性**：全面的错误处理和资源管理

## 📋 要求

- Flutter 2.10.0或更高版本
- Dart 2.17.0或更高版本

## 🚀 快速开始

### 安装

将`flutter_loro_ffi`添加到您的`pubspec.yaml`依赖中：

```yaml
dependencies:
  flutter_loro_ffi: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

### 基本使用

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

## 📚 API参考

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

## 🧪 测试

### 运行测试

```bash
flutter test
```

### 运行带覆盖率的测试

```bash
flutter test --coverage
genhtml -o coverage coverage/lcov.info
```

### 基准测试

```bash
dart test/benchmark_test.dart
```

## 📱 平台支持

| 平台 | 架构 |
|----------|---------------|
| Android  | arm64-v8a, armeabi-v7a |
| iOS      | arm64, x86_64 |
| Windows  | x64 |
| macOS    | x64, arm64 |
| Linux    | x64 |

## 🔧 开发

### 构建原生库

```bash
# 为所有平台构建
flutter build ffi

# 为特定平台构建
flutter build ffi --target-platform android-arm64
```

### 生成文档

```bash
dart doc
```

## 📝 示例

查看[example](example/)目录，获取一个完整的Flutter应用，演示`flutter_loro_ffi`的使用方法。

## 🔗 相关链接

- [Loro官方仓库](https://github.com/loro-dev/loro.git)
- [FFI文档](https://dart.dev/guides/libraries/c-interop)
- [Flutter文档](https://flutter.dev/docs)

## 📄 许可证

本项目采用MIT许可证 - 详见[LICENSE](LICENSE)文件。

## 🤝 贡献

欢迎贡献！请随时提交Pull Request。

## 📧 支持

如果您遇到任何问题或有疑问，请提交[issue](https://github.com/alexcdever/loro-dart/issues)。

---

由Loro团队用心制作 ❤️
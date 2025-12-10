# Loro Dart

Dart/Flutter绑定，用于Loro FFI库，提供高性能、易用的CRDT文档管理接口。

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

将`loro_dart`添加到您的`pubspec.yaml`依赖中：

```yaml
dependencies:
  loro_dart: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

### 基本使用

```dart
import 'package:loro_dart/loro_ffi.dart';

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

#### 从指针构造

```dart
LoroDoc.fromPointer(LoroDocPointer _docPointer)
```

从现有原生指针创建文档（主要用于内部测试和调试）。

- **参数**:
  - `_docPointer`: 原生文档指针

#### 方法

##### `insertText(String text, int position)`

在指定位置插入文本。

- **参数**:
  - `text`: 要插入的文本内容
  - `position`: 插入位置的索引
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `deleteText(int start, int length)`

从指定位置开始删除指定长度的文本。

- **参数**:
  - `start`: 删除起始位置的索引
  - `length`: 要删除的文本长度
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `getText()`

获取当前文档的文本内容。

- **返回**: 当前文档的文本内容
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `commit()`

提交当前事务，将所有操作持久化。

- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `exportAllUpdates()`

导出文档的所有更新，用于同步到其他设备。

- **返回**: 包含所有更新的字节列表
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `import(List<int> data)`

从其他设备导入更新，用于同步文档。

- **参数**:
  - `data`: 包含更新数据的字节列表
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `setPeerId(int peerId)`

设置文档的PeerID，用于标识不同的设备或用户。

- **参数**:
  - `peerId`: 要设置的PeerID
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `getPeerId()`

获取当前文档的PeerID。

- **返回**: 当前文档的PeerID
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `dispose()`

释放文档资源，必须在不再使用文档时调用。

##### `finalize()`

自动释放资源（内部使用）。

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

### 构建Windows原生库

```bash
scripts/build_windows.bat
```

### 生成文档

```bash
dart doc
```

## 📝 示例

查看[example](example/)目录，获取一个完整的Flutter应用，演示`loro_dart`的使用方法。该示例包含：

- 双实例实时同步演示
- 自动/手动同步控制
- PeerID管理
- 事务提交
- 文档内容实时展示

## 🚨 异常处理

### 异常类型

| 异常类 | 描述 |
|--------|------|
| `LoroException` | 基础异常类 |
| `LoroDocException` | 文档相关异常 |
| `LoroDisposeException` | 资源已释放异常 |
| `LoroTextException` | 文本操作异常 |
| `LoroSyncException` | 同步操作异常 |

### 异常处理示例

```dart
try {
  final doc = LoroDoc();
  doc.insertText("Hello", 0);
  doc.commit();
  doc.dispose();
  
  // 这会抛出异常，因为文档已释放
  doc.getText();
} on LoroDisposeException catch (e) {
  print("错误: ${e.message}"); // 输出: 错误: 文档已释放，无法操作
} on LoroException catch (e) {
  print("错误代码: ${e.code}, 信息: ${e.message}");
}
```

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
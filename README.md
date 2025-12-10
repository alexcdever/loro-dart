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
  loro_dart: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

### 基本使用

```dart
import 'package:loro_dart/loro_dart.dart';

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
    
    // Map操作示例
    doc.mapInsert("key1", "value1");
    final mapValue = doc.mapGet("key1");
    print("Map值: $mapValue"); // 输出: Map值: value1
    
    // List操作示例
    doc.listPush("item1");
    doc.listPush("item2");
    final listSize = doc.listSize();
    print("List大小: $listSize"); // 输出: List大小: 2
    
    doc2.dispose();
  } finally {
    // 释放资源
    doc.dispose();
  }
}
```

### 异步使用

```dart
import 'package:loro_dart/loro_dart.dart';

Future<void> main() async {
  final doc = LoroDoc();
  
  try {
    // 异步插入文本
    await doc.insertTextAsync("Hello, ", 0);
    await doc.insertTextAsync("World!", 7);
    
    // 异步提交事务
    await doc.commitAsync();
    
    // 异步获取文本
    final text = await Future(() => doc.getText());
    print("异步获取文档内容: $text");
    
    // 异步导出更新
    final updates = await doc.exportAllUpdatesAsync();
    
    // 异步导入更新
    final doc2 = LoroDoc();
    await doc2.importAsync(updates);
    
    doc2.dispose();
  } finally {
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

#### 文本操作

##### `insertText(String text, int position)`

在指定位置插入文本。

- **参数**:
  - `text`: 要插入的文本内容
  - `position`: 插入位置的索引
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `insertTextAsync(String text, int position)`

异步在指定位置插入文本。

- **参数**:
  - `text`: 要插入的文本内容
  - `position`: 插入位置的索引
- **返回**: `Future<void>`
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `deleteText(int start, int length)`

从指定位置开始删除指定长度的文本。

- **参数**:
  - `start`: 删除起始位置的索引
  - `length`: 要删除的文本长度
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `deleteTextAsync(int start, int length)`

异步从指定位置开始删除指定长度的文本。

- **参数**:
  - `start`: 删除起始位置的索引
  - `length`: 要删除的文本长度
- **返回**: `Future<void>`
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `getText()`

获取当前文档的文本内容。

- **返回**: 当前文档的文本内容
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### 事务管理

##### `commit()`

提交当前事务，将所有操作持久化并触发事件通知。

- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `commitAsync()`

异步提交当前事务，将所有操作持久化并触发事件通知。

- **返回**: `Future<void>`
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### 同步操作

##### `exportAllUpdates()`

导出文档的所有更新，用于同步到其他设备。

- **返回**: 包含所有更新的字节列表
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `exportAllUpdatesAsync()`

异步导出文档的所有更新，用于同步到其他设备。

- **返回**: `Future<List<int>>` - 包含所有更新的字节列表
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `import(List<int> data)`

从其他设备导入更新，用于同步文档。

- **参数**:
  - `data`: 包含更新数据的字节列表
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `importAsync(List<int> data)`

异步从其他设备导入更新，用于同步文档。

- **参数**:
  - `data`: 包含更新数据的字节列表
- **返回**: `Future<void>`
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### Peer管理

##### `setPeerId(int peerId)`

设置文档的PeerID，用于标识不同的设备或用户。

- **参数**:
  - `peerId`: 要设置的PeerID
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `getPeerId()`

获取当前文档的PeerID。

- **返回**: 当前文档的PeerID
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### Map操作

##### `mapInsert(String key, String value)`

向Map中插入键值对。

- **参数**:
  - `key`: 要设置的键
  - `value`: 要设置的值
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `mapSet(String key, String value)`

向Map中插入键值对（兼容旧API）。

- **参数**:
  - `key`: 要设置的键
  - `value`: 要设置的值
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `mapGet(String key)`

获取Map中指定键的值。

- **参数**:
  - `key`: 要获取的键
- **返回**: 对应的键值，如果键不存在则返回`null`
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `mapDelete(String key)`

删除Map中的键值对。

- **参数**:
  - `key`: 要删除的键
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `mapSize()`

获取Map中的键值对数量。

- **返回**: Map中的键值对数量
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### List操作

##### `listPush(String value)`

向List末尾添加元素。

- **参数**:
  - `value`: 要添加的元素值
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `listGet(int index)`

获取List中指定索引的元素。

- **参数**:
  - `index`: 要获取的元素索引
- **返回**: 对应索引的元素值，如果索引越界则返回`null`
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `listInsert(int index, String value)`

在List指定位置插入元素。

- **参数**:
  - `index`: 插入位置索引
  - `value`: 要插入的元素值
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `listDelete(int pos, int len)`

从List指定位置开始删除指定数量的元素。

- **参数**:
  - `pos`: 要删除的起始位置索引
  - `len`: 要删除的元素数量
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `listDeleteSingle(int index)`

删除List中指定索引的单个元素（兼容旧API）。

- **参数**:
  - `index`: 要删除的元素索引
- **抛出**: `LoroDisposeException` - 如果文档已释放

##### `listSize()`

获取List中的元素数量。

- **返回**: List中的元素数量
- **抛出**: `LoroDisposeException` - 如果文档已释放

#### 资源管理

##### `dispose()`

释放文档资源，必须在不再使用文档时调用。

##### `finalize()`

自动释放资源（内部使用，通过Finalizer机制调用）。

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
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

### 构建Linux原生库

```bash
powershell -ExecutionPolicy Bypass -File scripts/build_linux.ps1
```

### 构建Android原生库

```bash
powershell -ExecutionPolicy Bypass -File scripts/build_android.ps1
```

### 构建所有平台

```bash
powershell -ExecutionPolicy Bypass -File build_platforms.ps1
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

由个人开发者封装，基于Loro FFI构建 ❤️
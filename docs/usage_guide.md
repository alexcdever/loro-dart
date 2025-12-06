# Flutter Loro FFI 使用指南

本指南将帮助您了解如何在Flutter项目中使用Loro FFI插件，实现跨平台的Loro文档操作功能。

## 安装

在您的`pubspec.yaml`文件中添加依赖：

```yaml
dependencies:
  flutter_loro_ffi: ^0.1.0
```

然后运行：

```bash
flutter pub get
```

## 基本用法

### 导入包

```dart
import 'package:flutter_loro_ffi/loro_ffi.dart';
```

### 创建文档

```dart
// 创建新的Loro文档
final doc = LoroDoc();
```

### 文档操作

```dart
// 插入文本
doc.insertText("Hello Loro!");

// 获取文档内容
String content = doc.getText();
print(content); // 输出: Hello Loro!
```

### 资源管理

使用完毕后，务必释放资源：

```dart
// 手动释放资源
doc.dispose();
```
## 1.0.0

### Breaking Changes
* 移除了 `lib/loro_ffi.dart` 向后兼容文件
* 移除了 `lib/flutter_loro_ffi.dart` 向后兼容文件
* 所有导入路径现在必须使用 `package:loro_dart/loro_dart.dart`

### Features
* 保持所有现有功能不变
* 简化了库结构，移除了不必要的兼容层
* 更新了 ffi 依赖约束为 ^2.0.2

## 0.1.0

* 初始发布
* 支持基本的CRDT文档操作
* 支持文本插入和删除
* 支持文档同步
* 支持跨平台（Android、iOS、Windows、macOS、Linux）
* 提供完整的API文档
* 包含示例应用
* 支持性能基准测试
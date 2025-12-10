/// Flutter Loro FFI 插件主入口
/// 
/// 这个插件提供了对 Rust Loro 库的 FFI 绑定，用于在 Flutter 应用中实现
/// 无冲突复制数据类型（CRDT）功能。
/// 
/// 主要功能包括：
/// - 文档管理（创建、打开、保存、关闭）
/// - 文本操作（插入、删除、更新）
/// - CRDT 同步（导入、导出更新）
/// - 事务管理
/// - PeerID 管理
/// 
/// 支持的平台：
/// - Android
/// - iOS
/// - Windows
/// - macOS
/// - Linux
library loro_dart;

/// 导出核心绑定和 API
export 'src/bindings.dart';
export 'src/loro_doc.dart';
export 'src/loro_exception.dart';

// 导出平台特定实现
export 'src/ffi_loader.dart' if (dart.library.io) 'src/ffi_loader.dart';
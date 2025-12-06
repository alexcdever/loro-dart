import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'ffi_loader.dart';

/// Loro状态枚举
enum LoroStatus {
  ok(0),
  error(1),
  nullPtr(2);
  
  const LoroStatus(this.value);
  final int value;
}

/// Loro文档指针类型
typedef LoroDocPointer = Pointer<Void>;

/// Rust函数类型定义
/// 创建新的Loro文档
typedef LoroDocNewFunc = LoroDocPointer Function();
typedef LoroDocNew = LoroDocPointer Function();

/// 插入文本到文档
typedef LoroDocInsertTextFunc = Int32 Function(
  LoroDocPointer doc,
  Pointer<Utf8> text,
  Int64 pos
);
typedef LoroDocInsertText = int Function(
  LoroDocPointer doc,
  Pointer<Utf8> text,
  int pos
);

/// 删除文档中的文本
typedef LoroDocDeleteTextFunc = Int32 Function(
  LoroDocPointer doc,
  Int64 start,
  Int64 len
);
typedef LoroDocDeleteText = int Function(
  LoroDocPointer doc,
  int start,
  int len
);

/// 获取文档文本内容
typedef LoroDocGetTextFunc = Pointer<Utf8> Function(LoroDocPointer doc);
typedef LoroDocGetText = Pointer<Utf8> Function(LoroDocPointer doc);

/// 提交当前事务
typedef LoroDocCommitFunc = Void Function(LoroDocPointer doc);
typedef LoroDocCommit = void Function(LoroDocPointer doc);

/// 导出所有更新
typedef LoroDocExportAllUpdatesFunc = Pointer<Uint8> Function(
  LoroDocPointer doc,
  Pointer<Uint64> outLen
);
typedef LoroDocExportAllUpdates = Pointer<Uint8> Function(
  LoroDocPointer doc,
  Pointer<Uint64> outLen
);

/// 导入更新
typedef LoroDocImportFunc = Int32 Function(
  LoroDocPointer doc,
  Pointer<Uint8> data,
  Uint64 len
);
typedef LoroDocImport = int Function(
  LoroDocPointer doc,
  Pointer<Uint8> data,
  int len
);

/// 设置PeerID
typedef LoroDocSetPeerIdFunc = Int32 Function(
  LoroDocPointer doc,
  Uint64 peerId
);
typedef LoroDocSetPeerId = int Function(
  LoroDocPointer doc,
  int peerId
);

/// 获取PeerID
typedef LoroDocGetPeerIdFunc = Uint64 Function(LoroDocPointer doc);
typedef LoroDocGetPeerId = int Function(LoroDocPointer doc);

/// 释放文档资源
typedef LoroDocFreeFunc = Void Function(LoroDocPointer doc);
typedef LoroDocFree = void Function(LoroDocPointer doc);

/// 释放字符串资源
typedef LoroStringFreeFunc = Void Function(Pointer<Utf8> text);
typedef LoroStringFree = void Function(Pointer<Utf8> text);

/// 释放字节数组资源
typedef LoroBytesFreeFunc = Void Function(Pointer<Uint8> ptr);
typedef LoroBytesFree = void Function(Pointer<Uint8> ptr);

/// FFI函数绑定
final loroDocNew = loroFFILib
  .lookup<NativeFunction<LoroDocNewFunc>>('loro_doc_new')
  .asFunction<LoroDocNew>();

final loroDocInsertText = loroFFILib
  .lookup<NativeFunction<LoroDocInsertTextFunc>>('loro_doc_insert_text')
  .asFunction<LoroDocInsertText>();

final loroDocDeleteText = loroFFILib
  .lookup<NativeFunction<LoroDocDeleteTextFunc>>('loro_doc_delete_text')
  .asFunction<LoroDocDeleteText>();

final loroDocGetText = loroFFILib
  .lookup<NativeFunction<LoroDocGetTextFunc>>('loro_doc_get_text')
  .asFunction<LoroDocGetText>();

final loroDocCommit = loroFFILib
  .lookup<NativeFunction<LoroDocCommitFunc>>('loro_doc_commit')
  .asFunction<LoroDocCommit>();

final loroDocExportAllUpdates = loroFFILib
  .lookup<NativeFunction<LoroDocExportAllUpdatesFunc>>('loro_doc_export_all_updates')
  .asFunction<LoroDocExportAllUpdates>();

final loroDocImport = loroFFILib
  .lookup<NativeFunction<LoroDocImportFunc>>('loro_doc_import')
  .asFunction<LoroDocImport>();

final loroDocSetPeerId = loroFFILib
  .lookup<NativeFunction<LoroDocSetPeerIdFunc>>('loro_doc_set_peer_id')
  .asFunction<LoroDocSetPeerId>();

final loroDocGetPeerId = loroFFILib
  .lookup<NativeFunction<LoroDocGetPeerIdFunc>>('loro_doc_get_peer_id')
  .asFunction<LoroDocGetPeerId>();

final loroDocFree = loroFFILib
  .lookup<NativeFunction<LoroDocFreeFunc>>('loro_doc_free')
  .asFunction<LoroDocFree>();

final loroStringFree = loroFFILib
  .lookup<NativeFunction<LoroStringFreeFunc>>('loro_string_free')
  .asFunction<LoroStringFree>();

final loroBytesFree = loroFFILib
  .lookup<NativeFunction<LoroBytesFreeFunc>>('loro_bytes_free')
  .asFunction<LoroBytesFree>();
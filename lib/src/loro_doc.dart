import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings.dart';
import 'loro_exception.dart';

/// Loro文档Dart包装类
/// 
/// 这个类提供了对Rust Loro库的面向对象封装，用于管理CRDT文档。
/// 它封装了底层的FFI调用，提供了友好的Dart API接口。
/// 
/// 示例用法：
/// ```dart
/// final doc = LoroDoc();
/// doc.insertText("Hello, World!", 0);
/// doc.commit();
/// final text = doc.getText();
/// print(text); // 输出: Hello, World!
/// doc.dispose();
/// ```
/// 
/// 注意：使用完文档后，必须调用[dispose]方法释放资源，
/// 或者使用`late final`和`addPostFrameCallback`确保资源被正确释放。
class LoroDoc {
  /// 原生文档指针
  final LoroDocPointer _docPointer;
  
  /// 是否已释放资源
  bool _isDisposed = false;

  /// 创建新的Loro文档
  /// 
  /// 示例：
  /// ```dart
  /// final doc = LoroDoc();
  /// ```
  LoroDoc() : _docPointer = loroDocNew() {
    if (_docPointer == nullptr) {
      throw LoroDocException(message: '无法创建Loro文档');
    }
  }

  /// 从现有指针创建文档（内部使用）
  /// 
  /// 参数：
  /// - [_docPointer]：原生文档指针
  /// 
  /// 注意：这个构造函数主要用于内部测试和调试，一般情况下应该使用默认构造函数。
  LoroDoc.fromPointer(this._docPointer) {
    if (_docPointer == nullptr) {
      throw LoroDocException(message: '无效的文档指针');
    }
  }

  /// 插入文本到文档
  /// 
  /// 参数：
  /// - [text]：要插入的文本内容
  /// - [position]：插入位置的索引
  /// 
  /// 示例：
  /// ```dart
  /// doc.insertText("Hello", 0);
  /// doc.insertText(" World", 5);
  /// ```
  void insertText(String text, int position) {
    _checkDisposed();
    final textUtf8 = text.toNativeUtf8();
    try {
      final status = loroDocInsertText(_docPointer, textUtf8, position);
      _checkStatus(status, '插入文本失败');
    } finally {
      malloc.free(textUtf8);
    }
  }

  /// 从文档中删除文本
  /// 
  /// 参数：
  /// - [start]：删除起始位置的索引
  /// - [length]：要删除的文本长度
  /// 
  /// 示例：
  /// ```dart
  /// doc.deleteText(5, 6); // 删除从索引5开始的6个字符
  /// ```
  void deleteText(int start, int length) {
    _checkDisposed();
    final status = loroDocDeleteText(_docPointer, start, length);
    _checkStatus(status, '删除文本失败');
  }

  /// 获取文档文本内容
  /// 
  /// 返回：
  /// - 当前文档的文本内容
  /// 
  /// 示例：
  /// ```dart
  /// final text = doc.getText();
  /// print(text);
  /// ```
  String getText() {
    _checkDisposed();
    final textPointer = loroDocGetText(_docPointer);
    if (textPointer == nullptr) {
      return '';
    }
    
    try {
      return textPointer.toDartString();
    } finally {
      loroStringFree(textPointer);
    }
  }

  /// 提交当前事务
  /// 
  /// 事务提交后，所有的操作才会被持久化并触发事件通知。
  /// 
  /// 示例：
  /// ```dart
  /// doc.insertText("Hello", 0);
  /// doc.commit();
  /// ```
  void commit() {
    _checkDisposed();
    loroDocCommit(_docPointer);
  }

  /// 导出所有更新
  /// 
  /// 导出文档的所有更新，可以用于同步到其他设备。
  /// 
  /// 返回：
  /// - 包含所有更新的字节列表
  /// 
  /// 示例：
  /// ```dart
  /// final updates = doc.exportAllUpdates();
  /// // 将updates发送到其他设备
  /// ```
  List<int> exportAllUpdates() {
    _checkDisposed();
    final lenPtr = calloc<Uint64>();
    try {
      final dataPtr = loroDocExportAllUpdates(_docPointer, lenPtr);
      if (dataPtr == nullptr) {
        return [];
      }
      
      final len = lenPtr.value;
      final data = List<int>.generate(len, (i) => (dataPtr + i).value);
      loroBytesFree(dataPtr);
      return data;
    } finally {
      calloc.free(lenPtr);
    }
  }

  /// 导入更新
  /// 
  /// 从其他设备导入更新，用于同步文档。
  /// 
  /// 参数：
  /// - [data]：包含更新数据的字节列表
  /// 
  /// 示例：
  /// ```dart
  /// // 从其他设备接收updates
  /// doc.import(updates);
  /// ```
  void import(List<int> data) {
    _checkDisposed();
    final len = data.length;
    if (len == 0) {
      return;
    }
    
    final dataPtr = calloc<Uint8>(len);
    try {
      for (var i = 0; i < len; i++) {
        (dataPtr + i).value = data[i];
      }
      
      final status = loroDocImport(_docPointer, dataPtr, len);
      _checkStatus(status, '导入更新失败');
    } finally {
      calloc.free(dataPtr);
    }
  }

  /// 设置PeerID
  /// 
  /// PeerID用于标识不同的设备或用户。每个文档实例应该有唯一的PeerID。
  /// 
  /// 参数：
  /// - [peerId]：要设置的PeerID
  /// 
  /// 示例：
  /// ```dart
  /// doc.setPeerId(12345);
  /// ```
  void setPeerId(int peerId) {
    _checkDisposed();
    final status = loroDocSetPeerId(_docPointer, peerId);
    _checkStatus(status, '设置PeerID失败');
  }

  /// 获取PeerID
  /// 
  /// 返回：
  /// - 当前文档的PeerID
  /// 
  /// 示例：
  /// ```dart
  /// final peerId = doc.getPeerId();
  /// print('当前PeerID: $peerId');
  /// ```
  int getPeerId() {
    _checkDisposed();
    return loroDocGetPeerId(_docPointer);
  }

  /// 释放文档资源
  /// 
  /// 必须在不再使用文档时调用此方法，否则会导致内存泄漏。
  /// 
  /// 示例：
  /// ```dart
  /// final doc = LoroDoc();
  /// // 使用文档...
  /// doc.dispose();
  /// ```
  void dispose() {
    if (!_isDisposed) {
      loroDocFree(_docPointer);
      _isDisposed = true;
    }
  }

  /// 检查是否已释放资源
  void _checkDisposed() {
    if (_isDisposed) {
      throw LoroDisposeException(message: '文档已释放，无法操作');
    }
  }

  /// 检查FFI调用状态
  void _checkStatus(int status, String errorMessage) {
    if (status != LoroStatus.ok.value) {
      if (status == LoroStatus.nullPtr.value) {
        throw LoroException(
          message: '$errorMessage: 空指针错误',
          code: status,
        );
      } else if (status == LoroStatus.error.value) {
        throw LoroException(
          message: errorMessage,
          code: status,
        );
      } else {
        throw LoroException(
          message: '$errorMessage: 未知错误',
          code: status,
        );
      }
    }
  }
  
  /// 自动释放资源
  void finalize() {
    dispose();
  }
}
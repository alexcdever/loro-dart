import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'bindings.dart';
import 'loro_exception.dart';

/// Loro文档Dart包装类
/// 
/// 这个类提供了对Rust Loro库的面向对象封装，用于管理CRDT文档。
/// Loro是一个高性能、无冲突复制数据类型（CRDT）库，用于构建协作应用。
/// 
/// 主要功能包括：
/// - 文档管理（创建、打开、保存、关闭）
/// - 文本操作（插入、删除、更新）
/// - CRDT同步（导入、导出更新）
/// - 事务管理
/// - PeerID管理
/// - Map和List容器操作
/// 
/// 示例用法：
/// ```dart
/// // 创建新文档
/// final doc = LoroDoc();
/// 
/// // 插入文本
/// doc.insertText("Hello, Loro!", 0);
/// doc.commit();
/// 
/// // 获取文本
/// final text = doc.getText();
/// print(text); // 输出: Hello, Loro!
/// 
/// // 使用异步API
/// await doc.insertTextAsync("Async ", 0);
/// await doc.commitAsync();
/// 
/// // 导出更新
/// final updates = await doc.exportAllUpdatesAsync();
/// 
/// // 释放资源
/// doc.dispose();
/// ```
/// 
/// 注意：使用完文档后，建议调用[dispose]方法释放资源。
/// 为了防止内存泄漏，类内部已经添加了Finalizer自动管理资源，但仍建议手动释放。
/// 
/// 支持的平台：
/// - Android
/// - iOS
/// - Windows
/// - macOS
/// - Linux
class LoroDoc {
  /// 原生文档指针
  final LoroDocPointer _docPointer;
  
  /// 是否已释放资源
  bool _isDisposed = false;
  
  /// Finalizer，用于自动释放资源
  static final Finalizer<LoroDocPointer> _finalizer = Finalizer((pointer) {
    loroDocFree(pointer);
  });

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
    // 附加Finalizer，确保资源被释放
    _finalizer.attach(this, _docPointer);
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
    // 附加Finalizer，确保资源被释放
    _finalizer.attach(this, _docPointer);
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
  
  /// 异步插入文本到文档
  /// 
  /// 参数：
  /// - [text]：要插入的文本内容
  /// - [position]：插入位置的索引
  /// 
  /// 示例：
  /// ```dart
  /// await doc.insertTextAsync("Hello", 0);
  /// await doc.insertTextAsync(" World", 5);
  /// ```
  Future<void> insertTextAsync(String text, int position) async {
    return Future(() {
      insertText(text, position);
    });
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
  
  /// 异步从文档中删除文本
  /// 
  /// 参数：
  /// - [start]：删除起始位置的索引
  /// - [length]：要删除的文本长度
  /// 
  /// 示例：
  /// ```dart
  /// await doc.deleteTextAsync(5, 6); // 删除从索引5开始的6个字符
  /// ```
  Future<void> deleteTextAsync(int start, int length) async {
    return Future(() {
      deleteText(start, length);
    });
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
  
  /// 异步提交当前事务
  /// 
  /// 事务提交后，所有的操作才会被持久化并触发事件通知。
  /// 
  /// 示例：
  /// ```dart
  /// await doc.insertTextAsync("Hello", 0);
  /// await doc.commitAsync();
  /// ```
  Future<void> commitAsync() async {
    return Future(() {
      commit();
    });
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
    // 使用更高效的内存分配方式
    final lenPtr = malloc<Uint64>();
    try {
      final dataPtr = loroDocExportAllUpdates(_docPointer, lenPtr);
      if (dataPtr == nullptr) {
        return [];
      }
      
      final len = lenPtr.value;
      // 使用更高效的方式将指针转换为List<int>
      final data = List<int>.from(
        Iterable.generate(len, (i) => dataPtr[i]),
        growable: false,
      );
      loroBytesFree(dataPtr);
      return data;
    } finally {
      malloc.free(lenPtr);
    }
  }
  
  /// 异步导出所有更新
  /// 
  /// 导出文档的所有更新，可以用于同步到其他设备。
  /// 
  /// 返回：
  /// - 包含所有更新的字节列表
  /// 
  /// 示例：
  /// ```dart
  /// final updates = await doc.exportAllUpdatesAsync();
  /// // 将updates发送到其他设备
  /// ```
  Future<List<int>> exportAllUpdatesAsync() async {
    return Future(() {
      return exportAllUpdates();
    });
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
    
    // 使用更高效的内存分配方式
    final dataPtr = malloc<Uint8>(len);
    try {
      // 使用更高效的方式将List<int>复制到指针
      for (var i = 0; i < len; i++) {
        dataPtr[i] = data[i];
      }
      
      final status = loroDocImport(_docPointer, dataPtr, len);
      _checkStatus(status, '导入更新失败');
    } finally {
      malloc.free(dataPtr);
    }
  }
  
  /// 异步导入更新
  /// 
  /// 从其他设备导入更新，用于同步文档。
  /// 
  /// 参数：
  /// - [data]：包含更新数据的字节列表
  /// 
  /// 示例：
  /// ```dart
  /// // 从其他设备接收updates
  /// await doc.importAsync(updates);
  /// ```
  Future<void> importAsync(List<int> data) async {
    return Future(() {
      import(data);
    });
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
      // 分离Finalizer，防止重复释放
      _finalizer.detach(this);
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
      String detailedMessage = errorMessage;
      
      if (status == LoroStatus.nullPtr.value) {
        detailedMessage = '$errorMessage: 空指针错误\n原因: 文档指针已释放或无效\n解决方案: 请确保文档未被释放，或重新创建文档';
      } else if (status == LoroStatus.error.value) {
        detailedMessage = '$errorMessage: 操作失败\n原因: 可能是参数无效或内部错误\n解决方案: 请检查参数是否合法，或尝试重新操作';
      } else {
        detailedMessage = '$errorMessage: 未知错误\n原因: 发生了未预期的错误\n解决方案: 请检查操作是否合法，或联系开发者';
      }
      
      throw LoroException(
        message: detailedMessage,
        code: status,
        cause: status == LoroStatus.nullPtr.value ? '空指针错误' : status == LoroStatus.error.value ? '操作失败' : '未知错误',
      );
    }
  }
  
  /// 设置Map中的键值对
  /// 
  /// 参数：
  /// - [key]：要设置的键
  /// - [value]：要设置的值
  /// 
  /// 示例：
  /// ```dart
  /// doc.mapInsert("key1", "value1");
  /// ```
  void mapInsert(String key, String value) {
    _checkDisposed();
    final keyUtf8 = key.toNativeUtf8();
    final valueUtf8 = value.toNativeUtf8();
    try {
      final status = loroDocMapInsert(_docPointer, keyUtf8, valueUtf8);
      _checkStatus(status, '设置Map键值对失败');
    } finally {
      malloc.free(keyUtf8);
      malloc.free(valueUtf8);
    }
  }

  /// 设置Map中的键值对（兼容旧API）
  /// 
  /// 参数：
  /// - [key]：要设置的键
  /// - [value]：要设置的值
  /// 
  /// 示例：
  /// ```dart
  /// doc.mapSet("key1", "value1");
  /// ```
  void mapSet(String key, String value) {
    mapInsert(key, value);
  }

  /// 获取Map中的值
  /// 
  /// 参数：
  /// - [key]：要获取的键
  /// 
  /// 返回：
  /// - 对应的键值，如果键不存在则返回null
  /// 
  /// 示例：
  /// ```dart
  /// final value = doc.mapGet("key1");
  /// ```
  String? mapGet(String key) {
    _checkDisposed();
    final keyUtf8 = key.toNativeUtf8();
    try {
      final valuePointer = loroDocMapGet(_docPointer, keyUtf8);
      if (valuePointer == nullptr) {
        return null;
      }
      
      try {
        return valuePointer.toDartString();
      } finally {
        loroStringFree(valuePointer);
      }
    } finally {
      malloc.free(keyUtf8);
    }
  }

  /// 删除Map中的键值对
  /// 
  /// 参数：
  /// - [key]：要删除的键
  /// 
  /// 示例：
  /// ```dart
  /// doc.mapDelete("key1");
  /// ```
  void mapDelete(String key) {
    _checkDisposed();
    final keyUtf8 = key.toNativeUtf8();
    try {
      final status = loroDocMapDelete(_docPointer, keyUtf8);
      _checkStatus(status, '删除Map键值对失败');
    } finally {
      malloc.free(keyUtf8);
    }
  }

  /// 获取Map的大小
  /// 
  /// 返回：
  /// - Map中的键值对数量
  /// 
  /// 示例：
  /// ```dart
  /// final size = doc.mapSize();
  /// ```
  int mapSize() {
    _checkDisposed();
    return loroDocMapSize(_docPointer);
  }

  /// 向List末尾添加元素
  /// 
  /// 参数：
  /// - [value]：要添加的元素值
  /// 
  /// 示例：
  /// ```dart
  /// doc.listPush("item1");
  /// ```
  void listPush(String value) {
    _checkDisposed();
    final valueUtf8 = value.toNativeUtf8();
    try {
      final status = loroDocListPush(_docPointer, valueUtf8);
      _checkStatus(status, '向List添加元素失败');
    } finally {
      malloc.free(valueUtf8);
    }
  }

  /// 获取List中的元素
  /// 
  /// 参数：
  /// - [index]：要获取的元素索引
  /// 
  /// 返回：
  /// - 对应索引的元素值，如果索引越界则返回null
  /// 
  /// 示例：
  /// ```dart
  /// final item = doc.listGet(0);
  /// ```
  String? listGet(int index) {
    _checkDisposed();
    final valuePointer = loroDocListGet(_docPointer, index);
    if (valuePointer == nullptr) {
      return null;
    }
    
    try {
      return valuePointer.toDartString();
    } finally {
      loroStringFree(valuePointer);
    }
  }

  /// 删除List中的元素
  /// 
  /// 参数：
  /// - [pos]：要删除的起始位置索引
  /// - [len]：要删除的元素数量
  /// 
  /// 示例：
  /// ```dart
  /// doc.listDelete(0, 1); // 删除从索引0开始的1个元素
  /// ```
  void listDelete(int pos, int len) {
    _checkDisposed();
    final status = loroDocListDelete(_docPointer, pos, len);
    _checkStatus(status, '删除List元素失败');
  }

  /// 删除List中的单个元素（兼容旧API）
  /// 
  /// 参数：
  /// - [index]：要删除的元素索引
  /// 
  /// 示例：
  /// ```dart
  /// doc.listDeleteSingle(0);
  /// ```
  void listDeleteSingle(int index) {
    listDelete(index, 1);
  }

  /// 获取List的大小
  /// 
  /// 返回：
  /// - List中的元素数量
  /// 
  /// 示例：
  /// ```dart
  /// final size = doc.listSize();
  /// ```
  int listSize() {
    _checkDisposed();
    return loroDocListSize(_docPointer);
  }

  /// 在指定位置插入元素到List
  /// 
  /// 参数：
  /// - [index]：插入位置索引
  /// - [value]：要插入的元素值
  /// 
  /// 示例：
  /// ```dart
  /// doc.listInsert(0, "item0");
  /// ```
  void listInsert(int index, String value) {
    _checkDisposed();
    final valueUtf8 = value.toNativeUtf8();
    try {
      final status = loroDocListInsert(_docPointer, index, valueUtf8);
      _checkStatus(status, '插入List元素失败');
    } finally {
      malloc.free(valueUtf8);
    }
  }

  /// 自动释放资源
  void finalize() {
    dispose();
  }
}
import 'dart:ffi';
import 'dart:io' show Platform;

/// 多平台动态库加载器
/// 根据不同平台加载对应的本地库文件
DynamicLibrary _loadLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libloro_ffi.so');
  } else if (Platform.isIOS) {
    return DynamicLibrary.process();
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('loro_ffi.dll');
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('libloro_ffi.dylib');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('libloro_ffi.so');
  }
  throw UnsupportedError('不支持的平台: ${Platform.operatingSystem}');
}

/// 全局动态库实例
/// 用于所有FFI函数的查找和调用
final DynamicLibrary loroFFILib = _loadLibrary();
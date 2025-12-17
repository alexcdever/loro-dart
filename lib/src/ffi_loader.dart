import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

/// 加载原生 loro_dart 库。
///
/// 该函数处理平台特定的库加载：
/// - Android: libloro_dart.so
/// - iOS: loro_dart.framework
/// - Windows: loro_dart.dll
/// - Linux: libloro_dart.so
/// - macOS: libloro_dart.dylib
ffi.DynamicLibrary loadLoroLibrary() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('libloro_dart.so');
  } else if (Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('loro_dart.dll');
  } else if (Platform.isLinux) {
    return ffi.DynamicLibrary.open('libloro_dart.so');
  } else if (Platform.isMacOS) {
    return ffi.DynamicLibrary.open('libloro_dart.dylib');
  } else {
    throw UnsupportedError('平台 ${Platform.operatingSystem} 不支持');
  }
}

/// 初始化 Loro 库。
///
/// 在使用任何 Loro 功能之前，应调用此函数。
/// 如果初始化成功，返回 true。
bool initializeLoro() {
  try {
    loadLoroLibrary();
    // 执行必要的初始化操作
    return true;
  } catch (e) {
    // 这只是一个调试打印，不是生产代码
    // ignore: avoid_print
    print('初始化 Loro 库失败: $e');
    return false;
  }
}

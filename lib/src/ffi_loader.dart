import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

/// Loads the native loro_dart library.
///
/// This function handles platform-specific library loading for:
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
    throw UnsupportedError(
        'Platform ${Platform.operatingSystem} is not supported');
  }
}

/// Initialize the Loro library.
///
/// This should be called before using any Loro functionality.
/// Returns true if initialization was successful.
bool initializeLoro() {
  try {
    final lib = loadLoroLibrary();
    // Perform any necessary initialization
    return true;
  } catch (e) {
    print('Failed to initialize Loro library: $e');
    return false;
  }
}

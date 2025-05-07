# Flutter Loro FFI 跨平台开发文档

---

## **1. 环境准备**
### **1.1 工具链安装**
```bash
# Rust 工具链
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add \
  aarch64-linux-android armv7-linux-androideabi \
  aarch64-apple-ios x86_64-apple-ios \
  x86_64-pc-windows-msvc x86_64-apple-darwin x86_64-unknown-linux-gnu

# Flutter 开发环境
flutter doctor --android-licenses
brew install --HEAD libimobiledevice

# 交叉编译工具
cargo install cargo-ndk cargo-lipo cbindgen
```

---

## **2. 项目结构**
```bash
flutter_loro_ffi/
├── android/                 # Android平台库
│   └── src/main/jniLibs/
│       ├── arm64-v8a/librust_loro.so
│       ├── armeabi-v7a/librust_loro.so
├── ios/                     # iOS平台库
│   ├── Frameworks/librust_loro.a
│   └── LoroFFI.podspec
├── windows/                 # Windows平台库
│   └── loro_ffi_plugin.dll
├── macos/                   # macOS平台库
│   └── Frameworks/libloro_ffi.dylib
├── linux/                   # Linux平台库
│   └── libloro_ffi.so
├── lib/
│   ├── loro_ffi.dart        # 主入口
│   └── src/
│       ├── ffi_android.dart # Android加载逻辑
│       ├── ffi_ios.dart     # iOS加载逻辑
│       ├── ffi_windows.dart # Windows加载逻辑
│       ├── ffi_macos.dart   # macOS加载逻辑
│       ├── ffi_linux.dart   # Linux加载逻辑
│       └── bindings.dart    # FFI绑定
├── native/
│   └── rust/                # Rust核心代码
│       ├── src/
│       │   └── lib.rs
│       └── Cargo.toml
├── build.rs                 # 构建脚本
└── pubspec.yaml
```

---

## **3. Rust核心层开发**
### **3.1 Cargo.toml 配置**
```toml
[lib]
name = "loro_ffi"
crate-type = ["cdylib", "staticlib"]  # 同时生成动态/静态库

[dependencies]
cbindgen = "0.26.0"  # 头文件生成
```

### **3.2 示例接口实现**
```rust
// native/rust/src/lib.rs
#[no_mangle]
pub extern "C" fn loro_doc_new() -> *mut LoroDoc {
    Box::into_raw(Box::new(LoroDoc::new()))
}

#[no_mangle]
pub extern "C" fn loro_doc_insert_text(
    doc: *mut LoroDoc, 
    text: *const c_char
) {
    let c_str = unsafe { CStr::from_ptr(text) };
    let text = c_str.to_str().unwrap();
    unsafe { &mut *doc }.insert_text(text);
}
```

---

## **4. 跨平台编译**
### **4.1 Android编译**
```bash
cd native/rust
cargo ndk \
  -t armeabi-v7a \
  -t arm64-v8a \
  -t x86_64-linux-android \
  build --release

# 输出到Flutter项目
cp target/aarch64-linux-android/release/libloro_ffi.so \
  ../android/src/main/jniLibs/arm64-v8a/
```

### **4.2 iOS编译**
```bash
cargo lipo --release --targets \
  aarch64-apple-ios \
  x86_64-apple-ios

# 生成通用二进制
lipo -create \
  -output ios/Frameworks/libloro_ffi.a \
  target/universal/release/libloro_ffi.a
```

### **4.3 Windows编译**
```bash
cd native/rust
cargo build --release --target x86_64-pc-windows-msvc

# 输出到Flutter项目
mkdir -p ../windows/
cp target/x86_64-pc-windows-msvc/release/loro_ffi.dll \
  ../windows/loro_ffi_plugin.dll
```

### **4.4 macOS编译**
```bash
cd native/rust
cargo build --release --target x86_64-apple-darwin

# 输出到Flutter项目
mkdir -p ../macos/Frameworks/
cp target/x86_64-apple-darwin/release/libloro_ffi.dylib \
  ../macos/Frameworks/
```

### **4.5 Linux编译**
```bash
cd native/rust
cargo build --release --target x86_64-unknown-linux-gnu

# 输出到Flutter项目
mkdir -p ../linux/
cp target/x86_64-unknown-linux-gnu/release/libloro_ffi.so \
  ../linux/
```

---

## **5. Dart FFI绑定层**
### **5.1 头文件生成**
```bash
cbindgen --config cbindgen.toml -o include/loro_ffi.h
```

### **5.2 多平台加载实现**
```dart
// lib/src/ffi_loader.dart
DynamicLibrary _loadLibrary() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open('libloro_ffi.so');
  } else if (Platform.isIOS) {
    return DynamicLibrary.process();
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('loro_ffi_plugin.dll');
  } else if (Platform.isMacOS) {
    return DynamicLibrary.open('libloro_ffi.dylib');
  } else if (Platform.isLinux) {
    return DynamicLibrary.open('libloro_ffi.so');
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

final _dylib = _loadLibrary();

// lib/src/bindings.dart
typedef LoroDocNewFunc = Pointer Function();
typedef LoroDocInsertTextFunc = Void Function(
  Pointer<Utf8>,
  Pointer<Utf8>
);

final loroDocNew = _dylib
  .lookup<NativeFunction<LoroDocNewFunc>>('loro_doc_new')
  .asFunction();
```

---

## **6. Flutter插件集成**
### **6.1 pubspec.yaml配置**
```yaml
flutter:
  plugin:
    platforms:
      android:
        package: com.example.loro_ffi
        pluginClass: LoroFFIPlugin
      ios:
        pluginClass: LoroFFIPlugin
      windows:
        pluginClass: LoroFFIPlugin
      macos:
        pluginClass: LoroFFIPlugin
      linux:
        pluginClass: LoroFFIPlugin
  assets:
    - android/src/main/jniLibs/arm64-v8a/libloro_ffi.so
    - android/src/main/jniLibs/armeabi-v7a/libloro_ffi.so
    - ios/Frameworks/libloro_ffi.a
    - windows/loro_ffi_plugin.dll
    - macos/Frameworks/libloro_ffi.dylib
    - linux/libloro_ffi.so
```

### **6.2 iOS Podspec配置**
```ruby
Pod::Spec.new do |s|
  s.name             = 'LoroFFI'
  s.version          = '0.1.0'
  s.summary          = 'Loro FFI bindings'
  s.source           = { :path => '.' }
  s.vendored_libraries = 'Frameworks/libloro_ffi.a'
  s.pod_target_xcconfig = {
    'OTHER_LDFLAGS' => '-force_load $(PODS_ROOT)/LoroFFI/Frameworks/libloro_ffi.a'
  }
end
```

### **6.3 Windows平台配置**
```cmake
# windows/CMakeLists.txt
set(LibraryName "loro_ffi_plugin")

add_library(${LibraryName} SHARED
  "${PLUGIN_NAME}_plugin.cpp"
)
target_link_libraries(${LibraryName} PRIVATE flutter flutter_wrapper_plugin)

# 确保DLL被正确加载
install(TARGETS ${LibraryName} DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")
```

### **6.4 macOS平台配置**
```swift
// macos/Classes/LoroFFIPlugin.swift
import FlutterMacOS

public class LoroFFIPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // 注册插件
  }
}
```

### **6.5 Linux平台配置**
```cmake
# linux/CMakeLists.txt
set(LibraryName "loro_ffi_plugin")

add_library(${LibraryName} SHARED
  "${PLUGIN_NAME}_plugin.cc"
)
target_link_libraries(${LibraryName} PRIVATE flutter)
target_link_libraries(${LibraryName} PRIVATE PkgConfig::GTK)

# 确保SO被正确加载
install(TARGETS ${LibraryName} DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")
```

---

## **7. 开发者使用示例**
```dart
import 'package:flutter_loro_ffi/flutter_loro_ffi.dart';

void main() {
  final doc = LoroDoc.new();
  doc.insertText("Hello Multi-Platform!");
  print(doc.getText());
}
```

---

## **8. 测试与验证**
### **8.1 Android测试**
```bash
flutter build apk --target-platform \
  android-arm,android-arm64,android-x64
adb install build/app/outputs/apk/release/app-release.apk
```

### **8.2 iOS测试**
```bash
flutter build ios --simulator
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
```

### **8.3 Windows测试**
```bash
flutter build windows
start build\windows\runner\Release\app.exe
```

### **8.4 macOS测试**
```bash
flutter build macos
open build/macos/Build/Products/Release/app.app
```

### **8.5 Linux测试**
```bash
flutter build linux
./build/linux/x64/release/bundle/app
```

---

## **9. 发布流程**
### **9.1 版本管理**
```bash
# 更新所有平台二进制
./scripts/build_all.sh

# 版本号遵循语义化版本
git tag -a v1.2.3 -m "Support text sync"
```

### **9.2 Pub发布**
```bash
flutter pub publish --dry-run
flutter pub publish
```

---

## **10. 常见问题处理**
### **iOS符号丢失**
```ruby
# Podfile添加
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEAD_CODE_STRIPPING'] = 'NO'
      config.build_settings['OTHER_LDFLAGS'] = '-all_load'
    end
  end
end
```

### **Android UnsatisfiedLinkError**
```gradle
// android/build.gradle
android {
    packagingOptions {
        pickFirst '**/libloro_ffi.so'
    }
}
```

---

通过此文档，开发者可完整实现从Rust核心代码到跨平台Flutter插件的全流程开发，最终用户只需通过`pub.dev`安装即可享受无缝跨平台体验。
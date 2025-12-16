# 快速开始指南 (Quick Start Guide)

本指南将帮助你快速将loro-ffi编译成动态库并封装成Flutter插件。

## 项目结构

```
loro-dart/
├── rust/                   # Rust包装器项目(配置为cdylib)
│   ├── src/
│   │   ├── lib.rs         # 重新导出loro-ffi
│   │   └── loro_dart.udl  # UniFFI接口定义
│   ├── Cargo.toml         # 配置了cdylib
│   └── build.rs           # 构建脚本
├── loro-ffi/              # Git子模块(官方loro-ffi,不要修改)
├── lib/                   # Dart库代码
├── tool/                  # 构建和生成工具
│   ├── build.dart         # 多平台构建脚本
│   └── generate_bindings.dart # 生成Dart绑定
├── example/               # 示例应用
└── pubspec.yaml          # Flutter插件配置
```

## 步骤1: 安装依赖

### 必需工具
```bash
# 1. Flutter SDK (3.0+)
flutter --version

# 2. Rust工具链
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup update stable

# 3. Dart依赖
flutter pub get
```

### 安装Rust目标平台

```bash
# Android
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# iOS (仅macOS)
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim

# Windows
rustup target add x86_64-pc-windows-msvc

# Linux
rustup target add x86_64-unknown-linux-gnu

# macOS (仅macOS)
rustup target add x86_64-apple-darwin aarch64-apple-darwin
```

### 安装Android NDK (Android构建)
```bash
# 使用Android Studio的SDK Manager安装NDK
# 或下载: https://developer.android.com/ndk/downloads

# 设置环境变量
export ANDROID_NDK_HOME=/path/to/ndk
```

## 步骤2: 构建原生库

### 构建当前平台
```bash
dart run tool/build.dart
```

### 构建特定平台
```bash
# Android
dart run tool/build.dart --platform android

# iOS
dart run tool/build.dart --platform ios

# Windows
dart run tool/build.dart --platform windows

# Linux
dart run tool/build.dart --platform linux

# macOS
dart run tool/build.dart --platform macos

# 构建所有平台
dart run tool/build.dart --platform all
```

## 步骤3: 生成Dart绑定

```bash
# 安装uniffi-bindgen-dart(首次)
cargo install uniffi-bindgen-dart --git https://github.com/Uniffi-Dart/uniffi-dart

# 生成Dart绑定
dart run tool/generate_bindings.dart
```

**注意**: uniffi-dart目前处于实验阶段，如果遇到问题，可以考虑以下替代方案:
- 使用 [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- 手动编写FFI绑定(使用dart:ffi)

## 步骤4: 测试集成

```bash
# 运行测试
flutter test

# 运行示例应用
cd example
flutter run
```

## 步骤5: 准备发布

### 发布前检查清单

1. **代码质量**
   ```bash
   dart analyze
   dart format .
   flutter test
   ```

2. **更新版本信息**
   - 更新 `pubspec.yaml` 中的版本号
   - 更新 `CHANGELOG.md`

3. **验证包**
   ```bash
   dart pub publish --dry-run
   ```

4. **发布到pub.dev**
   ```bash
   dart pub publish
   ```

详细的发布检查清单请查看 [PUBLISHING.md](PUBLISHING.md)。

## 常见问题

### Q: uniffi-dart安装失败怎么办?

**A**: uniffi-dart是实验性项目，可能不稳定。替代方案:

1. **使用flutter_rust_bridge** (推荐):
   ```bash
   cargo install flutter_rust_bridge_codegen
   flutter pub add flutter_rust_bridge
   flutter pub add ffi
   ```

2. **手动编写FFI绑定**:
   - 使用 `dart:ffi` 直接调用C接口
   - 参考 [Flutter FFI文档](https://docs.flutter.dev/platform-integration/android/c-interop)

### Q: Android构建失败?

**A**: 检查以下几点:
- NDK已安装: `echo $ANDROID_NDK_HOME`
- 已添加Android目标: `rustup target list --installed`
- 设置cargo配置: 创建 `~/.cargo/config.toml`:
  ```toml
  [target.aarch64-linux-android]
  ar = "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar"
  linker = "$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang"
  ```

### Q: iOS构建失败?

**A**:
- 只能在macOS上构建iOS
- 安装Xcode Command Line Tools: `xcode-select --install`
- 检查iOS目标: `rustup target list --installed | grep ios`

### Q: 动态库找不到?

**A**: 检查库文件位置:
- Android: `android/src/main/jniLibs/*/libloro_dart_ffi.so`
- iOS: `ios/libloro_dart_ffi.a`或XCFramework
- Windows: `windows/loro_dart_ffi.dll`
- Linux: `linux/libloro_dart_ffi.so`
- macOS: `macos/libloro_dart_ffi.dylib`

### Q: 如何调试FFI问题?

**A**:
1. 启用详细日志:
   ```dart
   print(loadLoroLibrary().toString());
   ```

2. 检查符号导出:
   ```bash
   # Linux/macOS
   nm -D libloro_dart_ffi.so | grep loro

   # Windows
   dumpbin /EXPORTS loro_dart_ffi.dll
   ```

## 替代方案: 使用flutter_rust_bridge

如果uniffi-dart不稳定，可以使用flutter_rust_bridge:

1. **修改rust/Cargo.toml**:
   ```toml
   [dependencies]
   flutter_rust_bridge = "2"
   ```

2. **使用frb工具生成绑定**:
   ```bash
   flutter_rust_bridge_codegen \
     --rust-input rust/src/api.rs \
     --dart-output lib/src/bridge_generated.dart
   ```

3. **优点**:
   - 更成熟稳定
   - 更好的Dart类型映射
   - 活跃的社区支持

## 下一步

- 阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何贡献
- 查看 [example/](example/) 目录获取更多示例
- 访问 [loro.dev](https://loro.dev) 了解Loro CRDT

## 参考资源

- [Loro官方文档](https://loro.dev/docs)
- [UniFFI文档](https://mozilla.github.io/uniffi-rs/)
- [uniffi-dart仓库](https://github.com/Uniffi-Dart/uniffi-dart)
- [Flutter FFI教程](https://docs.flutter.dev/platform-integration/android/c-interop)
- [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)

---

如有问题，请在GitHub Issues中提问: https://github.com/alexcdever/loro-dart/issues

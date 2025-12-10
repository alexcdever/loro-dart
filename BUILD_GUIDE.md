# Loro Dart FFI 构建指南

本文档提供了为所有支持的平台构建Loro FFI库的详细步骤。

## 支持的平台

- ✅ Windows (x64)
- ✅ macOS (Intel 和 Apple Silicon)
- ✅ Linux (x64)
- ✅ Android (arm64-v8a, armeabi-v7a, x86_64, x86)
- ✅ iOS (arm64, x86_64)

## 环境要求

### 通用要求
- [Rust](https://www.rust-lang.org/tools/install) 1.70 或更高版本
- Cargo（Rust 包管理器）

### 平台特定要求

#### Windows
- Visual Studio 2019 或更高版本
- Windows 10 或更高版本

#### macOS
- Xcode 13 或更高版本
- macOS 12 或更高版本

#### Linux
- GCC 或 Clang
- Ubuntu 20.04 或更高版本（推荐）

#### Android
- Android NDK 25 或更高版本
- 设置 `ANDROID_NDK_ROOT` 环境变量

#### iOS
- Xcode 13 或更高版本
- macOS 12 或更高版本

## 构建步骤

### 1. 克隆仓库

```bash
git clone https://github.com/alexcdever/loro-dart.git
cd loro-dart
```

### 2. 初始化子模块

```bash
git submodule update --init --recursive
```

### 3. 构建所有平台

#### 在 macOS 或 Linux 上构建所有平台

```bash
# 运行构建脚本
bash build_all_platforms.sh
```

#### 在 Windows 上构建

```powershell
# 运行 PowerShell 脚本
.uild_all_platforms.ps1
```

> 注意：在 Windows 上仅构建 Windows 版本。其他平台需要在相应的操作系统上构建。

### 4. 手动构建特定平台

如果需要手动构建特定平台，可以使用以下命令：

#### Windows
```bash
cargo build --release --target x86_64-pc-windows-msvc
```

#### macOS
```bash
# Intel
cargo build --release --target x86_64-apple-darwin

# Apple Silicon
cargo build --release --target aarch64-apple-darwin

# 创建通用二进制文件
lipo -create -output libloro_ffi.dylib \
    target/x86_64-apple-darwin/release/libloro_ffi.dylib \
    target/aarch64-apple-darwin/release/libloro_ffi.dylib
```

#### Linux
```bash
cargo build --release --target x86_64-unknown-linux-gnu
```

#### Android
```bash
# 确保设置了 ANDROID_NDK_ROOT 环境变量

# arm64-v8a
cargo build --release --target aarch64-linux-android

# armeabi-v7a
cargo build --release --target armv7-linux-androideabi

# x86_64
cargo build --release --target x86_64-linux-android

# x86
cargo build --release --target i686-linux-android
```

#### iOS
```bash
# 设备 (arm64)
cargo build --release --target aarch64-apple-ios

# 模拟器 (x86_64)
cargo build --release --target x86_64-apple-ios

# 创建通用静态库
lipo -create -output libloro_ffi.a \
    target/aarch64-apple-ios/release/libloro_ffi.a \
    target/x86_64-apple-ios/release/libloro_ffi.a
```

## 构建输出

构建完成后，二进制文件将输出到以下位置：

| 平台 | 输出位置 |
|------|----------|
| Windows | `loro_ffi.dll` |
| macOS | `libloro_ffi.dylib` |
| Linux | `libloro_ffi.so` |
| Android | `android/src/main/jniLibs/` |
| iOS | `ios/Frameworks/libloro_ffi.a` |

## Flutter 插件集成

### Android
1. 构建完成后，Android 库将自动放置在 `android/src/main/jniLibs/` 目录中
2. Flutter 构建系统会自动包含这些库

### iOS
1. 构建完成后，iOS 静态库将自动放置在 `ios/Frameworks/` 目录中
2. 确保 `LoroFFI.podspec` 中的 `vendored_libraries` 配置正确

### macOS
1. 构建完成后，macOS 库将自动放置在 `macos/Libraries/` 目录中
2. 需要在 `macos/CMakeLists.txt` 中配置链接

### Linux
1. 构建完成后，Linux 库将自动放置在 `linux/Libraries/` 目录中
2. 需要在 `linux/CMakeLists.txt` 中配置链接

## 测试

### 运行 Dart 测试

```bash
dart test
```

### 运行 Flutter 集成测试

```bash
cd example
flutter test
```

### 运行示例应用

```bash
cd example
flutter run
```

## 发布到 pub.dev

在发布之前，确保：

1. 所有必要的二进制文件都已构建并放置在正确的位置
2. `pubspec.yaml` 中的版本号已更新
3. `CHANGELOG.md` 已更新
4. 运行了 `dart pub publish --dry-run` 检查是否有任何问题

```bash
dart pub publish --dry-run
# 确认没有问题后，运行：
dart pub publish
```

## 故障排除

### Android 构建失败
- 确保设置了 `ANDROID_NDK_ROOT` 环境变量
- 确保安装了正确版本的 Android NDK
- 检查 Rust 目标是否已正确安装

### iOS 构建失败
- 确保安装了 Xcode 和 iOS SDK
- 确保在 macOS 系统上构建
- 检查 Rust 目标是否已正确安装

### macOS 构建失败
- 确保安装了 Xcode 和 Command Line Tools
- 确保在 macOS 系统上构建
- 检查 Rust 目标是否已正确安装

### Linux 构建失败
- 确保安装了 GCC 或 Clang
- 检查 Rust 目标是否已正确安装

## 支持

如果遇到构建问题，请查看：
- [Rust 交叉编译文档](https://rust-lang.github.io/rustup/cross-compilation.html)
- [UniFFI 文档](https://mozilla.github.io/uniffi-rs/)
- 提交 GitHub Issue

## 许可证

MIT

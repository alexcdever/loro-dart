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
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.0.0 或更高版本
- [Dart SDK](https://dart.dev/get-dart) 2.17.0 或更高版本

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
- Android NDK 29 或更高版本
- Android SDK with Platform Tools

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

项目包含 `loro-ffi` 子模块，需要初始化：

```bash
git submodule update --init --recursive
```

### 3. 构建所有平台

项目提供了统一的构建脚本，可以在 Windows 上构建 Windows 和 Android 版本，在 Linux/macOS 上构建对应平台和 Android 版本。

#### 在 Windows 上构建

```powershell
# 运行 PowerShell 脚本
powershell -ExecutionPolicy Bypass -File build_platforms.ps1
```

#### 在 Linux 或 macOS 上构建

```bash
# 运行 Bash 脚本
bash build_all_platforms.sh
```

> 注意：某些平台可能需要在相应的操作系统上构建。例如，iOS 版本需要在 macOS 上构建。

### 4. 构建特定平台

如果需要构建特定平台，可以使用 `scripts/` 目录下的平台特定脚本：

#### Windows
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1
```

#### Linux
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_linux.ps1
```

#### Android
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_android.ps1
```

#### Dart 库（获取依赖和分析）
```powershell
powershell -ExecutionPolicy Bypass -File scripts/build_dart.ps1
```

### 5. 手动构建特定平台

如果需要手动构建特定平台，可以使用以下命令：

#### Windows
```bash
cd loro-ffi
cargo build --release --target x86_64-pc-windows-msvc
```

#### macOS
```bash
cd loro-ffi

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
cd loro-ffi
cargo build --release --target x86_64-unknown-linux-gnu
```

#### Android
```bash
cd loro-ffi

# 确保设置了正确的 NDK 路径
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
cd loro-ffi

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

构建完成后，二进制文件将输出到 `release/` 目录下：

| 平台 | 输出位置 |
|------|----------|
| Windows | `release/windows/loro_ffi.dll` |
| Linux | `release/linux/libloro_ffi.so` |
| Android (arm64-v8a) | `release/android/arm64-v8a/libloro_ffi.so` |
| Android (armeabi-v7a) | `release/android/armeabi-v7a/libloro_ffi.so` |
| Android (x86_64) | `release/android/x86_64/libloro_ffi.so` |
| Android (x86) | `release/android/x86/libloro_ffi.so` |
| macOS | 需手动复制或在macOS上构建 |
| iOS | 需手动复制或在macOS上构建 |

## Flutter 插件集成

项目使用 Flutter FFI 插件架构，构建系统会自动处理库的集成：

1. 构建完成后，确保二进制文件位于 `release/` 目录下
2. Flutter 构建系统会根据平台自动选择合适的二进制文件
3. 如需自定义集成，可参考 Flutter FFI 文档

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

### 运行带覆盖率的测试

```bash
flutter test --coverage
```

### 运行基准测试

```bash
dart test/benchmark_test.dart
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

### Windows 构建失败
- 确保安装了 Visual Studio with C++ build tools
- 确保安装了 Rust 和 Cargo

### Android 构建失败
- 确保 Android NDK 已正确安装
- 检查 `scripts/build_android.ps1` 中的 NDK 路径是否正确
- 确保安装了对应 Android 目标的 Rust 工具链

### Linux 构建失败
- 确保安装了 GCC 或 Clang
- 确保安装了对应 Linux 目标的 Rust 工具链

### macOS 构建失败
- 确保安装了 Xcode 和 Command Line Tools
- 确保安装了对应 macOS 目标的 Rust 工具链

### iOS 构建失败
- 确保在 macOS 系统上构建
- 确保安装了 Xcode 和 iOS SDK
- 确保安装了对应 iOS 目标的 Rust 工具链

## 支持

如果遇到构建问题，请查看：
- [Rust 交叉编译文档](https://rust-lang.github.io/rustup/cross-compilation.html)
- [Flutter FFI 文档](https://docs.flutter.dev/development/platform-integration/c-interop)
- 提交 GitHub Issue

## 许可证

MIT
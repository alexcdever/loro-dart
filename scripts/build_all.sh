#!/bin/bash
# 跨平台编译脚本
# 用于自动化构建所有平台的二进制文件

set -e

echo "===== 开始构建 Loro FFI 跨平台库 ====="

# 当前目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
RUST_DIR="$ROOT_DIR/native/rust"

# 创建输出目录
mkdir -p "$ROOT_DIR/android/src/main/jniLibs/arm64-v8a"
mkdir -p "$ROOT_DIR/android/src/main/jniLibs/armeabi-v7a"
mkdir -p "$ROOT_DIR/android/src/main/jniLibs/x86_64"
mkdir -p "$ROOT_DIR/ios/Frameworks"
mkdir -p "$ROOT_DIR/windows"
mkdir -p "$ROOT_DIR/macos/Frameworks"
mkdir -p "$ROOT_DIR/linux"

echo "===== 生成 C 头文件 ====="
cd "$RUST_DIR"
cbindgen --config cbindgen.toml -o "$ROOT_DIR/include/loro_ffi.h"

echo "===== 构建 Android 库 ====="
cd "$RUST_DIR"
cargo ndk \
  -t armeabi-v7a \
  -t arm64-v8a \
  -t x86_64 \
  build --release

# 复制 Android 库文件
cp "$RUST_DIR/target/aarch64-linux-android/release/libloro_ffi.so" \
   "$ROOT_DIR/android/src/main/jniLibs/arm64-v8a/"
cp "$RUST_DIR/target/armv7-linux-androideabi/release/libloro_ffi.so" \
   "$ROOT_DIR/android/src/main/jniLibs/armeabi-v7a/"
cp "$RUST_DIR/target/x86_64-linux-android/release/libloro_ffi.so" \
   "$ROOT_DIR/android/src/main/jniLibs/x86_64/"

echo "===== 构建 iOS 库 ====="
cd "$RUST_DIR"
cargo lipo --release --targets \
  aarch64-apple-ios \
  x86_64-apple-ios

# 生成通用二进制
lipo -create \
  -output "$ROOT_DIR/ios/Frameworks/libloro_ffi.a" \
  "$RUST_DIR/target/aarch64-apple-ios/release/libloro_ffi.a" \
  "$RUST_DIR/target/x86_64-apple-ios/release/libloro_ffi.a"

echo "===== 构建 Windows 库 ====="
cd "$RUST_DIR"
cargo build --release --target x86_64-pc-windows-msvc

# 复制 Windows 库文件
cp "$RUST_DIR/target/x86_64-pc-windows-msvc/release/loro_ffi.dll" \
   "$ROOT_DIR/windows/loro_ffi_plugin.dll"

echo "===== 构建 macOS 库 ====="
cd "$RUST_DIR"
cargo build --release --target x86_64-apple-darwin

# 复制 macOS 库文件
cp "$RUST_DIR/target/x86_64-apple-darwin/release/libloro_ffi.dylib" \
   "$ROOT_DIR/macos/Frameworks/"

echo "===== 构建 Linux 库 ====="
cd "$RUST_DIR"
cargo build --release --target x86_64-unknown-linux-gnu

# 复制 Linux 库文件
cp "$RUST_DIR/target/x86_64-unknown-linux-gnu/release/libloro_ffi.so" \
   "$ROOT_DIR/linux/"

echo "===== 所有平台构建完成 ====="
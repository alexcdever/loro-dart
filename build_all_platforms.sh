#!/bin/bash

# 跨平台构建脚本，用于构建Loro FFI库的所有平台版本

set -e

echo "开始构建Loro FFI库的所有平台版本..."

# 确保在loro-ffi目录中执行
cd "$(dirname "$0")/loro-ffi"

echo "
=== 构建Windows版本 ==="
cargo build --release --target x86_64-pc-windows-msvc
cp target/x86_64-pc-windows-msvc/release/loro_ffi.dll ../loro_ffi.dll

echo "
=== 构建macOS版本 ==="
cargo build --release --target x86_64-apple-darwin
cargo build --release --target aarch64-apple-darwin
lipo -create -output ../libloro_ffi.dylib \
    target/x86_64-apple-darwin/release/libloro_ffi.dylib \
    target/aarch64-apple-darwin/release/libloro_ffi.dylib

# 为Flutter macOS插件准备
mkdir -p ../macos/Libraries
cp ../libloro_ffi.dylib ../macos/Libraries/

echo "
=== 构建Linux版本 ==="
cargo build --release --target x86_64-unknown-linux-gnu
cp target/x86_64-unknown-linux-gnu/release/libloro_ffi.so ../libloro_ffi.so

# 为Flutter Linux插件准备
mkdir -p ../linux/Libraries
cp ../libloro_ffi.so ../linux/Libraries/

echo "
=== 构建Android版本 ==="
# 确保已安装Android NDK
if [ -z "$ANDROID_NDK_ROOT" ]; then
    echo "错误: 未设置ANDROID_NDK_ROOT环境变量"
    exit 1
fi

# 配置NDK工具链
NDK_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/darwin-x86_64"

export AR_aarch64_linux_android="$NDK_TOOLCHAIN/bin/aarch64-linux-android-ar"
export CC_aarch64_linux_android="$NDK_TOOLCHAIN/bin/aarch64-linux-android21-clang"
export AR_armv7_linux_androideabi="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-ar"
export CC_armv7_linux_androideabi="$NDK_TOOLCHAIN/bin/armv7a-linux-androideabi21-clang"
export AR_x86_64_linux_android="$NDK_TOOLCHAIN/bin/x86_64-linux-android-ar"
export CC_x86_64_linux_android="$NDK_TOOLCHAIN/bin/x86_64-linux-android21-clang"
export AR_i686_linux_android="$NDK_TOOLCHAIN/bin/i686-linux-android-ar"
export CC_i686_linux_android="$NDK_TOOLCHAIN/bin/i686-linux-android21-clang"

# 构建各架构的Android库
for arch in aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android; do
    echo "构建Android $arch版本..."
    cargo build --release --target $arch
    mkdir -p ../android/src/main/jniLibs/$(echo $arch | sed -e 's/aarch64-linux-android/arm64-v8a/' -e 's/armv7-linux-androideabi/armeabi-v7a/' -e 's/x86_64-linux-android/x86_64/' -e 's/i686-linux-android/x86/')
    cp target/$arch/release/libloro_ffi.so ../android/src/main/jniLibs/$(echo $arch | sed -e 's/aarch64-linux-android/arm64-v8a/' -e 's/armv7-linux-androideabi/armeabi-v7a/' -e 's/x86_64-linux-android/x86_64/' -e 's/i686-linux-android/x86/')/
done

echo "
=== 构建iOS版本 ==="
# 确保已安装Xcode和iOS SDK
if ! command -v xcodebuild &> /dev/null; then
    echo "错误: 未安装Xcode"
    exit 1
fi

# 构建iOS静态库
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios

# 创建通用静态库
lipo -create -output ../ios/Frameworks/libloro_ffi.a \
    target/aarch64-apple-ios/release/libloro_ffi.a \
    target/x86_64-apple-ios/release/libloro_ffi.a

echo "
=== 构建完成 ==="
echo "所有平台版本已构建完成！"
echo "输出位置:"
echo "- Windows: ../loro_ffi.dll"
echo "- macOS: ../libloro_ffi.dylib"
echo "- Linux: ../libloro_ffi.so"
echo "- Android: ../android/src/main/jniLibs/"
echo "- iOS: ../ios/Frameworks/libloro_ffi.a"

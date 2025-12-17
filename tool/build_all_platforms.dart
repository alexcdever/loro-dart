#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  stdout.write('🔧 开始构建所有平台的动态库...\n\n');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 1. 生成 frb 绑定代码
  await generateFrbBindings(projectRoot, rustDir);

  // 2. 构建所有平台的动态库
  stdout.write('\n🔨 开始构建所有平台的动态库...\n\n');

  // 构建顺序：先构建Android，再构建iOS，最后构建各平台本地库
  await buildAndroid(rustDir);
  await buildIOS(rustDir);
  await buildWindows(rustDir);
  await buildLinux(rustDir);
  await buildMacOS(rustDir);

  stdout.write('\n✅ 所有平台构建完成！\n');
}

/// 生成 flutter_rust_bridge 绑定
Future<void> generateFrbBindings(String projectRoot, String rustDir) async {
  stdout.write('📋 生成 flutter_rust_bridge 绑定...\n');
  final result = await Process.run(
    'dart',
    ['run', 'tool/generate_bindings_frb.dart'],
    workingDirectory: projectRoot,
  );

  stdout.write(result.stdout);
  if (result.stderr.isNotEmpty) {
    stderr.write(result.stderr);
  }

  if (result.exitCode != 0) {
    stderr.write('❌ 生成绑定失败\n');
    exit(1);
  }
  stdout.write('✅ 绑定生成成功！\n');
}

/// 构建 Android 动态库
Future<void> buildAndroid(String rustDir) async {
  stdout.write('\n📱 构建 Android 动态库...\n');

  // 检查当前平台是否支持 Android 构建
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 获取 NDK 路径
    final ndkPath = Platform.environment['ANDROID_NDK_ROOT'] ??
        (Platform.isWindows
            ? 'C:\\Users\\${Platform.environment['USERNAME']}\\AppData\\Local\\Android\\Sdk\\ndk'
            : Platform.isMacOS
                ? '${Platform.environment['HOME']}/Library/Android/sdk/ndk'
                : '/usr/local/lib/android/sdk/ndk');

    // 检查 NDK 路径是否存在
    final ndkDir = Directory(ndkPath);
    if (!ndkDir.existsSync()) {
      stdout.write('⚠️ NDK 路径不存在: $ndkPath，跳过 Android 构建...\n');
      return;
    }

    // 查找最新版本的 NDK
    final ndkVersions = ndkDir
        .listSync()
        .whereType<Directory>()
        .map((entity) => entity.path)
        .toList();

    if (ndkVersions.isEmpty) {
      stdout.write('⚠️ 在 $ndkPath 中未找到 NDK 版本，跳过 Android 构建...\n');
      return;
    }

    // 选择最新版本
    ndkVersions.sort();
    final latestNdkVersion = ndkVersions.last;
    final ndkRoot = Directory(latestNdkVersion);

    stdout.write('📌 使用 NDK: $ndkRoot\n');

    final targets = [
      'aarch64-linux-android',
      'armv7-linux-androideabi',
      'i686-linux-android',
      'x86_64-linux-android',
    ];

    final targetMap = {
      'aarch64-linux-android': 'arm64-v8a',
      'armv7-linux-androideabi': 'armeabi-v7a',
      'i686-linux-android': 'x86',
      'x86_64-linux-android': 'x86_64',
    };

    bool anySuccess = false;

    // 设置 NDK 路径环境变量
    final env = <String, String>{...Platform.environment};
    env['ANDROID_NDK_HOME'] = ndkRoot.path;

    for (final target in targets) {
      stdout.write('  构建 $target...\n');

      final result = await Process.run(
        'cargo',
        ['ndk', 'build', '--release', '--target', target],
        workingDirectory: rustDir,
        environment: env,
      );

      if (result.exitCode != 0) {
        stderr.write('❌ 构建 $target 失败，中止整个构建流程...\n');
        stderr.write('错误: ${result.stderr}\n');
        exit(1);
      }

      // 复制到 Android jniLibs 目录
      final outputDir = path.join(
        Directory.current.path,
        'android',
        'src',
        'main',
        'jniLibs',
        targetMap[target]!,
      );

      await Directory(outputDir).create(recursive: true);

      final libSource = path.join(
        rustDir,
        'target',
        target,
        'release',
        'libloro_dart.so',
      );

      final libDest = path.join(outputDir, 'libloro_dart.so');

      await File(libSource).copy(libDest);
      stdout.write('  ✓ 复制到 $libDest\n');
      anySuccess = true;
    }

    if (!anySuccess) {
      stderr.write('⚠️ 所有 Android 目标构建失败。请确保你已安装并配置了 Android NDK。\n');
    } else {
      stdout.write('✅ Android 动态库构建成功！\n');
    }
  } else {
    stdout.write('⚠️ 当前平台不支持 Android 构建，跳过...\n');
  }
}

/// 构建 iOS 动态库
Future<void> buildIOS(String rustDir) async {
  stdout.write('\n🍎 构建 iOS 动态库...\n');

  // 检查当前平台是否支持 iOS 构建
  if (Platform.isMacOS) {
    // Build for iOS device (arm64)
    stdout.write('  构建 iOS 设备 (arm64)...\n');
    var result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'aarch64-apple-ios'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 iOS 设备失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    // Build for iOS simulator (x86_64 and arm64)
    stdout.write('  构建 iOS 模拟器 (x86_64)...\n');
    result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'x86_64-apple-ios'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 iOS 模拟器 (x86_64) 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    stdout.write('  构建 iOS 模拟器 (arm64)...\n');
    result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'aarch64-apple-ios-sim'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 iOS 模拟器 (arm64) 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    // Create XCFramework
    stdout.write('  创建 XCFramework...\n');
    final outputDir = path.join(Directory.current.path, 'ios');
    await Directory(outputDir).create(recursive: true);

    stdout.write('✅ iOS 动态库构建成功！\n');
  } else {
    stdout.write('⚠️ 当前平台不支持 iOS 构建，跳过...\n');
  }
}

/// 构建 Windows 动态库
Future<void> buildWindows(String rustDir) async {
  stdout.write('\n🪟 构建 Windows 动态库...\n');

  if (Platform.isWindows) {
    final result = await Process.run(
      'cargo',
      ['build', '--release'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 Windows 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    final outputDir = path.join(Directory.current.path, 'windows');
    await Directory(outputDir).create(recursive: true);

    final libSource = path.join(
      rustDir,
      'target',
      'release',
      'loro_dart.dll',
    );

    final libDest = path.join(outputDir, 'loro_dart.dll');

    await File(libSource).copy(libDest);
    stdout.write('  ✓ 复制到 $libDest\n');
    stdout.write('✅ Windows 动态库构建成功！\n');
  } else {
    // 在非 Windows 平台上交叉编译 Windows 动态库
    stdout.write('  尝试交叉编译 Windows 动态库...\n');
    final result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'x86_64-pc-windows-gnu'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('⚠️ 交叉编译 Windows 失败，跳过...\n');
      stderr.write('错误: ${result.stderr}\n');
      return;
    }

    stdout.write('✅ Windows 动态库交叉编译成功！\n');
  }
}

/// 构建 Linux 动态库
Future<void> buildLinux(String rustDir) async {
  stdout.write('\n🐧 构建 Linux 动态库...\n');

  if (Platform.isLinux) {
    final result = await Process.run(
      'cargo',
      ['build', '--release'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 Linux 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    final outputDir = path.join(Directory.current.path, 'linux');
    await Directory(outputDir).create(recursive: true);

    final libSource = path.join(
      rustDir,
      'target',
      'release',
      'libloro_dart.so',
    );

    final libDest = path.join(outputDir, 'libloro_dart.so');

    await File(libSource).copy(libDest);
    stdout.write('  ✓ 复制到 $libDest\n');
    stdout.write('✅ Linux 动态库构建成功！\n');
  } else {
    // 在非 Linux 平台上交叉编译 Linux 动态库
    stdout.write('  尝试交叉编译 Linux 动态库...\n');
    final result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'x86_64-unknown-linux-gnu'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('⚠️ 交叉编译 Linux 失败，跳过...\n');
      stderr.write('错误: ${result.stderr}\n');
      return;
    }

    stdout.write('✅ Linux 动态库交叉编译成功！\n');
  }
}

/// 构建 macOS 动态库
Future<void> buildMacOS(String rustDir) async {
  stdout.write('\n🍎 构建 macOS 动态库...\n');

  if (Platform.isMacOS) {
    // Build for both x86_64 and arm64
    stdout.write('  构建 x86_64...\n');
    var result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'x86_64-apple-darwin'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 macOS x86_64 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    stdout.write('  构建 arm64...\n');
    result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'aarch64-apple-darwin'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('❌ 构建 macOS arm64 失败，中止整个构建流程...\n');
      stderr.write('错误: ${result.stderr}\n');
      exit(1);
    }

    // Create universal binary
    stdout.write('  创建通用二进制文件...\n');
    final outputDir = path.join(Directory.current.path, 'macos');
    await Directory(outputDir).create(recursive: true);

    final universalLib = path.join(outputDir, 'libloro_dart.dylib');

    result = await Process.run('lipo', [
      '-create',
      path.join(rustDir, 'target', 'x86_64-apple-darwin', 'release',
          'libloro_dart.dylib'),
      path.join(rustDir, 'target', 'aarch64-apple-darwin', 'release',
          'libloro_dart.dylib'),
      '-output',
      universalLib,
    ]);

    if (result.exitCode != 0) {
      stderr.write('⚠️ 创建通用二进制文件失败，跳过...\n');
      stderr.write('错误: ${result.stderr}\n');
      return;
    }

    stdout.write('  ✓ 在 $universalLib 创建了通用二进制文件\n');
    stdout.write('✅ macOS 动态库构建成功！\n');
  } else {
    // 在非 macOS 平台上交叉编译 macOS 动态库
    stdout.write('  尝试交叉编译 macOS 动态库...\n');
    final result = await Process.run(
      'cargo',
      ['build', '--release', '--target', 'x86_64-apple-darwin'],
      workingDirectory: rustDir,
    );

    if (result.exitCode != 0) {
      stderr.write('⚠️ 交叉编译 macOS 失败，跳过...\n');
      stderr.write('错误: ${result.stderr}\n');
      return;
    }

    stdout.write('✅ macOS 动态库交叉编译成功！\n');
  }
}

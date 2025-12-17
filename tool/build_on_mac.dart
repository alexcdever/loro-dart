#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('🔧 使用 flutter_rust_bridge 生成 Dart 绑定...\n');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 1. 生成 frb 绑定代码
  await generateFrbBindings(projectRoot, rustDir);

  // 2. 构建动态库
  print('\n🔨 开始构建动态库...\n');

  // macOS 上可以构建 Android、iOS 和 macOS
  await buildAndroid(rustDir);
  await buildIOS(rustDir);
  await buildMacOS(rustDir);

  print('\n✅ 所有构建完成！');
}

/// 生成 flutter_rust_bridge 绑定
Future<void> generateFrbBindings(String projectRoot, String rustDir) async {
  // 调用外部脚本生成绑定，确保生成逻辑的一致性
  final result = await Process.run(
    'dart',
    ['run', 'tool/generate_bindings_frb.dart'],
    workingDirectory: projectRoot,
  );

  // 输出结果
  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print(result.stderr);
  }

  if (result.exitCode != 0) {
    print('❌ 生成绑定失败');
    exit(1);
  }
}

/// 构建 Android 动态库
Future<void> buildAndroid(String rustDir) async {
  print('📱 构建 Android 动态库...');

  // 获取 NDK 路径
  final ndkPath = Platform.environment['ANDROID_NDK_ROOT'] ??
      Platform.environment['ANDROID_NDK_HOME'] ??
      '~/Library/Android/sdk/ndk';

  // 检查 NDK 路径是否存在
  final ndkDir = Directory(ndkPath);
  if (!ndkDir.existsSync()) {
    print('⚠️ NDK 路径不存在: $ndkPath');
    print('请设置 ANDROID_NDK_ROOT 或 ANDROID_NDK_HOME 环境变量到正确的 NDK 路径。');
    print('你可以通过 Android Studio SDK Manager 安装 NDK。');
    return;
  }

  // 查找最新版本的 NDK
  final ndkVersions = ndkDir
      .listSync()
      .where((entity) => entity is Directory)
      .map((entity) => entity.path)
      .toList();

  if (ndkVersions.isEmpty) {
    print('⚠️ 在 $ndkPath 中未找到 NDK 版本');
    return;
  }

  // 选择最新版本
  final latestNdkVersion = ndkVersions.last;
  final ndkRoot = Directory(latestNdkVersion);

  print('📌 使用 NDK: $ndkRoot');

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
    print('  构建 $target...');

    final result = await Process.run(
      'cargo',
      ['ndk', 'build', '--release', '--target', target],
      workingDirectory: rustDir,
      environment: env,
    );

    if (result.exitCode != 0) {
      print('⚠️ 构建 $target 失败，跳过...');
      print('错误: ${result.stderr}');
      continue;
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
    print('  ✓ 复制到 $libDest');
    anySuccess = true;
  }

  if (!anySuccess) {
    print('⚠️ 所有 Android 目标构建失败。请确保你已安装并配置了 Android NDK。');
    print('你可以通过 Android Studio SDK Manager 安装 NDK。');
  }
}

/// 构建 iOS 动态库
Future<void> buildIOS(String rustDir) async {
  print('🍎 构建 iOS 动态库...');

  // Build for iOS device (arm64)
  print('  构建 iOS 设备 (arm64)...');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 iOS 设备失败');
    print(result.stderr);
    exit(1);
  }

  // Build for iOS simulator (x86_64 and arm64)
  print('  构建 iOS 模拟器...');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 iOS 模拟器 (x86_64) 失败');
    print(result.stderr);
    exit(1);
  }

  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios-sim'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 iOS 模拟器 (arm64) 失败');
    print(result.stderr);
    exit(1);
  }

  // Create XCFramework
  print('  创建 XCFramework...');
  final outputDir = path.join(Directory.current.path, 'ios');
  await Directory(outputDir).create(recursive: true);

  // Create universal binary for simulator
  final simLibPath =
      path.join(rustDir, 'target', 'ios-sim-universal', 'release');
  await Directory(simLibPath).create(recursive: true);

  result = await Process.run('lipo', [
    '-create',
    path.join(
        rustDir, 'target', 'x86_64-apple-ios', 'release', 'libloro_dart.a'),
    path.join(rustDir, 'target', 'aarch64-apple-ios-sim', 'release',
        'libloro_dart.a'),
    '-output',
    path.join(simLibPath, 'libloro_dart.a'),
  ]);

  if (result.exitCode != 0) {
    print('⚠️ 创建模拟器通用二进制文件失败，跳过...');
  } else {
    print('  ✓ 创建了 iOS 通用库');
  }
}

/// 构建 macOS 动态库
Future<void> buildMacOS(String rustDir) async {
  print('🍎 构建 macOS 动态库...');

  // Build for both x86_64 and arm64
  print('  构建 x86_64...');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 macOS x86_64 失败');
    print(result.stderr);
    exit(1);
  }

  print('  构建 arm64...');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 macOS arm64 失败');
    print(result.stderr);
    exit(1);
  }

  // Create universal binary
  print('  创建通用二进制文件...');
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
    print('❌ 创建通用二进制文件失败');
    print(result.stderr);
    exit(1);
  }

  print('  ✓ 在 $universalLib 创建了通用二进制文件');
}

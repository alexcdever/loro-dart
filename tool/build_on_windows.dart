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

  // Windows 上可以构建 Android 和 Windows
  await buildAndroid(rustDir);
  await buildWindows(rustDir);

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
      'C:\\Users\\alexc\\AppData\\Local\\Android\\Sdk\\ndk';

  // 检查 NDK 路径是否存在
  final ndkDir = Directory(ndkPath);
  if (!ndkDir.existsSync()) {
    print('⚠️ NDK 路径不存在: $ndkPath');
    print('请设置 ANDROID_NDK_ROOT 环境变量到正确的 NDK 路径。');
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

/// 构建 Windows 动态库
Future<void> buildWindows(String rustDir) async {
  print('🪟 构建 Windows 动态库...');

  final result = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ 构建 Windows 失败');
    print(result.stderr);
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
  print('  ✓ 复制到 $libDest');
}

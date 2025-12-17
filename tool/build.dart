#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('platform',
        abbr: 'p',
        allowed: ['android', 'ios', 'windows', 'linux', 'macos', 'all'],
        defaultsTo: 'all',
        help: 'Target platform to build for');

  final results = parser.parse(arguments);
  final platform = results['platform'] as String;

  print('🔨 Building loro_dart for platform: $platform');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 只在当前平台上构建对应平台的目标，或者在明确指定平台时才构建
  final currentPlatform = Platform.operatingSystem;

  // Android 可以在所有平台上构建，因为我们已经安装了 Android 目标
  if (platform == 'all' || platform == 'android') {
    await buildAndroid(rustDir);
  }
  if (platform == 'ios') {
    print('⚠️ iOS 构建只能在 macOS 上进行，跳过...');
  }
  if ((platform == 'all' && currentPlatform == 'windows') ||
      platform == 'windows') {
    await buildWindows(rustDir);
  }
  if (platform == 'linux') {
    await buildLinux(rustDir);
  }
  if (platform == 'macos') {
    print('⚠️ macOS 构建只能在 macOS 上进行，跳过...');
  }

  print('✅ Build completed successfully!');
}

Future<void> buildAndroid(String rustDir) async {
  print('📱 Building for Android...');

  // 获取NDK路径
  final ndkPath = Platform.environment['ANDROID_NDK_ROOT'] ??
      'C:\\Users\\alexc\\AppData\\Local\\Android\\Sdk\\ndk';

  // 检查NDK路径是否存在
  final ndkDir = Directory(ndkPath);
  if (!ndkDir.existsSync()) {
    print('⚠️ NDK path not found: $ndkPath');
    print(
        'Please set ANDROID_NDK_ROOT environment variable to the correct NDK path.');
    print('You can install NDK via Android Studio SDK Manager.');
    return;
  }

  // 查找最新版本的NDK
  final ndkVersions = ndkDir
      .listSync()
      .where((entity) => entity is Directory)
      .map((entity) => entity.path)
      .toList();

  if (ndkVersions.isEmpty) {
    print('⚠️ No NDK versions found in $ndkPath');
    return;
  }

  // 选择最新版本
  final latestNdkVersion = ndkVersions.last;
  final ndkRoot = Directory(latestNdkVersion);

  print('📌 Using NDK at: $ndkRoot');

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

  // 设置NDK路径环境变量
  final env = <String, String>{...Platform.environment};
  env['ANDROID_NDK_HOME'] = ndkRoot.path;

  for (final target in targets) {
    print('  Building for $target...');

    final result = await Process.run(
      'cargo',
      ['ndk', 'build', '--release', '--target', target],
      workingDirectory: rustDir,
      environment: env,
    );

    if (result.exitCode != 0) {
      print('⚠️ Failed to build for $target, skipping...');
      print('Error: ${result.stderr}');
      continue;
    }

    // Copy to Android jniLibs directory
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
    print('  ✓ Copied to $libDest');
    anySuccess = true;
  }

  if (!anySuccess) {
    print(
        '⚠️ All Android targets failed to build. Please make sure you have Android NDK installed and configured.');
    print('You can install NDK via Android Studio SDK Manager.');
  }
}

Future<void> buildIOS(String rustDir) async {
  print('🍎 Building for iOS...');

  // Build for iOS device (arm64)
  print('  Building for iOS device (arm64)...');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for iOS device');
    print(result.stderr);
    exit(1);
  }

  // Build for iOS simulator (x86_64 and arm64)
  print('  Building for iOS simulator...');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for iOS simulator (x86_64)');
    print(result.stderr);
    exit(1);
  }

  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios-sim'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for iOS simulator (arm64)');
    print(result.stderr);
    exit(1);
  }

  // Create XCFramework
  print('  Creating XCFramework...');
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
    print('⚠️ Failed to create universal simulator binary, skipping...');
  } else {
    print('  ✓ Created iOS universal library');
  }
}

Future<void> buildWindows(String rustDir) async {
  print('🪟 Building for Windows...');

  final result = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for Windows');
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
  print('  ✓ Copied to $libDest');
}

Future<void> buildLinux(String rustDir) async {
  print('🐧 Building for Linux...');

  final result = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for Linux');
    print(result.stderr);
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
  print('  ✓ Copied to $libDest');
}

Future<void> buildMacOS(String rustDir) async {
  print('🍎 Building for macOS...');

  // Build for both x86_64 and arm64
  print('  Building for x86_64...');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for macOS x86_64');
    print(result.stderr);
    exit(1);
  }

  print('  Building for arm64...');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    print('❌ Failed to build for macOS arm64');
    print(result.stderr);
    exit(1);
  }

  // Create universal binary
  print('  Creating universal binary...');
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
    print('❌ Failed to create universal binary');
    print(result.stderr);
    exit(1);
  }

  print('  ✓ Created universal binary at $universalLib');
}

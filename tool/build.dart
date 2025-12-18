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

  stdout.write('🔨 Building loro_dart for platform: $platform\n');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 只在当前平台上构建对应平台的目标，或者在明确指定平台时才构建
  final currentPlatform = Platform.operatingSystem;

  // Android 可以在所有平台上构建，因为我们已经安装了 Android 目标
  if (platform == 'all' || platform == 'android') {
    await buildAndroid(rustDir);
  }
  if (platform == 'ios') {
    stdout.write('⚠️ iOS 构建只能在 macOS 上进行，跳过...\n');
  }
  if ((platform == 'all' && currentPlatform == 'windows') ||
      platform == 'windows') {
    await buildWindows(rustDir);
  }
  if (platform == 'linux') {
    await buildLinux(rustDir);
  }
  if (platform == 'macos') {
    stdout.write('⚠️ macOS 构建只能在 macOS 上进行，跳过...\n');
  }

  stdout.write('✅ Build completed successfully!\n');
}

Future<void> buildAndroid(String rustDir) async {
  stdout.write('📱 Building for Android...\n');

  // 获取NDK路径
  final ndkPath = Platform.environment['ANDROID_NDK_ROOT'] ??
      'C:\\Users\\alexc\\AppData\\Local\\Android\\Sdk\\ndk';

  // 检查NDK路径是否存在
  final ndkDir = Directory(ndkPath);
  if (!ndkDir.existsSync()) {
    stderr.write('⚠️ NDK path not found: $ndkPath\n');
    stderr.write(
        'Please set ANDROID_NDK_ROOT environment variable to the correct NDK path.\n');
    stderr.write('You can install NDK via Android Studio SDK Manager.\n');
    return;
  }

  // 查找最新版本的NDK
  final ndkVersions = ndkDir
      .listSync()
      .whereType<Directory>()
      .map((entity) => entity.path)
      .toList();

  if (ndkVersions.isEmpty) {
    stderr.write('⚠️ No NDK versions found in $ndkPath\n');
    return;
  }

  // 选择最新版本
  final latestNdkVersion = ndkVersions.last;
  final ndkRoot = Directory(latestNdkVersion);

  stdout.write('📌 Using NDK at: $ndkRoot\n');

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
    stdout.write('  Building for $target...\n');

    final result = await Process.run(
      'cargo',
      ['ndk', 'build', '--release', '--target', target],
      workingDirectory: rustDir,
      environment: env,
    );

    if (result.exitCode != 0) {
      stderr.write('⚠️ Failed to build for $target, skipping...\n');
      stderr.write('Error: ${result.stderr}\n');
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
    stdout.write('  ✓ Copied to $libDest\n');
    anySuccess = true;
  }

  if (!anySuccess) {
    stderr.write(
        '⚠️ All Android targets failed to build. Please make sure you have Android NDK installed and configured.\n');
    stderr.write('You can install NDK via Android Studio SDK Manager.\n');
  }
}

Future<void> buildIOS(String rustDir) async {
  stdout.write('🍎 Building for iOS...\n');

  // Build for iOS device (arm64)
  stdout.write('  Building for iOS device (arm64)...\n');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for iOS device\n');
    stderr.write(result.stderr);
    exit(1);
  }

  // Build for iOS simulator (x86_64 and arm64)
  stdout.write('  Building for iOS simulator...\n');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-ios'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for iOS simulator (x86_64)\n');
    stderr.write(result.stderr);
    exit(1);
  }

  stdout.write('  Building for iOS simulator (arm64)...\n');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-ios-sim'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for iOS simulator (arm64)\n');
    stderr.write(result.stderr);
    exit(1);
  }

  // Create XCFramework
  stdout.write('  Creating XCFramework...\n');
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
    stderr
        .write('⚠️ Failed to create universal simulator binary, skipping...\n');
  } else {
    stdout.write('  ✓ Created iOS universal library\n');
  }
}

Future<void> buildWindows(String rustDir) async {
  stdout.write('🪟 Building for Windows...\n');

  final result = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for Windows\n');
    stderr.write(result.stderr);
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
  stdout.write('  ✓ Copied to $libDest\n');
}

Future<void> buildLinux(String rustDir) async {
  stdout.write('🐧 Building for Linux...\n');

  final result = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for Linux\n');
    stderr.write(result.stderr);
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
  stdout.write('  ✓ Copied to $libDest\n');
}

Future<void> buildMacOS(String rustDir) async {
  stdout.write('🍎 Building for macOS...\n');

  // Build for both x86_64 and arm64
  stdout.write('  Building for x86_64...\n');
  var result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'x86_64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for macOS x86_64\n');
    stderr.write(result.stderr);
    exit(1);
  }

  stdout.write('  Building for arm64...\n');
  result = await Process.run(
    'cargo',
    ['build', '--release', '--target', 'aarch64-apple-darwin'],
    workingDirectory: rustDir,
  );

  if (result.exitCode != 0) {
    stderr.write('❌ Failed to build for macOS arm64\n');
    stderr.write(result.stderr);
    exit(1);
  }

  // Create universal binary
  stdout.write('  Creating universal binary...\n');
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
    stderr.write('❌ Failed to create universal binary\n');
    stderr.write(result.stderr);
    exit(1);
  }

  stdout.write('  ✓ Created universal binary at $universalLib\n');
}

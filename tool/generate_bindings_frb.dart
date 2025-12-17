#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

/// 使用 flutter_rust_bridge 生成 Dart 绑定
///
/// 这个脚本会：
/// 1. 检查 flutter_rust_bridge_codegen 是否安装
/// 2. 生成 Dart 绑定代码
/// 3. 生成 Rust 绑定代码

void main() async {
  print('🔧 使用 flutter_rust_bridge 生成 Dart 绑定...\n');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 检查 flutter_rust_bridge_codegen 是否安装
  print('📦 检查 flutter_rust_bridge_codegen...');
  final checkResult =
      await Process.run('flutter_rust_bridge_codegen', ['--version']);

  if (checkResult.exitCode != 0) {
    print('❌ flutter_rust_bridge_codegen 未安装\n');
    print('请运行以下命令安装：');
    print('  cargo install flutter_rust_bridge_codegen\n');
    print('或者访问：https://cjycode.com/flutter_rust_bridge/quickstart');
    exit(1);
  }

  print('✅ flutter_rust_bridge_codegen 已安装\n');

  // 生成绑定
  print('🔨 生成 Dart 和 Rust 绑定代码...\n');

  final generateResult = await Process.run(
    'flutter_rust_bridge_codegen',
    [
      'generate',
      '--rust-input',
      'crate::api',
      '--rust-root',
      rustDir,
      '--dart-output',
      path.join(projectRoot, 'lib', 'src'),
      '--c-output',
      path.join(projectRoot, 'lib', 'src', 'bridge_generated.h'),
    ],
    workingDirectory: projectRoot,
  );

  print(generateResult.stdout);

  if (generateResult.exitCode != 0) {
    print('❌ 生成绑定失败');
    print(generateResult.stderr);
    exit(1);
  }

  print('\n✅ Dart 绑定生成成功！');
  print('\n生成的文件：');
  print('  - lib/src/bridge_generated.dart');
  print('  - lib/src/bridge_definitions.dart');
  print('\n下一步：');
  print('  1. 运行: dart run tool/build.dart');
  print('  2. 运行: flutter test');
}

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
  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // 检查 flutter_rust_bridge_codegen 是否安装
  final checkResult = await Process.run(
    'flutter_rust_bridge_codegen',
    ['--version'],
    workingDirectory: projectRoot,
  );

  if (checkResult.exitCode != 0) {
    stderr.write('flutter_rust_bridge_codegen 未安装，正在自动安装...\n');
    final installResult = await Process.run(
      'cargo',
      ['install', 'flutter_rust_bridge_codegen'],
      workingDirectory: projectRoot,
    );

    if (installResult.exitCode != 0) {
      stderr.write('安装 flutter_rust_bridge_codegen 失败\n');
      stderr.write(installResult.stderr);
      stderr.write('请手动运行以下命令安装：\n');
      stderr.write('  cargo install flutter_rust_bridge_codegen\n');
      stderr.write('或者访问：https://cjycode.com/flutter_rust_bridge/quickstart\n');
      exit(1);
    }
    stderr.write('flutter_rust_bridge_codegen 安装成功！\n');
  }

  // 生成绑定
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

  stdout.write(generateResult.stdout);

  if (generateResult.exitCode != 0) {
    stderr.write('生成绑定失败\n');
    stderr.write(generateResult.stderr);
    exit(1);
  }
}

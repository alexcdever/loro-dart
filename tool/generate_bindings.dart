#!/usr/bin/env dart

import 'dart:io';
import 'package:path/path.dart' as path;

void main() async {
  print('🔧 Generating Dart bindings from UniFFI...');

  final projectRoot = Directory.current.path;
  final rustDir = path.join(projectRoot, 'rust');

  // First, ensure the Rust library is built
  print('Building Rust library...');
  final buildResult = await Process.run(
    'cargo',
    ['build', '--release'],
    workingDirectory: rustDir,
  );

  if (buildResult.exitCode != 0) {
    print('❌ Failed to build Rust library');
    print(buildResult.stderr);
    exit(1);
  }

  print('✅ Rust library built successfully');

  // Check if uniffi-bindgen-dart is installed
  print('Checking for uniffi-bindgen-dart...');
  final checkResult = await Process.run('cargo', ['install', '--list']);

  if (!checkResult.stdout.toString().contains('uniffi-bindgen-dart')) {
    print('📦 Installing uniffi-bindgen-dart...');
    final installResult = await Process.run(
      'cargo',
      ['install', 'uniffi-bindgen-dart', '--git', 'https://github.com/Uniffi-Dart/uniffi-dart'],
    );

    if (installResult.exitCode != 0) {
      print('❌ Failed to install uniffi-bindgen-dart');
      print(installResult.stderr);
      print('');
      print('Please install it manually:');
      print('  cargo install uniffi-bindgen-dart --git https://github.com/Uniffi-Dart/uniffi-dart');
      exit(1);
    }
  }

  print('✅ uniffi-bindgen-dart is available');

  // Generate Dart bindings
  print('Generating Dart bindings...');

  final udlFile = path.join(rustDir, 'src', 'loro_dart.udl');
  final outputDir = path.join(projectRoot, 'lib', 'src', 'generated');

  await Directory(outputDir).create(recursive: true);

  final generateResult = await Process.run(
    'uniffi-bindgen-dart',
    [
      udlFile,
      '--out-dir',
      outputDir,
    ],
    workingDirectory: rustDir,
  );

  if (generateResult.exitCode != 0) {
    print('❌ Failed to generate Dart bindings');
    print(generateResult.stderr);
    print('');
    print('Note: uniffi-dart is experimental. You may need to:');
    print('  1. Check that the UDL file is valid');
    print('  2. Ensure all dependencies are installed');
    print('  3. Try building with the latest uniffi-dart version');
    exit(1);
  }

  print('✅ Dart bindings generated successfully at $outputDir');
  print('');
  print('Next steps:');
  print('  1. Review the generated bindings in $outputDir');
  print('  2. Create wrapper classes in lib/src/');
  print('  3. Export public API from lib/loro_dart.dart');
}

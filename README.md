# Loro Dart

[![pub package](https://img.shields.io/pub/v/loro_dart.svg)](https://pub.dev/packages/loro_dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Dart bindings for [Loro](https://loro.dev) - A high-performance CRDT framework for building local-first collaborative applications.

**Built with [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)** for seamless Rust-Dart integration.

## ✨ Features

- 🚀 **High Performance**: Built directly on Loro core with efficient FFI
- 🔄 **Real-time Collaboration**: Powered by state-of-the-art CRDTs
- 📱 **Cross-platform**: Works on Android, iOS, Windows, Linux, and macOS
- 🎯 **Type-safe**: Full Dart type safety with automatic bindings
- 🔌 **Easy Integration**: Simple Flutter plugin architecture
- 🛠️ **Rich API**: Text, List, Map, Tree, Counter containers

## 🏗️ Architecture

```
Flutter App (Dart)
       ↓ flutter_rust_bridge (automatic bindings)
Rust Wrapper (simplified API)
       ↓ direct dependency
Loro Core (official library)
```

**Why this approach?**
- ✅ Direct access to latest Loro features
- ✅ Type-safe automatic code generation
- ✅ Better performance (no intermediate layer)
- ✅ Easy to maintain and update

## 📦 Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  loro_dart: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

```dart
import 'package:loro_dart/loro_dart.dart';

void main() async {
  // Create a new Loro document
  final doc = LoroDoc.new();

  // Work with text
  final text = doc.getText('text');
  await text.insert(0, 'Hello, Loro!');
  print(await text.toString());

  // Work with maps
  final map = doc.getMap('user');
  await map.insertString('name', 'Alice');
  await map.insertString('email', 'alice@example.com');

  // Work with lists
  final list = doc.getList('todos');
  await list.insertString(0, 'Buy milk');
  await list.insertString(1, 'Walk dog');

  // Commit changes
  await doc.commit();

  // Export document
  final snapshot = await doc.exportSnapshot();

  // Import in another document
  final doc2 = LoroDoc.new();
  await doc2.import(snapshot);

  print(await doc2.toJson());
}
```

## 📚 Documentation

### Containers

Loro provides several container types:

- **Text** - Collaborative text editing with rich formatting
- **List** - Ordered collection of values
- **Map** - Key-value storage
- **Tree** - Hierarchical data structure
- **Counter** - Increment/decrement operations

### Example: Collaborative Text Editing

```dart
final doc1 = LoroDoc.new();
final doc2 = LoroDoc.new();

// User 1 types
final text1 = doc1.getText('doc');
await text1.insert(0, 'Hello');

// Export and sync to User 2
final update = await doc1.exportSnapshot();
await doc2.import(update);

// User 2 types
final text2 = doc2.getText('doc');
await text2.insert(5, ' World');

// Sync back to User 1
final update2 = await doc2.exportSnapshot();
await doc1.import(update2);

// Both documents now have "Hello World"
print(await text1.toString()); // "Hello World"
```

## 🔨 Building from Source

### Prerequisites

- Rust toolchain (stable)
- Flutter SDK 3.0+
- flutter_rust_bridge_codegen

### Build Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/alexcdever/loro-dart
   cd loro-dart
   ```

2. **Install flutter_rust_bridge_codegen**
   ```bash
   cargo install flutter_rust_bridge_codegen
   ```

3. **Generate Dart bindings**
   ```bash
   dart run tool/generate_bindings_frb.dart
   ```

4. **Build native libraries**
   ```bash
   # For current platform
   dart run tool/build.dart

   # For specific platforms
   dart run tool/build.dart --platform android
   dart run tool/build.dart --platform ios
   ```

5. **Run tests**
   ```bash
   flutter test
   ```

For detailed build instructions, see [CORRECT_APPROACH.md](CORRECT_APPROACH.md).

## 🎯 Platform Setup

### Android

No additional setup required. Native libraries are automatically bundled.

### iOS

No additional setup required. Native libraries are automatically bundled.

### Windows/Linux/macOS

Native libraries are automatically bundled with your application.

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details.

## 📖 API Reference

For complete API documentation, visit [pub.dev/documentation/loro_dart](https://pub.dev/documentation/loro_dart/latest/).

## 🔗 Links

- [Official Loro Website](https://loro.dev)
- [Loro GitHub Repository](https://github.com/loro-dev/loro)
- [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
- [Package on pub.dev](https://pub.dev/packages/loro_dart)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Loro](https://github.com/loro-dev/loro) - The amazing CRDT framework
- [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge) - For making Rust-Dart FFI seamless
- The Rust and Flutter communities

## 📞 Support

If you have questions or need help:

- 📖 [Read the documentation](https://loro.dev/docs)
- 🐛 [Report issues](https://github.com/alexcdever/loro-dart/issues)
- 💬 [Join discussions](https://github.com/alexcdever/loro-dart/discussions)

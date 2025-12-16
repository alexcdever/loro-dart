import 'package:flutter/material.dart';
import 'package:loro_dart/loro_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loro Dart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Loro Dart Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initializeLoro();
  }

  Future<void> _initializeLoro() async {
    setState(() {
      _status = 'Loading Loro library...';
    });

    try {
      // 初始化 flutter_rust_bridge
      await RustLib.init();

      // 创建一个测试文档，验证库是否正常工作
      final doc = await LoroDoc.newInstance();
      final peerId = await doc.peerId();

      setState(() {
        _status = '✅ Loro library loaded successfully!\n\n'
            'Library information:\n'
            '- Peer ID: $peerId\n'
            '- Status: Ready to use\n\n'
            'Example functionality:\n'
            '1. Create and manage documents\n'
            '2. Text operations (insert, delete)\n'
            '3. List operations\n'
            '4. Map operations\n'
            '5. Export/Import data';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e\n\n'
            'Please make sure to:\n'
            '1. Build the native library: cd rust && cargo build --release\n'
            '2. Generate Dart bindings: dart run tool/generate_bindings_frb.dart';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.code,
                size: 64,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Loro CRDT for Dart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeLoro,
                child: const Text('Retry Initialization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

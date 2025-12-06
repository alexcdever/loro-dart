import 'package:flutter/material.dart';
import 'package:flutter_loro_ffi/loro_ffi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loro FFI 示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Loro FFI 示例'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 创建Loro文档实例
  final LoroDoc _loroDoc = LoroDoc();
  final TextEditingController _textController = TextEditingController();
  String _docContent = '';

  @override
  void initState() {
    super.initState();
    // 初始化时更新文档内容显示
    _updateDocContent();
  }

  @override
  void dispose() {
    // 释放资源
    _loroDoc.dispose();
    _textController.dispose();
    super.dispose();
  }

  // 更新文档内容显示
  void _updateDocContent() {
    setState(() {
      _docContent = _loroDoc.getText();
    });
  }

  // 插入文本到文档
  void _insertText() {
    if (_textController.text.isNotEmpty) {
      // 在文档末尾插入文本
      _loroDoc.insertText(_textController.text, _docContent.length);
      _textController.clear();
      _updateDocContent();
    }
  }

  // 提交事务
  void _commit() {
    _loroDoc.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('事务已提交')),
    );
  }

  // 演示同步功能
  void _demoSync() {
    // 导出当前文档的所有更新
    final updates = _loroDoc.exportAllUpdates();
    
    // 创建一个新文档并导入更新
    final newDoc = LoroDoc();
    newDoc.import(updates);
    
    // 比较两个文档的内容
    final newContent = newDoc.getText();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('同步演示完成，新文档内容: $newContent')),
    );
    
    newDoc.dispose();
  }

  // 演示PeerID管理
  void _demoPeerId() {
    final currentPeerId = _loroDoc.getPeerId();
    final newPeerId = currentPeerId + 1;
    _loroDoc.setPeerId(newPeerId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PeerID已从 $currentPeerId 更改为 $newPeerId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 文本输入框
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '输入要添加的文本',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 按钮行
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _insertText,
                    child: const Text('添加到文档'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _commit,
                    child: const Text('提交事务'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _demoSync,
                    child: const Text('演示同步'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _demoPeerId,
                    child: const Text('演示PeerID'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 文档内容标题
            const Text(
              '文档内容:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 文档内容显示
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: Text(_docContent.isEmpty ? '文档为空' : _docContent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
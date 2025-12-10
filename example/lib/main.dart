import 'package:flutter/material.dart';
import 'package:loro_dart/loro_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loro FFI 实时同步示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Loro FFI 实时同步示例'),
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
  // 创建两个独立的Loro文档实例
  final LoroDoc _loroDoc1 = LoroDoc();
  final LoroDoc _loroDoc2 = LoroDoc();
  
  // 两个文本控制器，分别用于两个实例
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();
  
  // 两个文档的内容
  String _docContent1 = '';
  String _docContent2 = '';
  
  // 同步开关状态
  bool _autoSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    // 初始化时设置不同的PeerID
    _loroDoc1.setPeerId(1);
    _loroDoc2.setPeerId(2);
    
    // 初始化时更新文档内容显示
    _updateDocContent1();
    _updateDocContent2();
  }

  @override
  void dispose() {
    // 释放资源
    _loroDoc1.dispose();
    _loroDoc2.dispose();
    _textController1.dispose();
    _textController2.dispose();
    super.dispose();
  }

  // 更新文档1的内容显示
  void _updateDocContent1() {
    setState(() {
      _docContent1 = _loroDoc1.getText();
    });
  }
  
  // 更新文档2的内容显示
  void _updateDocContent2() {
    setState(() {
      _docContent2 = _loroDoc2.getText();
    });
  }

  // 实现两个实例之间的单向同步
  // [forceSync] 参数用于控制是否绕过自动同步开关
  void _syncInstances(LoroDoc sourceDoc, LoroDoc targetDoc, {bool forceSync = false}) {
    if (!_autoSyncEnabled && !forceSync) return;
    
    // 导出源文档的更新
    final updates = sourceDoc.exportAllUpdates();
    
    // 导入到目标文档
    targetDoc.import(updates);
  }
  
  // 双向同步函数
  // [forceSync] 参数用于控制是否绕过自动同步开关
  void _biDirectionalSync(LoroDoc doc1, LoroDoc doc2, {bool forceSync = false}) {
    _syncInstances(doc1, doc2, forceSync: forceSync);
    _syncInstances(doc2, doc1, forceSync: forceSync);
  }

  // 向文档1插入文本
  void _insertText1() {
    if (_textController1.text.isNotEmpty) {
      // 在文档末尾插入文本
      _loroDoc1.insertText(_textController1.text, _docContent1.length);
      _textController1.clear();
      _updateDocContent1();
      
      // 双向同步 - 遵循自动同步开关设置
      _biDirectionalSync(_loroDoc1, _loroDoc2);
      _updateDocContent2();
    }
  }
  
  // 向文档2插入文本
  void _insertText2() {
    if (_textController2.text.isNotEmpty) {
      // 在文档末尾插入文本
      _loroDoc2.insertText(_textController2.text, _docContent2.length);
      _textController2.clear();
      _updateDocContent2();
      
      // 双向同步 - 遵循自动同步开关设置
      _biDirectionalSync(_loroDoc2, _loroDoc1);
      _updateDocContent1();
    }
  }

  // 提交文档1的事务
  void _commit1() {
    _loroDoc1.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文档1事务已提交')),
    );
  }
  
  // 提交文档2的事务
  void _commit2() {
    _loroDoc2.commit();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文档2事务已提交')),
    );
  }
  
  // 切换自动同步开关
  void _toggleAutoSync() {
    setState(() {
      _autoSyncEnabled = !_autoSyncEnabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_autoSyncEnabled ? '自动同步已开启' : '自动同步已关闭')),
    );
  }
  
  // 手动同步两个文档
  void _manualSync() {
    // 双向同步 - 强制同步，绕过自动同步开关设置
    _biDirectionalSync(_loroDoc1, _loroDoc2, forceSync: true);
    
    // 更新UI
    _updateDocContent1();
    _updateDocContent2();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('手动同步完成')),
    );
  }

  // 重置两个文档 - 注意：由于Dart的final限制，我们不能重新分配文档实例
  // 这里我们使用清空内容的方式模拟重置
  void _resetDocs() {
    // 清空两个文档的内容
    // 注意：实际应用中可能需要更复杂的重置逻辑
    _textController1.clear();
    _textController2.clear();
    
    setState(() {
      // 重置内容显示
      _docContent1 = '';
      _docContent2 = '';
    });
    
    // 重新创建文档实例的替代方案：
    // 1. 释放旧实例
    _loroDoc1.dispose();
    _loroDoc2.dispose();
    
    // 2. 在StatefulWidget的state中，我们无法重新分配final变量
    // 因此，我们需要重新创建整个State对象
    // 这里我们使用Navigator重新加载页面来实现
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: widget.title)),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文档已重置')),
    );
  }

  // 单个实例的UI组件
  Widget _buildInstancePanel(
    String title,
    String content,
    TextEditingController controller,
    VoidCallback onInsert,
    VoidCallback onCommit,
    int peerId
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 面板标题和PeerID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text('PeerID: $peerId'),
                  backgroundColor: Color.fromARGB(51, (Colors.blue.r * 255.0).round().clamp(0, 255), (Colors.blue.g * 255.0).round().clamp(0, 255), (Colors.blue.b * 255.0).round().clamp(0, 255)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 文本输入框
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '输入要添加的文本',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            
            // 按钮行
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onInsert,
                    child: const Text('添加到文档'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCommit,
                    child: const Text('提交事务'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 文档内容标题
            const Text(
              '文档内容:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // 文档内容显示
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                  color: Color.fromARGB(13, (Colors.grey.r * 255.0).round().clamp(0, 255), (Colors.grey.g * 255.0).round().clamp(0, 255), (Colors.grey.b * 255.0).round().clamp(0, 255)),
                ),
                child: SingleChildScrollView(
                  child: Text(content.isEmpty ? '文档为空' : content),
                ),
              ),
            ),
          ],
        ),
      ),
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
            // 顶部控制按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleAutoSync,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _autoSyncEnabled ? Colors.green : Colors.grey,
                    ),
                    child: Text(_autoSyncEnabled ? '关闭自动同步' : '开启自动同步'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _manualSync,
                    child: const Text('手动同步'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetDocs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('重置文档'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 两个实例的面板
            Expanded(
              child: Row(
                children: [
                  // 第一个实例面板
                  _buildInstancePanel(
                    '实例 1',
                    _docContent1,
                    _textController1,
                    _insertText1,
                    _commit1,
                    _loroDoc1.getPeerId()
                  ),
                  
                  // 第二个实例面板
                  _buildInstancePanel(
                    '实例 2',
                    _docContent2,
                    _textController2,
                    _insertText2,
                    _commit2,
                    _loroDoc2.getPeerId()
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
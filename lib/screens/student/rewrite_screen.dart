import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class RewriteScreen extends StatefulWidget {
  final TextRecordModel record;
  const RewriteScreen({super.key, required this.record});

  @override
  State<RewriteScreen> createState() => _RewriteScreenState();
}

class _RewriteScreenState extends State<RewriteScreen> {
  final _newPrompt = TextEditingController();
  final _humanText = TextEditingController();
  bool _isPromptMode = true;
  bool _loading = false;
  List<RewriteModel> _rewrites = [];

  @override
  void initState() {
    super.initState();
    _loadRewrites();
  }

  Future<void> _loadRewrites() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getRewrites(widget.record.id);
      setState(() => _rewrites = (data['rewrites'] as List).map((j) => RewriteModel.fromJson(j)).toList());
    } catch (_) {}
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      if (_isPromptMode) {
        if (_newPrompt.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入新Prompt'), backgroundColor: Colors.orange));
          setState(() => _loading = false);
          return;
        }
        await auth.api.rewrite(widget.record.id, type: 'prompt_only', newPrompt: _newPrompt.text.trim());
      } else {
        if (_humanText.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入改写文本'), backgroundColor: Colors.orange));
          setState(() => _loading = false);
          return;
        }
        await auth.api.rewrite(widget.record.id, type: 'human_rewrite', humanText: _humanText.text.trim());
      }
      _newPrompt.clear(); _humanText.clear();
      _loadRewrites();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('改写提交成功'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    return Scaffold(
      appBar: AppBar(title: const Text('改写与再评估'), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x144F46E5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1F4F46E5))),
              child: const Text('步骤五', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
            ),
          ]),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('原始文本', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 4),
                Text(r.originalText ?? '', maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF475569))),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('当前AI评分: '),
                  Text('${r.aiTotal ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  const Text(' / 17'),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Prompt改写优化')),
              ButtonSegment(value: false, label: Text('人工改写优化')),
            ],
            selected: {_isPromptMode},
            onSelectionChanged: (v) => setState(() => _isPromptMode = v.first),
          ),
          const SizedBox(height: 16),
          if (_isPromptMode) ...[
            const Text('新Prompt', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _newPrompt, maxLines: 4, decoration: const InputDecoration(hintText: '根据课程所学，编写更优质的Prompt指令...', contentPadding: EdgeInsets.all(16))),
          ] else ...[
            const Text('您的改写文本', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _humanText, maxLines: 8, decoration: const InputDecoration(hintText: '根据所学课程知识，手动改写优化后的文本...', contentPadding: EdgeInsets.all(16))),
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('提交改写并评估 →'))),
          if (_rewrites.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('历史改写记录', style: TextStyle(fontWeight: FontWeight.w600)),
            ..._rewrites.map((rw) => Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                title: Text(rw.rewriteType == 'prompt_only' ? 'Prompt改写' : '人工改写'),
                subtitle: rw.rewriteType == 'prompt_only' ? Text('评分: ${rw.oldPromptScore?.toInt() ?? 0} → ${rw.newPromptScore?.toInt() ?? 0}') : null,
              ),
            )),
          ],
        ]),
      ),
    );
  }

  @override
  void dispose() { _newPrompt.dispose(); _humanText.dispose(); super.dispose(); }
}

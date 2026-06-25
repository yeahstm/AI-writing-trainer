import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class OptimizeScreen extends StatefulWidget {
  const OptimizeScreen({super.key});
  @override
  State<OptimizeScreen> createState() => _OptimizeScreenState();
}

class _OptimizeScreenState extends State<OptimizeScreen> {
  final _text = TextEditingController();
  final _prompt = TextEditingController();
  bool _loading = false;

  final _quickPrompts = [
    '请将文本学术化，提升用词的准确性和正式程度，确保符合学术规范。',
    '请检查文本的逻辑结构，优化段落衔接，确保论证链条完整清晰。',
    '请精简文本，在保持核心内容的前提下缩减至800字以内。',
    '请丰富文本的文献支撑，增强论证的说服力和学术深度。',
  ];

  Future<void> _optimize() async {
    if (_text.text.trim().isEmpty || _prompt.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写文本和Prompt'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.optimize(_text.text.trim(), _prompt.text.trim());
      if (!mounted) return;
      final record = TextRecordModel.fromJson(data['record']);
      if (data['content_evaluation'] != null) {
        record.contentEvaluation = ContentEvalModel.fromJson(data['content_evaluation']);
      }
      Navigator.pushNamed(context, '/prompt_eval', arguments: {'record': record});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文本优化工作台'), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x144F46E5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1F4F46E5))),
              child: const Text('步骤一', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('文本优化工作台', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          const Text('输入您的原始文本和优化指令，AI将严格遵循您的Prompt完成专业级文本优化。', style: TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          TextField(
            controller: _text, maxLines: 8,
            decoration: const InputDecoration(
              hintText: '在此粘贴您需要优化的学术文本...',
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _prompt, maxLines: 4,
            decoration: const InputDecoration(
              hintText: '例：请将方法论部分提升至学术期刊水准，使用专业术语和正式语态...',
              contentPadding: EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _quickPrompts.map((p) => ActionChip(
              label: Text(p.length > 15 ? '${p.substring(0, 15)}...' : p, style: const TextStyle(fontSize: 12)),
              onPressed: () => _prompt.text = p,
            )).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: _loading ? null : _optimize,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('开始AI优化 →'),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _text.dispose(); _prompt.dispose();
    super.dispose();
  }
}

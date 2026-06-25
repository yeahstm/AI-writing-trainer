import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class ScoringScreen extends StatefulWidget {
  final ContentEvalModel evaluation;
  final TextRecordModel record;
  const ScoringScreen({super.key, required this.evaluation, required this.record});
  @override
  State<ScoringScreen> createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<ScoringScreen> {
  final _comment = TextEditingController();
  int _lr = 0, _ca = 0, _os = 0, _inter = 0, _refl = 0;
  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      await auth.api.submitScore(widget.evaluation.id, scores: {
        'literature_relevance': _lr, 'citation_accuracy': _ca,
        'outline_structure': _os, 'interdisciplinary': _inter,
        'reflection': _refl,
      }, comment: _comment.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('评分提交成功'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.evaluation;
    return Scaffold(
      appBar: AppBar(title: const Text('人工评分'), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AI参考评分', style: TextStyle(fontWeight: FontWeight.w600)),
                _scoreRow('文献相关性', e.aiLiteratureRelevance ?? 0, 5),
                _scoreRow('引用准确性', e.aiCitationAccuracy ?? 0, 5),
                _scoreRow('大纲结构', e.aiOutlineStructure ?? 0, 5),
                _scoreRow('基础分', e.aiBasicTotal ?? 0, 15),
                _scoreRow('跨学科视角', e.aiInterdisciplinary ?? 0, 1),
                _scoreRow('AI使用反思', e.aiReflection ?? 0, 1),
                const Divider(),
                _scoreRow('AI总评分', e.aiTotal ?? 0, 17),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          const Text('被评估文本', style: TextStyle(fontWeight: FontWeight.w600)),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.record.aiOptimizedText ?? '', maxLines: 10, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF475569))),
            ),
          ),
          const SizedBox(height: 16),
          const Text('基础评分 (0-5)', style: TextStyle(fontWeight: FontWeight.w600)),
          _slider('文献相关性', _lr, (v) => setState(() => _lr = v.toInt()), 5),
          _slider('引用准确性', _ca, (v) => setState(() => _ca = v.toInt()), 5),
          _slider('大纲结构', _os, (v) => setState(() => _os = v.toInt()), 5),
          const Text('加分项 (0-1)', style: TextStyle(fontWeight: FontWeight.w600)),
          _slider('跨学科视角', _inter, (v) => setState(() => _inter = v.toInt()), 1),
          _slider('AI使用反思', _refl, (v) => setState(() => _refl = v.toInt()), 1),
          TextField(controller: _comment, maxLines: 3, decoration: const InputDecoration(hintText: '评语（可选）', contentPadding: EdgeInsets.all(16))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('提交评分'))),
        ]),
      ),
    );
  }

  Widget _scoreRow(String label, int val, int max) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Color(0xFF64748B))),
      Text('$val/$max', style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );

  Widget _slider(String label, int val, Function(double) cb, int max) => Row(children: [
    SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)))),
    Expanded(child: Slider(value: val.toDouble(), min: 0, max: max.toDouble(), divisions: max, onChanged: cb)),
    Text('$val', style: const TextStyle(fontWeight: FontWeight.w600)),
  ]);

  @override
  void dispose() { _comment.dispose(); super.dispose(); }
}

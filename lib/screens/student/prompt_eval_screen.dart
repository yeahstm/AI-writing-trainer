import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class PromptEvalScreen extends StatelessWidget {
  final TextRecordModel record;
  const PromptEvalScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prompt质量分析'), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x144F46E5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1F4F46E5))),
              child: const Text('步骤二', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
            ),
          ]),
          const SizedBox(height: 12),
          const Text('Prompt质量分析', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 20),
          if (record.promptScore != null) _scoreCircle(record.promptScore!),
          const SizedBox(height: 16),
          _section('您提交的Prompt指令', record.userPrompt ?? ''),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _statCard('原文字数', '${record.originalText?.length ?? 0}')),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Prompt字数', '${record.userPrompt?.length ?? 0}')),
          ]),
          const SizedBox(height: 16),
          Text('AI分析报告', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(record.contentEvaluation?.aiReport ?? '报告生成中...', style: const TextStyle(color: Color(0xFF475569), height: 1.6)),
            ),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('← 返回重新优化')),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/content_eval', arguments: {'record': record}),
              child: const Text('下一步：查看内容评估 →'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _scoreCircle(double score) {
    final color = score >= 80 ? Colors.green : (score >= 60 ? Colors.orange : Colors.red);
    return Center(
      child: Container(
        width: 96, height: 96,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 4)),
        child: Center(child: Text('${score.toInt()}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color))),
      ),
    );
  }

  Widget _section(String label, String text) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
        const SizedBox(height: 8),
        Text('"$text"', style: const TextStyle(color: Color(0xFF475569), fontStyle: FontStyle.italic)),
      ]),
    ),
  );

  Widget _statCard(String label, String value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    ),
  );
}

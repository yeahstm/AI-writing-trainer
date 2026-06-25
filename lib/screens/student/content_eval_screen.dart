import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class ContentEvalScreen extends StatefulWidget {
  final TextRecordModel record;
  const ContentEvalScreen({super.key, required this.record});

  @override
  State<ContentEvalScreen> createState() => _ContentEvalScreenState();
}

class _ContentEvalScreenState extends State<ContentEvalScreen> {
  late TextRecordModel _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _record = widget.record;
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getRecord(_record.id);
      if (!mounted) return;
      setState(() {
        _record = TextRecordModel.fromJson(data['record']);
        if (data['content_evaluation'] != null) {
          _record.contentEvaluation = ContentEvalModel.fromJson(data['content_evaluation']);
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _scoreDot(int val, {Color color = const Color(0xFF4F46E5)}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withAlpha(20), border: Border.all(color: color.withAlpha(60))),
      child: Center(child: Text('$val', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ce = _record.contentEvaluation;
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (ce == null) {
      return Scaffold(appBar: AppBar(title: const Text('内容评估')), drawer: const AppDrawer(),
        body: const Center(child: Text('评估数据尚未生成')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('生成内容评估报告'), centerTitle: true),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x144F46E5), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x1F4F46E5))),
              child: const Text('步骤三', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
            ),
          ]),
          const SizedBox(height: 16),
          Center(
            child: Column(children: [
              Text('${ce.finalScore ?? ce.aiTotal ?? '-'}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const Text('/ 17', style: TextStyle(fontSize: 16, color: Color(0xFF94A3B8))),
            ]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                getTitle: (i, _) {
                  const labels = ['文献相关性', '引用准确性', '大纲结构'];
                  return RadarChartTitle(text: labels[i]);
                },
                dataSets: [
                  RadarDataSet(
                    dataEntries: [
                      RadarEntry(value: (ce.aiLiteratureRelevance ?? 0).toDouble()),
                      RadarEntry(value: (ce.aiCitationAccuracy ?? 0).toDouble()),
                      RadarEntry(value: (ce.aiOutlineStructure ?? 0).toDouble()),
                    ],
                    borderColor: const Color(0xFF6366F1),
                    borderWidth: 2.5,
                    fillColor: const Color(0xFF6366F1).withAlpha(30),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _dimRow('文献相关性', _scoreDot(ce.aiLiteratureRelevance ?? 0), '/ 5'),
          _dimRow('引用准确性', _scoreDot(ce.aiCitationAccuracy ?? 0), '/ 5'),
          _dimRow('大纲结构', _scoreDot(ce.aiOutlineStructure ?? 0), '/ 5'),
          const Divider(height: 24),
          _dimRow('基础分', Text('${ce.aiBasicTotal ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)), '/ 15'),
          _dimRow('跨学科视角', _scoreDot(ce.aiInterdisciplinary ?? 0, color: Colors.green), '+1'),
          _dimRow('AI使用反思', _scoreDot(ce.aiReflection ?? 0, color: Colors.green), '+1'),
          _dimRow('加分小计', Text('+${ce.aiBonusTotal ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold)), '+2'),
          const Divider(height: 24),
          _dimRow('AI总评分', Text('${ce.aiTotal ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))), '/ 17'),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AI评估分析报告', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
                const SizedBox(height: 8),
                Text(ce.aiReport ?? '', style: const TextStyle(color: Color(0xFF475569), height: 1.6)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('← 返回Prompt评估')),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/courses'),
              child: const Text('下一步：进入课程学习 →'),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _dimRow(String label, Widget val, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B)))),
        val, const SizedBox(width: 4),
        Text(suffix, style: const TextStyle(color: Color(0xFF94A3B8))),
      ]),
    );
  }
}

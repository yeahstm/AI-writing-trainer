import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class AdminWeightsScreen extends StatefulWidget {
  const AdminWeightsScreen({super.key});
  @override
  State<AdminWeightsScreen> createState() => _AdminWeightsScreenState();
}

class _AdminWeightsScreenState extends State<AdminWeightsScreen> {
  double _ai = 0.5, _human = 0.5;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getWeights();
      setState(() {
        _ai = (data['ai_weight'] as num).toDouble();
        _human = (data['human_weight'] as num).toDouble();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    try {
      await context.read<AuthProvider>().api.setWeights(_ai, _human);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('权重已更新'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评分权重'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Text('AI评分权重: ${_ai.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(value: _ai, min: 0, max: 1, divisions: 20, onChanged: (v) => setState(() { _ai = v; _human = 1 - v; })),
            const SizedBox(height: 16),
            Text('人工评分权重: ${_human.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(value: _human, min: 0, max: 1, divisions: 20, onChanged: (v) => setState(() { _human = v; _ai = 1 - v; })),
            Row(children: [
              Expanded(child: Container(height: 24, color: const Color(0xFF4F46E5)), flex: (_ai * 100).round()),
              Expanded(child: Container(height: 24, color: Colors.amber), flex: (_human * 100).round()),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _save, child: const Text('更新权重配置'))),
          ]),
        ),
    );
  }
}

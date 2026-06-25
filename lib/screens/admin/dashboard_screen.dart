import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getAdminDashboard();
      setState(() {
        _stats = data.map((k, v) => MapEntry(k, (v as num).toInt()));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理员面板'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Wrap(spacing: 12, runSpacing: 12, children: [
              _stat('总用户', _stats['user_count'] ?? 0, Colors.indigo),
              _stat('学生', _stats['student_count'] ?? 0, Colors.indigo),
              _stat('教师', _stats['teacher_count'] ?? 0, Colors.amber),
              _stat('文本记录', _stats['record_count'] ?? 0, const Color(0xFF64748B)),
              _stat('待评分', _stats['pending_count'] ?? 0, Colors.red),
            ]),
            const SizedBox(height: 24),
            ..._links(),
          ]),
        ),
    );
  }

  Widget _stat(String label, int count, Color color) => SizedBox(
    width: 140,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ]),
      ),
    ),
  );

  List<Widget> _links() => [
    _btn('用户管理', () => Navigator.pushNamed(context, '/admin_users')),
    _btn('师生分配', () => Navigator.pushNamed(context, '/admin_assignments')),
    _btn('评分权重', () => Navigator.pushNamed(context, '/admin_weights')),
    _btn('全量记录', () => Navigator.pushNamed(context, '/admin_records')),
    _btn('课程管理', () => Navigator.pushNamed(context, '/admin_courses')),
    _btn('安全概览', () => Navigator.pushNamed(context, '/admin_security')),
  ].map((b) => Padding(padding: const EdgeInsets.only(bottom: 8), child: b)).toList();

  Widget _btn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: OutlinedButton(onPressed: onTap, child: Text(label)),
  );
}


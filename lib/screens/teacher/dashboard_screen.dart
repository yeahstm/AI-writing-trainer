import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});
  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _studentCount = 0, _pending = 0, _done = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getTeacherDashboard();
      setState(() {
        _studentCount = data['student_count'] ?? 0;
        _pending = data['pending_count'] ?? 0;
        _done = data['done_count'] ?? 0;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('教师工作台'), centerTitle: true),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('欢迎回来，${context.watch<AuthProvider>().user?.displayName ?? ''}', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _statCard('管理学生', _studentCount, Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('待评分', _pending, Colors.amber)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('已评分', _done, Colors.green)),
          ]),
          const SizedBox(height: 24),
          _linkCard('查看学生列表', Icons.people, () => Navigator.pushNamed(context, '/teacher_students')),
          const SizedBox(height: 8),
          _linkCard('浏览课程库', Icons.school, () => Navigator.pushNamed(context, '/courses')),
        ]),
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      ]),
    ),
  );

  Widget _linkCard(String label, IconData icon, VoidCallback onTap) => Card(
    child: ListTile(leading: Icon(icon, color: const Color(0xFF4F46E5)), title: Text(label), trailing: const Icon(Icons.chevron_right), onTap: onTap),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});
  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _oldPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confirmPw = TextEditingController();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      _data = await auth.api.getMyPage();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _changePw() async {
    if (_newPw.text != _confirmPw.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次新密码不一致'), backgroundColor: Colors.orange));
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.changePassword(_oldPw.text, _newPw.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码修改成功'), backgroundColor: Colors.green));
      _oldPw.clear(); _newPw.clear(); _confirmPw.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error ?? '修改失败'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) return const Scaffold(body: Center(child: Text('未登录')));

    return Scaffold(
      appBar: AppBar(title: const Text('我的页面'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(user.displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('${user.email} · ${user.role}', style: const TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(height: 24),
            if (_data != null && user.role == 'student') ...[
              Row(children: [
                _stat('优化记录', _data!['record_count'] ?? 0),
                const SizedBox(width: 12),
                _stat('已完成课程', _data!['completed_courses'] ?? 0),
              ]),
            ],
            if (_data != null && user.role == 'teacher') _stat('管理学生', _data!['student_count'] ?? 0),
            if (_data != null && user.role == 'admin') Row(children: [
              _stat('系统用户', _data!['total_users'] ?? 0),
              const SizedBox(width: 12),
              _stat('总记录', _data!['total_records'] ?? 0),
            ]),
            const SizedBox(height: 24),
            const Text('修改密码', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: _oldPw, obscureText: true, decoration: const InputDecoration(labelText: '原密码', contentPadding: EdgeInsets.all(12))),
            const SizedBox(height: 8),
            TextField(controller: _newPw, obscureText: true, decoration: const InputDecoration(labelText: '新密码', contentPadding: EdgeInsets.all(12))),
            const SizedBox(height: 8),
            TextField(controller: _confirmPw, obscureText: true, decoration: const InputDecoration(labelText: '确认新密码', contentPadding: EdgeInsets.all(12))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _changePw, child: const Text('更新密码'))),
          ]),
        ),
    );
  }

  Widget _stat(String label, int count) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('$count', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
        ]),
      ),
    ),
  );

  @override
  void dispose() { _oldPw.dispose(); _newPw.dispose(); _confirmPw.dispose(); super.dispose(); }
}

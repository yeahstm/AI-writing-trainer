import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class AdminAssignmentsScreen extends StatefulWidget {
  const AdminAssignmentsScreen({super.key});
  @override
  State<AdminAssignmentsScreen> createState() => _AdminAssignmentsScreenState();
}

class _AdminAssignmentsScreenState extends State<AdminAssignmentsScreen> {
  List<UserModel> _teachers = [], _students = [];
  Map<int, int> _amap = {};
  int? _selTeacher, _selStudent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getAdminAssignments();
      setState(() {
        _teachers = (data['teachers'] as List).map((j) => UserModel.fromJson(j)).toList();
        _students = (data['students'] as List).map((j) => UserModel.fromJson(j)).toList();
        _amap = Map<int, int>.from(data['assignment_map'] ?? {});
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _assign() async {
    if (_selTeacher == null || _selStudent == null) return;
    try {
      await context.read<AuthProvider>().api.createAssignment(_selTeacher!, _selStudent!);
      _load();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('分配成功'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('师生分配'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            DropdownButtonFormField<int>(
              value: _selTeacher,
              hint: const Text('选择教师'),
              items: _teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.displayName))).toList(),
              onChanged: (v) => setState(() => _selTeacher = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selStudent,
              hint: const Text('选择学生'),
              items: _students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName))).toList(),
              onChanged: (v) => setState(() => _selStudent = v),
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _assign, child: const Text('确认分配'))),
            const SizedBox(height: 16),
            const Text('当前分配情况', style: TextStyle(fontWeight: FontWeight.w600)),
            ..._students.map((s) => ListTile(
              title: Text(s.displayName),
              trailing: _amap.containsKey(s.id)
                  ? Text(_teachers.firstWhere((t) => t.id == _amap[s.id], orElse: () => _teachers.first).displayName)
                  : const Chip(label: Text('未分配')),
            )),
          ]),
        ),
    );
  }
}

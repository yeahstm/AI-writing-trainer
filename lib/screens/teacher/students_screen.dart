import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});
  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  List<UserModel> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getTeacherStudents();
      setState(() {
        _students = (data['students'] as List).map((j) => UserModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的学生'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        _students.isEmpty ? const Center(child: Text('暂无分配的学生')) :
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _students.length,
          itemBuilder: (_, i) {
            final s = _students[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(s.displayName[0])),
                title: Text(s.displayName),
                subtitle: Text(s.email),
                onTap: () => Navigator.pushNamed(context, '/teacher_student_detail', arguments: {'student': s}),
              ),
            );
          },
        ),
    );
  }
}

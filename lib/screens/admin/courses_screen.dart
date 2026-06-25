import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class AdminCoursesScreen extends StatefulWidget {
  const AdminCoursesScreen({super.key});
  @override
  State<AdminCoursesScreen> createState() => _AdminCoursesScreenState();
}

class _AdminCoursesScreenState extends State<AdminCoursesScreen> {
  List<CourseModel> _courses = [];
  bool _loading = true;
  final _title = TextEditingController(), _desc = TextEditingController(), _url = TextEditingController();
  String _category = 'text_optimization';
  int _duration = 15, _sort = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getAdminCourses();
      setState(() {
        _courses = (data['courses'] as List).map((j) => CourseModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    try {
      await context.read<AuthProvider>().api.addCourse({
        'title': _title.text.trim(), 'description': _desc.text.trim(),
        'video_url': _url.text.trim(), 'category': _category,
        'duration_minutes': _duration, 'sort_order': _sort,
      });
      _title.clear(); _desc.clear(); _url.clear();
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _toggle(CourseModel c) async {
    try {
      await context.read<AuthProvider>().api.toggleCourse(c.id);
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('课程管理'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: '课程标题', contentPadding: EdgeInsets.all(12))),
            const SizedBox(height: 8),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: '简介', contentPadding: EdgeInsets.all(12))),
            const SizedBox(height: 8),
            DropdownButtonFormField(value: _category, items: const [
              DropdownMenuItem(value: 'text_optimization', child: Text('文本优化技巧')),
              DropdownMenuItem(value: 'prompt_engineering', child: Text('Prompt Engineering')),
            ], onChanged: (v) => _category = v!),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _add, child: const Text('添加课程'))),
            const SizedBox(height: 16),
            ..._courses.map((c) => Card(
              child: ListTile(
                title: Text(c.title),
                subtitle: Text('${c.category} · ${c.durationMinutes}分钟 · ${c.isActive ? "启用" : "禁用"}'),
                trailing: TextButton(onPressed: () => _toggle(c), child: Text(c.isActive ? '禁用' : '启用')),
              ),
            )),
          ]),
        ),
    );
  }

  @override
  void dispose() { _title.dispose(); _desc.dispose(); _url.dispose(); super.dispose(); }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> with SingleTickerProviderStateMixin {
  List<CourseModel> _textOpt = [];
  List<CourseModel> _promptEng = [];
  bool _loading = true;
  late TabController _tabC;

  @override
  void initState() {
    super.initState();
    _tabC = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getCourses();
      setState(() {
        _textOpt = (data['text_optimization'] as List).map((j) => CourseModel.fromJson(j)).toList();
        _promptEng = (data['prompt_engineering'] as List).map((j) => CourseModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _mark(CourseModel c, String action) async {
    try {
      final auth = context.read<AuthProvider>();
      await auth.api.markCourse(c.id, action);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网课学习中心'),
        bottom: TabBar(controller: _tabC, tabs: const [Tab(text: '文本优化技巧'), Tab(text: 'Prompt Engineering')]),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabC,
              children: [
                _courseList(_textOpt),
                _courseList(_promptEng),
              ],
            ),
    );
  }

  Widget _courseList(List<CourseModel> courses) {
    if (courses.isEmpty) return const Center(child: Text('暂无课程'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length + 1,
      itemBuilder: (_, i) {
        if (i == courses.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton(
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  final records = auth.api;
                  // fallback to latest record
                  Navigator.pushNamed(context, '/rewrite');
                },
                child: const Text('进入改写再评估 →'),
              ),
            ),
          );
        }
        final c = courses[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(c.isCompleted ? Icons.check_circle : (c.isWatched ? Icons.visibility : Icons.play_circle),
                color: c.isCompleted ? Colors.green : (c.isWatched ? Colors.orange : Colors.grey)),
            title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${c.description ?? ''} · ${c.durationMinutes ?? 0}分钟', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: c.isCompleted
                ? const Chip(label: Text('已学完', style: TextStyle(fontSize: 12, color: Colors.green)))
                : TextButton(onPressed: () => _mark(c, 'completed'), child: const Text('标记完成')),
          ),
        );
      },
    );
  }

  @override
  void dispose() { _tabC.dispose(); super.dispose(); }
}

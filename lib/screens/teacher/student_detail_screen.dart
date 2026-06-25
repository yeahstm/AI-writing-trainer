import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class TeacherStudentDetailScreen extends StatefulWidget {
  final UserModel student;
  const TeacherStudentDetailScreen({super.key, required this.student});
  @override
  State<TeacherStudentDetailScreen> createState() => _TeacherStudentDetailScreenState();
}

class _TeacherStudentDetailScreenState extends State<TeacherStudentDetailScreen> {
  List<TextRecordModel> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getTeacherStudentDetail(widget.student.id);
      setState(() {
        _records = (data['records'] as List).map((j) => TextRecordModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.student.displayName), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        _records.isEmpty ? const Center(child: Text('暂无文本记录')) :
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _records.length,
          itemBuilder: (_, i) {
            final r = _records[i];
            final ce = r.contentEvaluation;
            return Card(
              child: ListTile(
                title: Text(r.originalText ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${r.status} · ${r.createdAt?.substring(0, 10) ?? ''}'),
                trailing: ce != null && ce.humanTotal == null
                    ? ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/scoring', arguments: {'eval': ce, 'record': r}), child: const Text('立即评分'))
                    : Text('${ce?.finalScore?.toInt() ?? '?'}/17'),
              ),
            );
          },
        ),
    );
  }
}

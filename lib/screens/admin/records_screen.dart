import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class AdminRecordsScreen extends StatefulWidget {
  const AdminRecordsScreen({super.key});
  @override
  State<AdminRecordsScreen> createState() => _AdminRecordsScreenState();
}

class _AdminRecordsScreenState extends State<AdminRecordsScreen> {
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
      final data = await auth.api.getAdminRecords();
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
      appBar: AppBar(title: const Text('全量记录'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _records.length,
          itemBuilder: (_, i) {
            final r = _records[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text((r.authorName ?? '?')[0])),
                title: Text(r.originalText ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${r.authorName ?? ""} · ${r.status}'),
                trailing: Text('${r.finalScore?.toInt() ?? '?'}/17'),
              ),
            );
          },
        ),
    );
  }
}

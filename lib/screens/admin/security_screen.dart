import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';

class AdminSecurityScreen extends StatefulWidget {
  const AdminSecurityScreen({super.key});
  @override
  State<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends State<AdminSecurityScreen> {
  Map<String, double> _banned = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getBannedIps();
      setState(() {
        _banned = Map<String, double>.from((data['banned_ips'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('安全概览'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('封禁IP: ${_banned.length} 个', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_banned.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('当前无封禁IP'))))
            else
              ..._banned.entries.map((e) => Card(
                child: ListTile(
                  title: Text(e.key),
                  subtitle: Text('剩余: ${(e.value / 3600).toStringAsFixed(1)} 小时'),
                ),
              )),
          ]),
        ),
    );
  }
}

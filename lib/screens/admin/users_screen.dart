import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../../widgets/app_drawer.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await auth.api.getAdminUsers();
      setState(() {
        _users = (data['users'] as List).map((j) => UserModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(UserModel u) async {
    try {
      await context.read<AuthProvider>().api.toggleUser(u.id);
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _changeRole(UserModel u, String role) async {
    try {
      await context.read<AuthProvider>().api.changeRole(u.id, role);
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('用户管理'), centerTitle: true),
      drawer: const AppDrawer(),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (_, i) {
            final u = _users[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(u.displayName[0])),
                title: Text(u.displayName),
                subtitle: Text('${u.email} · ${u.role} · ${u.isActive ? "启用" : "禁用"}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'toggle') _toggle(u);
                    else _changeRole(u, v);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'toggle', child: Text(u.isActive ? '禁用' : '启用')),
                    const PopupMenuItem(value: 'student', child: Text('设为学生')),
                    const PopupMenuItem(value: 'teacher', child: Text('设为教师')),
                    const PopupMenuItem(value: 'admin', child: Text('设为管理员')),
                  ],
                ),
              ),
            );
          },
        ),
    );
  }
}

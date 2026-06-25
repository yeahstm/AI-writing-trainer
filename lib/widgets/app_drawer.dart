import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/models.dart';
import '../config.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;
    final path = ModalRoute.of(context)?.settings.name ?? '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE8EAF0))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                      ),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(AppConfig.appName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      Text(AppConfig.appSubtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: _navItems(role, path, context, auth),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person, size: 20),
              title: const Text('我的页面', style: TextStyle(fontSize: 14)),
              onTap: () => Navigator.pushReplacementNamed(context, '/my_page'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, size: 20, color: Colors.red),
              title: const Text('退出登录', style: TextStyle(fontSize: 14, color: Colors.red)),
              onTap: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _navItems(String role, String path, BuildContext context, AuthProvider auth) {
    switch (role) {
      case 'student':
        return [
          _navItem('初次优化', Icons.edit_note, '/optimize', path, 1),
          _navItemStudent('Prompt评估', Icons.auto_awesome, '/prompt_eval', path, 2, auth),
          _navItemStudent('内容评估', Icons.assessment, '/content_eval', path, 3, auth),
          _navItem('网课学习', Icons.school, '/courses', path, 4),
          _navItemStudent('改写再评估', Icons.refresh, '/rewrite', path, 5, auth),
        ];
      case 'teacher':
        return [
          _navItem('工作台', Icons.dashboard, '/teacher_dashboard', path, 1),
          _navItem('我的学生', Icons.people, '/teacher_students', path, 2),
          _navItem('课程库', Icons.school, '/courses', path, 3),
        ];
      case 'admin':
        return [
          _navItem('管理仪表盘', Icons.dashboard, '/admin_dashboard', path, 1),
          _navItem('用户管理', Icons.people, '/admin_users', path, 2),
          _navItem('师生分配', Icons.link, '/admin_assignments', path, 3),
          _navItem('评分权重', Icons.tune, '/admin_weights', path, 4),
          _navItem('全量记录', Icons.list_alt, '/admin_records', path, 5),
          _navItem('课程管理', Icons.school, '/admin_courses', path, 6),
          _navItem('安全概览', Icons.shield, '/admin_security', path, 7),
        ];
      default:
        return [];
    }
  }

  /// 学生步骤2/3/5 —— 自动拉最新记录后跳转
  Widget _navItemStudent(String title, IconData icon, String route, String currentPath, int step, AuthProvider auth) {
    final isActive = currentPath == route;
    return Builder(
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: ListTile(
          leading: Icon(icon, size: 20, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8)),
          title: Text(title, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF475569))),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: isActive ? const Color(0xFFEEF2FF) : null,
          onTap: () async {
            Navigator.pop(ctx);
            try {
              final data = await auth.api.getRecords();
              final records = (data['records'] as List).map((j) => TextRecordModel.fromJson(j)).toList();
              if (records.isNotEmpty) {
                if (!ctx.mounted) return;
                Navigator.pushReplacementNamed(ctx, route, arguments: {'record': records.first});
              } else {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('请先完成初次优化'), backgroundColor: Colors.orange),
                );
                Navigator.pushReplacementNamed(ctx, '/optimize');
              }
            } catch (_) {
              if (!ctx.mounted) return;
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('暂无记录，请先完成初次优化'), backgroundColor: Colors.orange),
              );
              Navigator.pushReplacementNamed(ctx, '/optimize');
            }
          },
        ),
      ),
    );
  }

  Widget _navItem(String title, IconData icon, String route, String currentPath, int step) {
    final isActive = currentPath == route;
    return Builder(
      builder: (ctx) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: ListTile(
          leading: Icon(icon, size: 20, color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF94A3B8)),
          title: Text(title, style: TextStyle(fontSize: 14, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF4F46E5) : const Color(0xFF475569))),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          tileColor: isActive ? const Color(0xFFEEF2FF) : null,
          onTap: () {
            Navigator.pop(ctx);
            Navigator.pushReplacementNamed(ctx, route);
          },
        ),
      ),
    );
  }
}

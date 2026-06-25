import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_username.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      switch (auth.role) {
        case 'student':
          Navigator.pushReplacementNamed(context, '/optimize');
        case 'teacher':
          Navigator.pushReplacementNamed(context, '/teacher_dashboard');
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? '登录失败'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06080D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0x99FFFFFF).withAlpha(8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFF4338CA), Color(0xFF6366F1)]),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 20),
                  const Text('驭智而行', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFFC7D2FE))),
                  const SizedBox(height: 4),
                  const Text('AI 时代数字公民培养平台', style: TextStyle(fontSize: 13, color: Color(0x66FFFFFF))),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _username,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      prefixIcon: Icon(Icons.person, size: 20),
                      filled: true,
                      fillColor: Color(0x0AFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock, size: 20),
                      filled: true,
                      fillColor: Color(0x0AFFFFFF),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('登 录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text('还没有账号？立即注册 →', style: TextStyle(color: Color(0x66FFFFFF))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }
}

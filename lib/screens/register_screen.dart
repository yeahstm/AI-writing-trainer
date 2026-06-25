import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_username.text.trim().isEmpty || _email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有必填字段'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _username.text.trim(), _email.text.trim(),
      _password.text, _displayName.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('注册成功！请登录'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? '注册失败'), backgroundColor: Colors.red),
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
                  const Text('加入驭智而行', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFC7D2FE))),
                  const SizedBox(height: 4),
                  const Text('开启 AI 驾驭之旅', style: TextStyle(fontSize: 13, color: Color(0x66FFFFFF))),
                  const SizedBox(height: 32),
                  _field('用户名 *', _username, Icons.person),
                  const SizedBox(height: 14),
                  _field('显示名称', _displayName, Icons.badge),
                  const SizedBox(height: 14),
                  _field('邮箱 *', _email, Icons.email),
                  const SizedBox(height: 14),
                  _field('密码（至少8位，含字母+数字）*', _password, Icons.lock, obscure: true),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('注 册', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('← 已有账号？去登录', style: TextStyle(color: Color(0x66FFFFFF))),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0x0AFFFFFF),
      ),
    );
  }

  @override
  void dispose() {
    _username.dispose(); _email.dispose(); _password.dispose(); _displayName.dispose();
    super.dispose();
  }
}

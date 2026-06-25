import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student/optimize_screen.dart';
import 'screens/student/prompt_eval_screen.dart';
import 'screens/student/content_eval_screen.dart';
import 'screens/student/courses_screen.dart';
import 'screens/student/rewrite_screen.dart';
import 'screens/teacher/dashboard_screen.dart';
import 'screens/teacher/students_screen.dart';
import 'screens/teacher/student_detail_screen.dart';
import 'screens/teacher/scoring_screen.dart';
import 'screens/admin/dashboard_screen.dart' as admin;
import 'screens/admin/users_screen.dart';
import 'screens/admin/assignments_screen.dart';
import 'screens/admin/weights_screen.dart';
import 'screens/admin/records_screen.dart';
import 'screens/admin/courses_screen.dart';
import 'screens/admin/security_screen.dart';
import 'screens/common/my_page.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: const AtelierApp(),
  ));
}

class AtelierApp extends StatelessWidget {
  const AtelierApp({super.key});

  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4F46E5),
    onPrimary: Colors.white,
    secondary: Color(0xFF6366F1),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF1E293B),
    error: Color(0xFFEF4444),
    onError: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '驭智而行',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: _colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8EAF0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E5ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E5ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return _page(const LoginScreen());
          case '/register':
            return _page(const RegisterScreen());
          case '/optimize':
            return _page(const OptimizeScreen());
          case '/prompt_eval':
            final args = settings.arguments as Map;
            return _page(PromptEvalScreen(record: args['record']));
          case '/content_eval':
            final args = settings.arguments as Map;
            return _page(ContentEvalScreen(record: args['record']));
          case '/courses':
            return _page(const CoursesScreen());
          case '/rewrite':
            final args = settings.arguments as Map;
            return _page(RewriteScreen(record: args['record']));
          case '/teacher_dashboard':
            return _page(const TeacherDashboardScreen());
          case '/teacher_students':
            return _page(const TeacherStudentsScreen());
          case '/teacher_student_detail':
            final args = settings.arguments as Map;
            return _page(TeacherStudentDetailScreen(student: args['student']));
          case '/scoring':
            final args = settings.arguments as Map;
            return _page(ScoringScreen(evaluation: args['eval'], record: args['record']));
          case '/admin_dashboard':
            return _page(const admin.AdminDashboardScreen());
          case '/admin_users':
            return _page(const AdminUsersScreen());
          case '/admin_assignments':
            return _page(const AdminAssignmentsScreen());
          case '/admin_weights':
            return _page(const AdminWeightsScreen());
          case '/admin_records':
            return _page(const AdminRecordsScreen());
          case '/admin_courses':
            return _page(const AdminCoursesScreen());
          case '/admin_security':
            return _page(const AdminSecurityScreen());
          case '/my_page':
            return _page(const MyPageScreen());
          default:
            return _page(const LoginScreen());
        }
      },
    );
  }

  static MaterialPageRoute _page(Widget w) =>
      MaterialPageRoute(builder: (_) => w);
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();
    if (!mounted) return;
    if (auth.isLoggedIn) {
      _navigate(auth.role);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _navigate(String role) {
    switch (role) {
      case 'student':
        Navigator.pushReplacementNamed(context, '/optimize');
      case 'teacher':
        Navigator.pushReplacementNamed(context, '/teacher_dashboard');
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      default:
        Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

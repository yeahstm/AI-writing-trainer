import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    http.Response res;
    switch (method) {
      case 'GET':
        res = await http.get(uri, headers: _headers);
        break;
      case 'POST':
        res = await http.post(uri, headers: _headers, body: jsonEncode(body));
        break;
      default:
        throw Exception('Unsupported method');
    }
    final data = jsonDecode(res.body);
    if (res.statusCode >= 400) {
      throw Exception(data['error'] ?? '请求失败 (${res.statusCode})');
    }
    return data;
  }

  // Auth
  Future<Map<String, dynamic>> login(String username, String password) =>
      request('POST', '/login', body: {'username': username, 'password': password});

  Future<Map<String, dynamic>> register(
          String username, String email, String password, String displayName) =>
      request('POST', '/register',
          body: {'username': username, 'email': email, 'password': password, 'display_name': displayName});

  Future<Map<String, dynamic>> getUser() => request('GET', '/user');

  Future<Map<String, dynamic>> changePassword(String oldPw, String newPw) =>
      request('POST', '/change-password',
          body: {'old_password': oldPw, 'new_password': newPw});

  // Student - Optimize
  Future<Map<String, dynamic>> optimize(String originalText, String userPrompt) =>
      request('POST', '/optimize',
          body: {'original_text': originalText, 'user_prompt': userPrompt});

  Future<Map<String, dynamic>> getRecords() => request('GET', '/records');

  Future<Map<String, dynamic>> getRecord(int recordId) =>
      request('GET', '/record/$recordId');

  // Courses
  Future<Map<String, dynamic>> getCourses() => request('GET', '/courses');

  Future<void> markCourse(int courseId, String action) =>
      request('POST', '/courses/$courseId/mark', body: {'action': action});

  // Rewrite
  Future<Map<String, dynamic>> rewrite(int recordId,
          {required String type, String? newPrompt, String? humanText}) =>
      request('POST', '/rewrite/$recordId', body: {
        'rewrite_type': type,
        if (newPrompt != null) 'new_prompt': newPrompt,
        if (humanText != null) 'human_rewritten_text': humanText,
      });

  Future<Map<String, dynamic>> getRewrites(int recordId) =>
      request('GET', '/rewrites/$recordId');

  // Teacher
  Future<Map<String, dynamic>> getTeacherDashboard() =>
      request('GET', '/teacher/dashboard');

  Future<Map<String, dynamic>> getTeacherStudents() =>
      request('GET', '/teacher/students');

  Future<Map<String, dynamic>> getTeacherStudentDetail(int studentId) =>
      request('GET', '/teacher/student/$studentId');

  Future<Map<String, dynamic>> submitScore(int evalId,
          {required Map<String, int> scores, String? comment}) =>
      request('POST', '/teacher/score/$evalId', body: {
        ...scores,
        'comment': comment ?? '',
      });

  // Admin
  Future<Map<String, dynamic>> getAdminDashboard() =>
      request('GET', '/admin/dashboard');

  Future<Map<String, dynamic>> getAdminUsers() =>
      request('GET', '/admin/users');

  Future<void> toggleUser(int uid) =>
      request('POST', '/admin/users/$uid/toggle');

  Future<void> changeRole(int uid, String role) =>
      request('POST', '/admin/users/$uid/role', body: {'role': role});

  Future<Map<String, dynamic>> getAdminAssignments() =>
      request('GET', '/admin/assignments');

  Future<void> createAssignment(int teacherId, int studentId) =>
      request('POST', '/admin/assignments',
          body: {'teacher_id': teacherId, 'student_id': studentId});

  Future<Map<String, dynamic>> getWeights() =>
      request('GET', '/admin/weights');

  Future<void> setWeights(double ai, double human) =>
      request('POST', '/admin/weights',
          body: {'ai_weight': ai, 'human_weight': human});

  Future<Map<String, dynamic>> getAdminRecords() =>
      request('GET', '/admin/records');

  Future<Map<String, dynamic>> getAdminCourses() =>
      request('GET', '/admin/courses');

  Future<void> addCourse(Map<String, dynamic> course) =>
      request('POST', '/admin/courses', body: course);

  Future<void> toggleCourse(int cid) =>
      request('POST', '/admin/courses/$cid/toggle');

  Future<Map<String, dynamic>> getBannedIps() =>
      request('GET', '/admin/security');

  // My page
  Future<Map<String, dynamic>> getMyPage() => request('GET', '/my');
}

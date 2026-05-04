import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.genzpro.pk';

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String dob,
    required String gender,
    String? phone,
    String? address,
    String? course,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'dob': dob,
          'gender': gender,
          'phone': phone ?? '',
          'address': address ?? '',
          'course': course ?? '',
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId.toString()}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? name,
    String? phone,
    String? address,
    String? course,
    String? dob,
    String? gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
          if (course != null) 'course': course,
          if (dob != null) 'dob': dob,
          if (gender != null) 'gender': gender,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCourses({
    String? type,
    String? category,
    String? status,
  }) async {
    try {
      String url = '$baseUrl/get_courses.php';
      List<String> params = [];

      if (type != null && type != 'all') params.add('type=$type');
      if (category != null && category != 'all') params.add('category=$category');
      if (status != null && status != 'all') params.add('status=$status');

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(Uri.parse(url));
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_course_details.php?course_id=$courseId'),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_categories.php'));
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> enroll({required int userId, required int courseId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/enroll.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId, 'course_id': courseId}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getMyEnrollments(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my_enrollments.php?user_id=$userId'));
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard.php'));
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // CONFIG: Change this to your server IP if not running on localhost
  // Since the user is testing on a real device, we likely need the LAN IP.
  // The previous main.dart had 'http://192.168.8.127:5000'.
  // I will make this configurable or default to that.
  static const String _baseUrl = 'http://192.168.8.127:5000';

  Future<Map<String, dynamic>> checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/test')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'error': 'Server returned ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMasterMetadata() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_master_metadata')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to fetch master metadata'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> uploadMasterKey(File image, String subject, String gradeLevel, String examDate) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_master'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['subject'] = subject;
      request.fields['grade_level'] = gradeLevel;
      request.fields['exam_date'] = examDate;

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> gradeStudent(File image, String studentId, String name, String medium) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/grade_student'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.fields['student_id'] = studentId;
      request.fields['student_name'] = name;
      request.fields['student_medium'] = medium;

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        return {'success': false, 'error': errorData['error'] ?? 'Unknown error'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<dynamic> exportExcel({String? subject, String? gradeLevel, String? grade}) async {
    try {
      var uri = Uri.parse('$_baseUrl/export_excel');
      var queryParams = <String, String>{};
      if (subject != null) queryParams['subject'] = subject;
      if (gradeLevel != null) queryParams['grade_level'] = gradeLevel;
      if (grade != null) queryParams['grade'] = grade;
      
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> getAllResults() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_all_results')).timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to fetch results'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getFilters() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/get_filters')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to fetch filters'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

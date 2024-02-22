import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'https://api.example.com';

  // GET 요청
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // POST 요청
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }
}

Future<void> fetchUserData() async {
  try {
    final apiService = ApiService();
    final data = await apiService.get('/users/1');
    print('User Data: $data');
    // 여기서 data를 처리합니다.
  } catch (e) {
    print(e.toString());
  }
}
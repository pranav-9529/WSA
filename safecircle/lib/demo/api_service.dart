import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://wsa-1.onrender.com"; // CHANGE THIS

  // Signup API
  static Future<Map<String, dynamic>> signup(
    String fname,
    String lname,
    String email,
    String phone,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/signup");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fname": fname,
        "lname": lname,
        "email": email,
        "phone": phone,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  // Login API
  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": password}),
    );

    return jsonDecode(response.body);
  }
}

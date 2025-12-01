import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Change this to your deployed backend URL when testing on a real device
  static const String baseUrl = "https://wsa-1.onrender.com/api";

  // -------- LOGIN --------
  static Future<Map<String, dynamic>> login({
    String? phone,
    String? email,
    required String password,
  }) async {
    final body = {
      if (phone != null && phone.isNotEmpty) "phone": phone,
      if (email != null && email.isNotEmpty) "email": email,
      "password": password,
    };

    try {
      final url = Uri.parse("$baseUrl/auth/login");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Login status: ${res.statusCode}, body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data;
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      print("Login error: $e");
      return {"success": false, "message": "Network error"};
    }
  }

  // -------- SIGNUP --------
  static Future<Map<String, dynamic>> signup({
    required String fname,
    required String lname,
    required String email,
    required String phone,
    required String password,
  }) async {
    final body = {
      "fname": fname,
      "lname": lname,
      "email": email,
      "phone": phone,
      "password": password,
    };

    try {
      final url = Uri.parse("$baseUrl/auth/signup");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("Signup status: ${res.statusCode}, body: ${res.body}");

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        return {"success": false, "message": "Server error: ${res.statusCode}"};
      }
    } catch (e) {
      print("Signup error: $e");
      return {"success": false, "message": "Network error"};
    }
  }

  // -------- AUTH HEADER --------
  static Future<Map<String, String>> getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }
}

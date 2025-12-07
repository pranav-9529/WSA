// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   // Change this to your deployed backend URL
//   static const String baseUrl = "https://wsa-1.onrender.com/api";

//   // -------- LOGIN --------
//   static Future<Map<String, dynamic>> login({
//     String? phone,
//     String? email,
//     required String password,
//   }) async {
//     final body = {
//       if (phone != null && phone.isNotEmpty) "phone": phone,
//       if (email != null && email.isNotEmpty) "email": email,
//       "password": password,
//     };

//     try {
//       final url = Uri.parse("$baseUrl/auth/login");
//       final res = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       print("Login status: ${res.statusCode}, body: ${res.body}");

//       if (res.statusCode == 200) {
//         // ✅ Parse JSON safely
//         Map<String, dynamic> data;
//         try {
//           data = jsonDecode(res.body);
//         } catch (e) {
//           return {"success": false, "message": "Invalid server response"};
//         }

//         // ✅ Save JWT token and userId for single user login
//         if (data["success"] == true &&
//             data["token"] != null &&
//             data["user"] != null) {
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString("token", data["token"]);
//           await prefs.setString("userID", data["_id"].toString());
//         }

//         return data;
//       } else if (res.statusCode == 401 || res.statusCode == 400) {
//         // Unauthorized / invalid credentials
//         return {"success": false, "message": "Invalid credentials"};
//       } else {
//         return {"success": false, "message": "Server error: ${res.statusCode}"};
//       }
//     } catch (e) {
//       print("Login error: $e");
//       return {"success": false, "message": "Network error"};
//     }
//   }

//   // -------- SIGNUP --------
//   static Future<Map<String, dynamic>> signup({
//     required String fname,
//     required String lname,
//     required String email,
//     required String phone,
//     required String password,
//   }) async {
//     final body = {
//       "fname": fname,
//       "lname": lname,
//       "email": email,
//       "phone": phone,
//       "password": password,
//     };

//     try {
//       final url = Uri.parse("$baseUrl/auth/signup");
//       final res = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       print("Signup status: ${res.statusCode}, body: ${res.body}");

//       if (res.statusCode == 200 || res.statusCode == 201) {
//         return jsonDecode(res.body);
//       } else {
//         return {"success": false, "message": "Server error: ${res.statusCode}"};
//       }
//     } catch (e) {
//       print("Signup error: $e");
//       return {"success": false, "message": "Network error"};
//     }
//   }

//   // -------- GET AUTH HEADER (for API calls) --------
//   static Future<Map<String, String>> getHeaders() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("token");

//     return {
//       "Content-Type": "application/json",
//       if (token != null) "Authorization": "Bearer $token",
//     };
//   }

//   // -------- LOGOUT --------
//   static Future<void> logout() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove("token");
//     await prefs.remove("userId");
//   }
// }

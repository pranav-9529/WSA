// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ApiService {
//   static const String baseUrl = "https://wsa-1.onrender.com/api"; // replace

//   static Future<Map<String, dynamic>> login(
//     String? phone,
//     String? email,
//     String password,
//   ) async {
//     final url = Uri.parse("$baseUrl/login");

//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "email": email,
//           "phone": phone,
//           "password": password,
//         }),
//       );

//       return jsonDecode(response.body);
//     } catch (e) {
//       return {"success": false, "message": "Server Error: $e"};
//     }
//   }
// }

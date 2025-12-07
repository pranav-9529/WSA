import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://wsa-1.onrender.com/api/auth";

  // ---------------------- SAVE USERID ----------------------
  static Future<void> saveUserID(String userID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userID", userID);
  }

  // ---------------------- SAVE TOKEN ----------------------
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ---------------------- GET TOKEN ----------------------
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ---------------------- LOGIN ----------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data["token"]);
    }

    return {"status": response.statusCode, "data": data};
  }

  // ---------------------- SIGNUP ----------------------
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/signup");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data["token"]);
    }

    return {"status": response.statusCode, "data": data};
  }

  // ---------------------- GET USER DETAIL (JWT) ----------------------
  static Future<Map<String, dynamic>> getUserData() async {
    final token = await getToken();

    final url = Uri.parse("$baseUrl/user/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return {"status": response.statusCode, "data": jsonDecode(response.body)};
  }
}

// ==============================================================
// ⭐⭐ NEW CODE ADDED BELOW — Folder + Contact API (NO CHANGES ABOVE)
// ==============================================================

class ApiService2 {
  static const String baseUrl = "https://wsa-1.onrender.com/api";

  // ---------------------- SAVE TOKEN ----------------------
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  // ---------------------- GET TOKEN ----------------------
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  // ---------------------- ADD FOLDER ----------------------
  static Future<Map<String, dynamic>> addFolder({
    required String folderName,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.post(
      Uri.parse("$baseUrl/folder/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "folderName": folderName,
        "userID": userID, // <- important lowercase 'd'
      }),
    );

    print(
      "Folder creation response: ${response.statusCode} | ${response.body}",
    );

    return _processResponse(response);
  }

  // ---------------------- GET ALL FOLDERS ----------------------
  static Future<Map<String, dynamic>> getFolders(String userID) async {
    final token = await getToken() ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/folder/all/$userID"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------------- DELETE FOLDER ----------------------
  static Future<Map<String, dynamic>> deleteFolder({
    required String folderID,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.delete(
      Uri.parse("$baseUrl/folder/delete/$folderID/$userID"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------------- ADD CONTACT ----------------------
  static Future<Map<String, dynamic>> addContact({
    required String folderID,
    required String name,
    required String phone,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.post(
      Uri.parse("$baseUrl/contact/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "folderID": folderID,
        "c_name": name, // backend expects c_name
        "c_phone": phone, // backend expects c_phone
        "userID": userID,
      }),
    );

    return _processResponse(response);
  }

  // ---------------------- GET CONTACTS BY FOLDER ----------------------
  static Future<Map<String, dynamic>> getContacts({
    required String folderID,
    required String userID,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/contact/$folderID/$userID"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------------- DELETE MULTIPLE CONTACTS ----------------------
  static Future<Map<String, dynamic>> deleteMultipleContacts({
    required List<String> contactIDs,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.post(
      Uri.parse("$baseUrl/contact/delete-multiple"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"contactIDs": contactIDs}),
    );

    return _processResponse(response);
  }

  // ---------------------- SEARCH CONTACT ----------------------
  static Future<Map<String, dynamic>> searchContact({
    required String query,
  }) async {
    final token = await getToken() ?? "";

    final response = await http.get(
      Uri.parse("$baseUrl/contact/search?query=$query"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    return _processResponse(response);
  }

  // ---------------------- HELPER: PROCESS RESPONSE ----------------------
  static Map<String, dynamic> _processResponse(http.Response response) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Error ${response.statusCode}: ${response.reasonPhrase}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Invalid response: $e"};
    }
  }
}

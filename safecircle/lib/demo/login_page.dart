// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_service.dart';
// import 'home_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController loginController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool isLoading = false;

//   Future<void> loginUser() async {
//     final loginInput = loginController.text.trim();
//     final password = passwordController.text.trim();

//     if (loginInput.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Email/Phone and Password are required")),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final res = await ApiService.login(
//         email: loginInput,
//         phone: loginInput,
//         password: password,
//       );

//       setState(() => isLoading = false);

//       print("Login Response: $res");

//       if (res["success"] == true) {
//         final prefs = await SharedPreferences.getInstance();

//         await prefs.setString("token", res["token"] ?? "");
//         await prefs.setString("userID", res["_id"].toString());

//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Login Successful!")));

//         // ⭐⭐ FORCE NAVIGATION FIX ⭐⭐
//         Future.microtask(() {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (context) => HomePage()),
//             (route) => false,
//           );
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(res["message"] ?? "Login Failed")),
//         );
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: loginController,
//               decoration: const InputDecoration(labelText: "Email or Phone"),
//             ),
//             const SizedBox(height: 15),
//             TextFormField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: const InputDecoration(labelText: "Password"),
//             ),
//             const SizedBox(height: 20),
//             isLoading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: loginUser,
//                     child: const Text("Login"),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

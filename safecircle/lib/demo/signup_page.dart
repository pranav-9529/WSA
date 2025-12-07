// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_service.dart';
// import 'home_page.dart';
// import 'login_page.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final fnameController = TextEditingController();
//   final lnameController = TextEditingController();
//   final emailController = TextEditingController();
//   final phoneController = TextEditingController();
//   final passwordController = TextEditingController();

//   bool loading = false;

//   void signupUser() async {
//     final fname = fnameController.text.trim();
//     final lname = lnameController.text.trim();
//     final email = emailController.text.trim();
//     final phone = phoneController.text.trim();
//     final password = passwordController.text.trim();

//     if (fname.isEmpty ||
//         lname.isEmpty ||
//         password.isEmpty ||
//         (email.isEmpty && phone.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please fill all required fields")),
//       );
//       return;
//     }

//     setState(() => loading = true);

//     try {
//       final res = await ApiService.signup(
//         fname: fname,
//         lname: lname,
//         email: email,
//         phone: phone,
//         password: password,
//       );

//       print("Signup Response: $res"); // Debug

//       setState(() => loading = false);

//       if (res["success"] == true) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString("token", res["token"]);
//         await prefs.setString("userID", res["userID"]);

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => HomePage()),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(res["message"] ?? "Signup failed")),
//         );
//       }
//     } catch (e) {
//       setState(() => loading = false);
//       print("Signup Error: $e"); // Debug
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Network error")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Signup")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: fnameController,
//               decoration: const InputDecoration(
//                 labelText: "First Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: lnameController,
//               decoration: const InputDecoration(
//                 labelText: "Last Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: "Email",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: phoneController,
//               decoration: const InputDecoration(
//                 labelText: "Phone",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(
//                 labelText: "Password",
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 20),
//             loading
//                 ? const CircularProgressIndicator()
//                 : ElevatedButton(
//                     onPressed: signupUser,
//                     child: const Text("Signup"),
//                   ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => LoginPage()),
//                 );
//               },
//               child: const Text("Already have an account? Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

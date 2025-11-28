import 'package:flutter/material.dart';
import 'package:safecircle/demo/signup_page.dart';
import 'api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginController =
      TextEditingController(); // single field for email/phone
  final passwordController = TextEditingController();

  bool loading = false;

  void loginUser() async {
    setState(() => loading = true);

    String input = loginController.text.trim();
    String password = passwordController.text.trim();

    // Identify input: phone or email
    String email = "";
    String phone = "";

    if (input.contains("@")) {
      email = input; // it's email
    } else {
      phone = input; // it's phone
    }

    final res = await ApiService.login(phone, email, password);

    setState(() => loading = false);

    if (res["message"] == "Login successful") {
      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage()));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["message"].toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: loginController,
              decoration: InputDecoration(
                labelText: "Enter Phone No. OR Email",
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 25),

            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: loginUser, child: Text("Login")),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
              child: Text("Don't have an account? Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

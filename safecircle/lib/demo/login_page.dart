import 'package:flutter/material.dart';
import 'package:safecircle/demo/signup_page.dart';
import 'api_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void loginUser() async {
    setState(() => loading = true);

    final res = await ApiService.login(
      phoneController.text,
      passwordController.text,
    );

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
              controller: phoneController,
              decoration: InputDecoration(labelText: "Phone"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            SizedBox(height: 20),
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
              child: Text("don't have an account, Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

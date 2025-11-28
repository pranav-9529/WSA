import 'package:flutter/material.dart';
import 'package:safecircle/demo/login_page.dart';
import 'api_service.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  void signupUser() async {
    setState(() => loading = true);

    final res = await ApiService.signup(
      fnameController.text,
      lnameController.text,
      emailController.text,
      phoneController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (res["message"] == "User registered successfully") {
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
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: fnameController,
              decoration: InputDecoration(labelText: "First Name"),
            ),
            TextField(
              controller: lnameController,
              decoration: InputDecoration(labelText: "Last Name"),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
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
                : ElevatedButton(onPressed: signupUser, child: Text("Signup")),

            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text("You have an account, Login"),
            ),
          ],
        ),
      ),
    );
  }
}

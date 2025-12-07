import 'package:flutter/material.dart';
import 'package:safecircle/demo/F_C_page.dart';
import 'package:safecircle/demo/home_page.dart';
import 'package:safecircle/demo2/folder.dart';
import 'api_service.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  signupUser() async {
    setState(() => loading = true);

    final res = await ApiService.signup(
      name: name.text,
      email: email.text,
      password: password.text,
    );

    setState(() => loading = false);

    if (res["status"] == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => FolderScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["data"]["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: email,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: password,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : signupUser,
              child: loading ? CircularProgressIndicator() : Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:safecircle/demo/F_C_page.dart';
import 'package:safecircle/demo/home_page.dart';
import 'package:safecircle/demo2/folder.dart';
import 'api_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  loginUser() async {
    setState(() => loading = true);

    final res = await ApiService.login(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    setState(() => loading = false);

    if (res["status"] == 200) {
      var data = res["data"];
      String token = data['token'];
      String userID = data['userID'];

      await ApiService.saveToken(token);
      await ApiService.saveUserID(userID);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
              onPressed: loading ? null : loginUser,
              child: loading ? CircularProgressIndicator() : Text("Login"),
            ),
            TextButton(
              child: Text("Create account"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

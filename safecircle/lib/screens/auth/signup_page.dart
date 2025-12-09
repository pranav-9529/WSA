import 'package:flutter/material.dart';
import 'package:safecircle/Theme/colors.dart';
import 'package:safecircle/screens/home_page.dart';
import '../../service/api_service.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final fnameCtrl = TextEditingController();
  final lnameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;

  signupUser() async {
    final fname = fnameCtrl.text.trim();
    final lname = lnameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    if (fname.isEmpty ||
        lname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.signup(
        fname: fname,
        lname: lname,
        email: email,
        phone: phone,
        password: password,
      );

      setState(() => loading = false);

      // ---------------------------
      // ⭐ SIGNUP SUCCESS? THEN LOGIN
      // ---------------------------
      if (res["status"] == 200 || res["status"] == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup successful, logging in...")),
        );

        // Now login to get token + userID
        final loginRes = await ApiService.login(
          email: email,
          password: password,
        );

        if (loginRes["status"] == 200) {
          final data = loginRes["data"];
          final token = data["token"];
          final userID = data["userID"];

          if (token != null && userID != null) {
            await ApiService.saveToken(token);
            await ApiService.saveUserID(userID);
          }

          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Signup done but login failed")),
          );
        }
      } else {
        String msg = res["data"]["message"] ?? "Signup failed";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Signup")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: fnameCtrl,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lnameCtrl,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : signupUser,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}

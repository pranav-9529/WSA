import 'package:flutter/material.dart';

void main() {
  runApp(LoginPage());
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "Login",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    Image.network(
                      "data:image/jpeg;base64,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",
                      width: 25,
                    ),
                    SizedBox(width: 10),
                    Text("+91", style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
                height: 55,
              ),

              SizedBox(height: 30),

              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFFd4145a), Color(0xFFfbb03b)],
                  ),
                ),
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("OR"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              SizedBox(height: 30),

              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://developers.google.com/identity/images/g-logo.png",
                      width: 22,
                    ),
                    SizedBox(width: 10),
                    Text("Google Sign in", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't i have an account ?"),
                  SizedBox(width: 6),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

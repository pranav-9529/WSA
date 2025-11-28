import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home - API Test")),
      body: Center(
        child: Text(
          "API Testing Successful 👍",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

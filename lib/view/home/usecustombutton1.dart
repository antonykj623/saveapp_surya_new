import 'package:flutter/material.dart';

import 'custombuton.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Widget Example")),
      body: Center(
        child: CustomButton(
          text: "Click Me",
          color: Colors.green,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Button Clicked!")),
            );
          },
        ),
      ),
    );
  }
}
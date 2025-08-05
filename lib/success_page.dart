// success_page.dart
import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  final int nid;
  const SuccessPage({super.key, required this.nid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Success')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅ Registration Successful!'),
            Text('Your ID: $nid'),
          ],
        ),
      ),
    );
  }
}
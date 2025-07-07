import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart'; // for SuccessPage
import 'qr_view_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
  final mobile = mobileController.text.trim();

  if (mobile.isEmpty || !RegExp(r'^\d{10}$').hasMatch(mobile)) {
    showSnack('Enter valid 10-digit mobile number');
    return;
  }

  setState(() => isLoading = true);

  try {
    final response = await http.post(
      Uri.parse('http://172.16.218.68/vehicle_app/api/login_qr'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'mobile': mobile}),
    );

    print("API Response: ${response.body}");

    if (response.headers['content-type']?.contains('application/json') ?? false) {
      final jsonResp = json.decode(response.body);
      print("Parsed UID: ${jsonResp['uid']}");

      if (response.statusCode == 200 && jsonResp['success'] == true) {
        if (jsonResp['uid'] == null) {
          showSnack('❌ Invalid or missing user ID (uid)');
          return;
        }

        final int uid = int.parse(jsonResp['uid'].toString());

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(uid: uid),
          ),
        );
      } else {
        showSnack(jsonResp['message'] ?? 'Login failed');
      }
    } else {
      showSnack('Unexpected server response:\n${response.body}');
    }
  } catch (e) {
    showSnack('❌ Network error: $e');
  } finally {
    setState(() => isLoading = false);
  }
}



  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginUser,
                    child: const Text('Login'),
                  ),
          ],
        ),
      ),
    );
  }
}

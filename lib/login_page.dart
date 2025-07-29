import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'qr_view_page.dart';


import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final rawMobile = mobileController.text;
  final mobile = rawMobile.replaceAll(RegExp(r'\D'), '');

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
          final uid = int.parse(jsonResp['uid'].toString());

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => QRViewPage(uid: uid)),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF232526),
              Color(0xFF414345),
              Color(0xFF0f2027),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_open, size: 60, color: Colors.blueAccent),
                    const SizedBox(height: 20),
                    Text(
                      "Login to EV Wallet",
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        label: Text(
                          'Mobile Number',
                          style: GoogleFonts.orbitron(fontSize: 14),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: loginUser,
                            icon: const Icon(Icons.login),
                            label: Text(
                              "Login",
                              style: GoogleFonts.orbitron(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: GoogleFonts.orbitron(
                            fontSize: 14, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

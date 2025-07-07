import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      showSnack('⚠️ Please fill all fields');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      showSnack('⚠️ Mobile number must be 10 digits');
      return;
    }

    setState(() => isLoading = true);

    try {
        final response = await http.post(
        Uri.parse('http://172.16.218.68/vehicle_app/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'mobile_number': mobile, // ✅ fixed key
        }),
      );


      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        showSnack('✅ Registered successfully!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        showSnack('❌ ${data['message'] ?? "Registration failed"}');
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
                    const Icon(Icons.ev_station, size: 60, color: Colors.green),
                    const SizedBox(height: 20),
                    Text(
                      "Register for Charging Access",
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        label: Text(
                          'Full Name',
                          style: GoogleFonts.orbitron(fontSize: 14),
                        ),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        label: Text(
                          'Mobile Number',
                          style: GoogleFonts.orbitron(fontSize: 14),
                        ),
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            onPressed: registerUser,
                            icon: const Icon(Icons.app_registration),
                            label: Text(
                              "Register",
                              style: GoogleFonts.orbitron(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
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
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
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

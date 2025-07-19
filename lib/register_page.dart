import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_page.dart';
import 'success_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkForUpdate(context);
    });
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2/vehicle_app/sites/default/files/version.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['latest_version'];
        final apkUrl = data['apk_url'];

        // ✅ Get current version using package_info_plus
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        if (currentVersion != latestVersion) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Update Available'),
              content: Text('A new version ($latestVersion) is available.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (await canLaunchUrl(Uri.parse(apkUrl))) {
                      await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
                    } else {
                      showSnack('Could not launch update URL');
                    }
                  },
                  child: const Text('Update Now'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Update check error: $e");
    }
  }

  Future<void> submitForm() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();

    if (name.isEmpty || mobile.isEmpty) {
      showSnack('Please fill all fields');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      showSnack('Invalid mobile number. Must be 10 digits.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final uuid = Uuid();
      final String uniqueId = uuid.v4();

      final response = await http.post(
        Uri.parse('http://localhost/vehicle_app/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'mobile_number': mobile,
          'device_id': uniqueId,
        }),
      );

      final jsonResp = json.decode(response.body);

      if (response.statusCode == 200 && jsonResp['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessPage(nid: int.parse(jsonResp['nid'].toString())),
          ),
        );
      } else {
        showSnack('❌ ${jsonResp['message'] ?? "Registration failed"}');
      }
    } catch (e) {
      showSnack('❌ Network error: $e');
    } finally {
      setState(() => isLoading = false);
    }
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
                            onPressed: submitForm,
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

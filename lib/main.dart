import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:upgrader/upgrader.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'qr_view_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'success_page.dart';
import 'welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EV Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        textTheme: GoogleFonts.orbitronTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  
    final int uid;
  final String username;
  const HomePage({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  void sendToArduino(BuildContext context, String deviceId) async {
    final uri = Uri.parse('http://172.16.218.172/check_device'); // Arduino endpoint
    try {
      final response = await http.post(uri, body: {'device_id': deviceId});
      if (response.statusCode == 200) {
        final result = response.body.trim().toLowerCase();
        if (result == 'match') {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text("Authorized"),
              content: Text("Device matched. Access granted."),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text("Unauthorized"),
              content: Text("QR code not matched. Access denied."),
            ),
          );
        }
      } else {
        throw Exception("Bad response: ${response.statusCode}");
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: Text("Failed to contact Arduino.\n$e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR to Check Device')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Scan QR Code'),
          onPressed: () async {
                      final result = await Navigator.push(
              context,
              MaterialPageRoute(
              builder: (_) => QRViewPage(uid: uid, username: username),
              ),
            );
            if (result != null) {
              final deviceId = result.toString();
              sendToArduino(context, deviceId);
            }
          },
        ),
      ),
    );
  }
}







class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  bool isLoading = false;

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
      final response = await http.post(
        Uri.parse('http://172.16.218.68/vehicle_app/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'mobile_number': mobile,
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
        showSnack('❌ ${response.body}');
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
      appBar: AppBar(
        title: const Text('User Registration'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2027), Color(0xFF203A43), Color(0xFF2C5364)],
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
                        label: Text('Full Name', style: GoogleFonts.orbitron(fontSize: 14)),
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        label: Text('Mobile Number', style: GoogleFonts.orbitron(fontSize: 14)),
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
                            label: Text("Register", style: GoogleFonts.orbitron(fontSize: 16)),
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
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text("Already have an account? Login",
                          style: GoogleFonts.orbitron(fontSize: 14, color: Colors.blueGrey)),
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
            const Text('✅ Operation Successful!', style: TextStyle(fontSize: 20)),
            Text('Your ID is: $nid', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
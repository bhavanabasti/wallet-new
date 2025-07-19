import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';
import 'home_page.dart';
import 'package:upgrader/upgrader.dart'; 
import 'theme.dart'; 
import 'landing_page.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UpgradeAlert(
        child: RegisterPage(), // your app home
      ),
    );
  }
}
/* ───────────── APP ROOT ───────────── */

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Wallet',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: const LandingPage(), // ✅ Start from LandingPage
//     );
//   }
// }
/* ───────────── HOME SCREEN ───────────── */

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Welcome")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const RegisterPage()),
//               ),
//               child: const Text("Register"),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LoginPage()),
//               ),
//               child: const Text("Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/* ───────────── REGISTER PAGE ───────────── */

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
        Uri.parse('http://localhost/vehicle_app/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'mobile_number': mobile, // ✅ fixed key
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
      appBar: AppBar(title: const Text('User Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const Spacer(),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: submitForm,
                    child: const Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}

/* ───────────── SUCCESS PAGE ───────────── */

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
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

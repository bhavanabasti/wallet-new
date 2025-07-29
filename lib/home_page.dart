import 'package:flutter/material.dart';
import 'qr_view_page.dart'; // The page where scanner opens
import 'services/esp_service.dart'; 
import 'package:http/http.dart' as http; // ✅ Fix for 'http' error
import 'dart:convert'; // ✅ Fix for 'json' error

class HomePage extends StatefulWidget {
  final int uid;
  const HomePage({required this.uid, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String voltage = '';
  String current = '';
  String energy = '';
  String amount = '';
  bool loading = false;

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final data = await fetchChargerData('192.168.4.1'); // Your ESP IP
      setState(() {
        voltage = data['voltage'].toString();
        current = data['current'].toString();
        energy = data['energy'].toString();
        amount = data['amount'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching ESP data')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> payNow() async {
    try {
      final response = await http.post(
        Uri.parse('http://172.16.218.68/vehicle_app/api/save_reading'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'uid': widget.uid,
          'voltage': voltage,
          'current': current,
          'energy': energy,
          'amount': amount,
        }),
      );

      final jsonResp = json.decode(response.body);
      if (response.statusCode == 200 && jsonResp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Payment Successful")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Payment Failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // Automatically fetch on page open
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charging Session')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Voltage: $voltage V"),
                  Text("Current: $current A"),
                  Text("Energy: $energy kWh"),
                  Text("Amount: ₹$amount"),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.currency_rupee),
                    label: const Text("Pay Now"),
                    onPressed: payNow,
                  )
                ],
              ),
            ),
    );
  }
}



// class HomePage extends StatelessWidget {
//    final int uid;
//   const HomePage({required this.uid, super.key}); // ✅ correct
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Wallet Home'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final result = await Navigator.push(
//               context,
//              MaterialPageRoute(builder: (context) => QRViewPage(uid: uid)),// ✅ FIXED
//             );
//             if (result != null) {
//               print("Scanned QR Code: $result");
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text("Scanned: $result")),
//               );
//             }
//           },
//           child: Text("Scan QR Code"),
//         ),
//       ),
//     );
//   }
// }

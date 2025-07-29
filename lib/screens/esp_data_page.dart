// lib/screens/esp_data_page.dart

import 'package:flutter/material.dart';
import '../services/esp_service.dart'; // Import the function

class ESPDataPage extends StatefulWidget {
  @override
  _ESPDataPageState createState() => _ESPDataPageState();
}

class _ESPDataPageState extends State<ESPDataPage> {
  String voltage = 'Loading...';
  String current = 'Loading...';

  @override
  void initState() {
    super.initState();
    getData(); // 🔹 Call it when widget loads
  }

  // 🔹 Place this inside the _ESPDataPageState class
  void getData() async {
    final ip = '192.168.4.1'; // Your ESP's IP address
    try {
      final data = await fetchChargerData(ip);
      setState(() {
        voltage = data['voltage'].toString();
        current = data['current'].toString();
      });
    } catch (e) {
      setState(() {
        voltage = 'Error';
        current = 'Error';
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charger Data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Voltage: $voltage', style: TextStyle(fontSize: 20)),
            Text('Current: $current', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

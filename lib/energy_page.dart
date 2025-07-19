// lib/energy_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EnergyPage extends StatefulWidget {
  final String qrUrl;

  const EnergyPage({super.key, required this.qrUrl});

  @override
  _EnergyPageState createState() => _EnergyPageState();
}

class _EnergyPageState extends State<EnergyPage> {
  Map<String, dynamic>? energyData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchEnergyData();
  }

  Future<void> fetchEnergyData() async {
    try {
      final response = await http.get(Uri.parse(widget.qrUrl));
      if (response.statusCode == 200) {
        setState(() {
          energyData = jsonDecode(response.body);
          loading = false;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching energy data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live EV Charging Data')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : energyData == null
              ? const Text("No data received.")
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("🔌 Voltage: ${energyData!['voltage']} V", style: TextStyle(fontSize: 20)),
                      Text("⚡ Current: ${energyData!['current']} A", style: TextStyle(fontSize: 20)),
                      Text("💡 Power: ${energyData!['power']} W", style: TextStyle(fontSize: 20)),
                      Text("📊 Energy: ${energyData!['energy']} kWh", style: TextStyle(fontSize: 20)),
                      Text("💰 Amount: ₹${energyData!['amount']}", style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
    );
  }
}

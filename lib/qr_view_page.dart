import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'energy_page.dart'; // ⬅️ Make sure this import exists

class QRViewPage extends StatefulWidget {
  final int uid;
  const QRViewPage({super.key, required this.uid});

  @override
  State<QRViewPage> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
      onDetect: (BarcodeCapture capture) {
  if (scanned) return;

  final code = capture.barcodes.first.rawValue ?? "";

  if (code.isNotEmpty && code.startsWith("http://172.16.218.40/data?uid=")) {
    scanned = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnergyPage(qrUrl: code),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Invalid QR Code"),
      ),
    );
  }
},

      ),
    );
  }
}

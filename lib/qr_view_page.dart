import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRViewPage extends StatelessWidget {
  final int uid;
  const QRViewPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final MobileScannerController cameraController = MobileScannerController();

    return Scaffold(
      appBar: AppBar(title: Text("Scan QR - UID: $uid")),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (BarcodeCapture capture) {
          final Barcode barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'home_page.dart';

import 'qr_view_page.dart';



class QRViewPage extends StatefulWidget {
  final int uid;

  const QRViewPage({super.key, required this.uid});

  @override
  State<QRViewPage> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  late final MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final Barcode? barcode = capture.barcodes.first;
    if (barcode != null && barcode.rawValue != null) {
      final code = barcode.rawValue!;
      debugPrint('Scanned QR Code: $code');

      // Optionally stop scanning once detected
      cameraController.stop();

      Navigator.pop(context, code); // return scanned result to previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'home_page.dart';

// class QRViewPage extends StatefulWidget {
//   final int uid;

//   const QRViewPage({super.key, required this.uid});

//   @override
//   State<QRViewPage> createState() => _QRViewPageState();
// }

// class _QRViewPageState extends State<QRViewPage> {
//   bool isScanned = false;

//   void onDetect(Barcode barcode, MobileScannerArguments? args) {
//     if (isScanned) return;

//     final scannedData = barcode.rawValue;
//     if (scannedData == null) return;

//     setState(() => isScanned = true); // prevent duplicate scans

//     // ✅ Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Scanned QR Code: $scannedData")),
//     );

//     // ✅ Navigate to HomePage
//     Future.delayed(const Duration(seconds: 1), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomePage(uid: widget.uid)),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Scan QR Code")),
//       body: MobileScanner(
//         allowDuplicates: false,
//         onDetect: onDetect,
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

class QRViewPage extends StatefulWidget {
  final int uid;
  final String username; // Expected to be mobile number

  const QRViewPage({
    Key? key,
    required this.uid,
    required this.username,
  }) : super(key: key);

  @override
  State<QRViewPage> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  bool isScanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (isScanned) return;
    isScanned = true;

    final String? deviceId = capture.barcodes.first.rawValue?.trim();

    if (deviceId == null || deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR code')),
      );
      return;
    }

    try {
      // Log payload before sending
      final payload = {
        'mobile': widget.username,
        'device_id': deviceId,
        'status': 'success',
      };

      print('Scanned deviceId: $deviceId');
      print('Sending to Drupal: ${jsonEncode(payload)}');

      final logResponse = await http.post(
        Uri.parse('http://172.16.218.68/vehicle_app/api/device_event_log'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('Drupal log status: ${logResponse.statusCode}');
      print('Drupal log headers: ${logResponse.headers}');
      print('Drupal log body: ${logResponse.body}');

      if (logResponse.statusCode != 200 ||
          !(logResponse.headers['content-type']?.contains('application/json') ?? false)) {
        throw Exception('Unexpected response from Drupal: ${logResponse.statusCode} - ${logResponse.body}');
      }

      // Notify Arduino
      final arduinoResponse = await http.post(
        Uri.parse('http://172.16.218.172/api/check_device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'username': widget.username,
        }),
      );

      print('Arduino response: ${arduinoResponse.body}');

      if (arduinoResponse.statusCode != 200 ||
          !arduinoResponse.headers['content-type']!.contains('application/json')) {
        throw Exception('Unexpected response from Arduino.');
      }

      final responseJson = jsonDecode(arduinoResponse.body);
      final status = responseJson['status'] ?? 'unknown';
      final current = responseJson['current'] ?? '0';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device $status | Current: $current A')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:http/http.dart' as http;


// class QRViewPage extends StatefulWidget {
  
//   final int uid;
  
//   const QRViewPage({super.key, required this.uid});

//   @override
//   State<QRViewPage> createState() => _QRViewPageState();
// }

// class _QRViewPageState extends State<QRViewPage> {
//   late final MobileScannerController cameraController;
//   bool isProcessing = false;

//   @override
//   void initState() {
//     super.initState();
//     cameraController = MobileScannerController();
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture capture) async {
//     if (isProcessing) return; // Prevent multiple scans
//     isProcessing = true;

//     final Barcode? barcode = capture.barcodes.first;
//     if (barcode != null && barcode.rawValue != null) {
//       final code = barcode.rawValue!;
//       debugPrint('Scanned QR Code: $code');

//       final deviceId = barcode.rawValue!;
//       debugPrint('Scanned QR Code: $deviceId');

//       cameraController.stop();

//       // Send device ID to ESP (example: Arduino check)
//       final response = await http.post(
//         Uri.parse('http://172.16.218.40/check_device'),
//         headers: {'Content-Type': 'application/json'},
//         body: '{"device_id": "$deviceId"}',
//       );

//       String message;
//       bool authorized = false;

//       if (response.statusCode == 200) {
//         final result = response.body;
//         authorized = result.trim() == 'OK';
//         message = authorized
//             ? '✅ Authorized! Device can be turned ON.'
//             : '❌ Unauthorized Device!';
//       } else {
//         message = '⚠️ Error connecting to device.';
//       }

//       if (!mounted) return;

//       // Show result to user
//       await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: const Text("Device Check Result"),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("OK"),
//             )
//           ],
//         ),
//       );

//       // Go back to HomePage with scanned code (if authorized)
//       if (authorized && mounted) {
//         Navigator.pop(context, deviceId);
//       } else {
//         // Restart scanning if unauthorized or error
//         cameraController.start();
//         isProcessing = false;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Scan QR Code")),
//       body: MobileScanner(
//         controller: cameraController,
//         onDetect: _onDetect,
//       ),
//     );
//   }
// }







// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'home_page.dart';

// import 'qr_view_page.dart';



// class QRViewPage extends StatefulWidget {
//   final int uid;

//   const QRViewPage({super.key, required this.uid});

//   @override
//   State<QRViewPage> createState() => _QRViewPageState();
// }

// class _QRViewPageState extends State<QRViewPage> {
//   late final MobileScannerController cameraController;

//   @override
//   void initState() {
//     super.initState();
//     cameraController = MobileScannerController();
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture capture) {
//     final Barcode? barcode = capture.barcodes.first;
//     if (barcode != null && barcode.rawValue != null) {
//       final code = barcode.rawValue!;
//       debugPrint('Scanned QR Code: $code');

//       // Optionally stop scanning once detected
//       cameraController.stop();

//       Navigator.pop(context, code); // return scanned result to previous page
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Scan QR Code")),
//       body: MobileScanner(
//         controller: cameraController,
//         onDetect: _onDetect,
//       ),
//     );
//   }
    // }






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
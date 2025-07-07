import 'package:flutter/material.dart';
import 'qr_view_page.dart'; // The page where scanner opens

class HomePage extends StatelessWidget {
   final int uid;
  const HomePage({required this.uid, super.key}); // ✅ correct
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
             MaterialPageRoute(builder: (context) => QRViewPage(uid: uid)),// ✅ FIXED
            );
            if (result != null) {
              print("Scanned QR Code: $result");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Scanned: $result")),
              );
            }
          },
          child: Text("Scan QR Code"),
        ),
      ),
    );
  }
}

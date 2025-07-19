import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

Future<void> checkForUpdate(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version;

  try {
    // Replace this with your real API endpoint or static JSON file
    final response = await http.get(
      Uri.parse('http://localhost/vehicle_app/api/app_version'), // or static JSON file
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final latestVersion = data['latest_version'];
      final apkUrl = data['apk_url'];

      if (currentVersion != latestVersion) {
        // Show dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Text('A new version ($latestVersion) is available.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (await canLaunchUrl(Uri.parse(apkUrl))) {
                    await launchUrl(Uri.parse(apkUrl), mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch update link')),
                    );
                  }
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    debugPrint("Error checking for update: $e");
  }
}

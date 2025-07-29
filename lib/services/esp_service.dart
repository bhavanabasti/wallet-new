// lib/services/esp_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchChargerData(String ip) async {
  final response = await http.get(Uri.parse('http://$ip/'));

  if (response.statusCode == 200) {
    try {
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  } else {
    throw Exception('Failed to fetch data from ESP');
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_quanlykhachsan/config/api_config.dart';

class ChatApiService {
  static Future<String> sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/Chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['text'] as String).trim();
      }
      throw Exception('API Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể kết nối với AI');
    }
  }
}
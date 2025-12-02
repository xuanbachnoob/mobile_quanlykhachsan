import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/hoantien.dart';

class HoantienApiService {
  static Future<Hoantien> createHoantien({
    required int madatphong,
    required int sotienhoan,
    required String lydo,
    String? ghichu,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Hoantiens');

    final body = jsonEncode({
      'madatphong': madatphong,
      'sotienhoan': sotienhoan,
      'lydo': lydo,
      'trangthai': 'Hoàn tất',
      'ghichu': ghichu ?? '',
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        return Hoantien.fromJson(data);
      } else {

        String errorMessage = 'Lỗi ${response.statusCode}';
        
        try {
          final errorData = jsonDecode(response.body);
          
          if (errorData is Map) {
            if (errorData.containsKey('message')) {
              errorMessage = errorData['message'];
            } else if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              if (errors is Map) {
                final errorList = errors.values.map((e) => e.toString()).join(', ');
                errorMessage = errorList;
              }
            } else if (errorData.containsKey('title')) {
              errorMessage = errorData['title'];
            } else {
              errorMessage = errorData.toString();
            }
          }
        } catch (e) {
          errorMessage = response.body;
        }
        
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}
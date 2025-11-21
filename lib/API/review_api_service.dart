import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mobile_quanlykhachsan/config/api_config.dart';

class ReviewApiService {

  /// Gửi đánh giá
  static Future<void> submitReview({
    required int makh,
    required int madatphong,
    required int sosao,
    required String danhgia,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Reviews/submit');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'makh': makh,
              'madatphong': madatphong,
              'sosao': sosao,
              'danhgia': danhgia,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('✅ Review submitted successfully');
        return;
      } else {
        throw Exception('Lỗi ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// ✅ KIỂM TRA ĐÃ ĐÁNH GIÁ CHƯA
  static Future<bool> checkReview({
    required int makh,
    required int madatphong,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Reviews/check?makh=$makh&madatphong=$madatphong');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['hasReviewed'] as bool? ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('❌ Check review error: $e');
      return false;
    }
  }
}
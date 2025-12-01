import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_information_model.dart';

/// Service xử lý Payment API
class PaymentApiService {
  /// Tạo VNPay URL
  Future<VnPayUrlResponse> createVnPayUrl(PaymentInformationModel model) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Payment/CreateVNPayUrl');

    print('🔍 Creating VNPay URL...');
    print('📤 Request: ${json.encode(model.toJson())}');

    try {
      final response = await http
          .post(
            url,
            headers: ApiConfig.headers,
            body: json.encode(model.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);

      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return VnPayUrlResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Không thể tạo thanh toán. Mã lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

//  Future<void> confirmPayment(int mahd, int amount) async {
//   final url = Uri.parse(
//     '${ApiConfig.baseUrl}/Payment/confirm-payment-success',
//   ).replace(queryParameters: {
//     'mahd': mahd.toString(),
//     'Amount': amount.toString(),
//   });
//   try {
//     final response = await http.get(url).timeout(ApiConfig.connectionTimeout);

//     print('Response ${response.statusCode}: ${response.body}\n');

//     if (response.statusCode == 200) {
//       print(' Payment confirmed!\n');
//       return; //  Không cần parse response
//     } else {
//       throw Exception('HTTP ${response.statusCode}: ${response.body}');
//     }
//   } catch (e) {
//     print(' Confirm error: $e\n');
//     rethrow;
//   }
// }
}

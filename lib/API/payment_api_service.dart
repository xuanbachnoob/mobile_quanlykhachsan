import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/payment_information_model.dart';

/// Service xử lý Payment API
class PaymentApiService {
  /// Tạo VNPay URL
  Future<VnPayUrlResponse> createVnPayUrl(PaymentInformationModel model) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Payment/CreateVNPayUrl');


    try {
      final response = await http
          .post(
            url,
            headers: ApiConfig.headers,
            body: json.encode(model.toJson()),
          )
          .timeout(ApiConfig.connectionTimeout);


      if (response.statusCode == 200) {
        return VnPayUrlResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Không thể tạo thanh toán. Mã lỗi: ${response.statusCode}',
        );
      }
    } catch (e) {

      throw Exception('Lỗi kết nối: $e');
    }
  }

}

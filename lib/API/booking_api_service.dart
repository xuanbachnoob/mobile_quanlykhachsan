import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/datphong.dart';
import '../models/chitietdatphong.dart';
import '../models/sudungdv.dart';

/// Service xử lý Booking API
class BookingApiService {
  /// 1. Tạo đặt phòng
  Future<Datphong> createDatphong(Datphong datphong) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Datphongs');
    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: json.encode(datphong.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Datphong.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không thể tạo đặt phòng. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating Datphong: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// 2. Tạo chi tiết đặt phòng
  Future<void> createChitietdatphong(Chitietdatphong chitiet) async {
    final url = Uri.parse('${ApiConfig.chitietDatphongEndpoint}/mobile');

    print('📤 Creating Chitietdatphong...');
    print('Request: ${json.encode(chitiet.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: json.encode(chitiet.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      print('📡 Response: ${response.statusCode}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Không thể tạo chi tiết đặt phòng. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating Chitietdatphong: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// 3. Tạo sử dụng dịch vụ (Stored Procedure tự tính toán)
  Future<void> createSudungdv(Sudungdv sudungdv) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Sudungdvs/sudungdv');
    // ✅ CHỈ GỬI 3 FIELDS: madatphong, madv, soluong
    final requestBody = {
      'madatphong': sudungdv.madatphong,
      'madv': sudungdv.madv,
      'soluong': sudungdv.soluong,
    };
    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: json.encode(requestBody),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Không thể tạo sử dụng dịch vụ. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating Sudungdv: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// 4. Tạo hóa đơn (Stored Procedure)
 Future<int> createHoadon() async {
  final url = Uri.parse('${ApiConfig.hoadonEndpoint}/taohoadon');
    final response = await http.post(
      url,
      headers: ApiConfig.headers,
    ).timeout(ApiConfig.connectionTimeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['mahoadon'];
    } else {
      throw Exception('Không thể tạo hóa đơn. Mã lỗi: ${response.statusCode}');
    }
}

  /// 5. FULL FLOW: Tạo booking hoàn chỉnh
  Future<Map<String, int>> createFullBooking({
  required Datphong datphong,
  required List<Map<String, dynamic>> rooms,
  required List<Map<String, int>> services,
}) async {
  try {
    print('🚀 ===== STARTING FULL BOOKING FLOW =====');

    // STEP 1: Tạo đặt phòng
    print('\n📝 STEP 1: Creating Datphong...');
    final createdDatphong = await createDatphong(datphong);
    final madatphong = createdDatphong.madatphong!;
    print('✅ Created Datphong with ID: $madatphong');

    // STEP 2: Tạo chi tiết đặt phòng

    for (var room in rooms) {
      await createChitietdatphong(
        Chitietdatphong(
          madatphong: madatphong,
          maphong: room['maphong'] as int,
          tongcong: room['tongcong'] as int,
          trangthai: 'Đã hủy',
        ),
      );
    }

    final mahoadon = await createHoadon();

    // STEP 3: Tạo sử dụng dịch vụ
    if (services.isNotEmpty) {

      for (var service in services) {
        await createSudungdv(
          Sudungdv(
            madatphong: madatphong,
            madv: service['madv']!,
            soluong: service['soluong']!,
          ),
        );
      }

    }

    return {
      'madatphong': madatphong,
      'mahoadon': mahoadon,
    };
    
  } catch (e) {
    rethrow;
  }
}
}
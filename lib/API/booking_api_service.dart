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

    print('📤 Creating Datphong...');
    print('Request: ${json.encode(datphong.toJson())}');

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
    final url = Uri.parse('${ApiConfig.baseUrl}/Chitietdatphongs');

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

    print('📤 Creating Sudungdv...');
    
    // ✅ CHỈ GỬI 3 FIELDS: madatphong, madv, soluong
    final requestBody = {
      'madatphong': sudungdv.madatphong,
      'madv': sudungdv.madv,
      'soluong': sudungdv.soluong,
    };
    
    print('Request: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
        body: json.encode(requestBody),
      ).timeout(ApiConfig.connectionTimeout);

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Không thể tạo sử dụng dịch vụ. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating Sudungdv: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// 4. Tạo hóa đơn (Stored Procedure)
  Future<void> createHoadon() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/Hoadons/taohoadon');

    print('📤 Creating Hoadon...');

    try {
      final response = await http.post(
        url,
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectionTimeout);

      print('📡 Response: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Không thể tạo hóa đơn. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating Hoadon: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// 5. FULL FLOW: Tạo booking hoàn chỉnh
  Future<int> createFullBooking({
    required Datphong datphong,
    required List<int> roomIds, // List maphong
    required List<Map<String, int>> services, // List {madv, soluong}
  }) async {
    try {
      print('🚀 ===== STARTING FULL BOOKING FLOW =====');

      // ===== STEP 1: TẠO ĐẶT PHÒNG =====
      print('\n📝 STEP 1: Creating Datphong...');
      final createdDatphong = await createDatphong(datphong);
      final madatphong = createdDatphong.madatphong!;
      print('✅ Created Datphong with ID: $madatphong');

      // ===== STEP 2: TẠO CHI TIẾT ĐẶT PHÒNG =====
      print('\n🏨 STEP 2: Creating Chitietdatphong for ${roomIds.length} room(s)...');
      for (int i = 0; i < roomIds.length; i++) {
        final maphong = roomIds[i];
        print('  Creating ${i + 1}/${roomIds.length}: Room ID $maphong');
        
        await createChitietdatphong(
          Chitietdatphong(
            madatphong: madatphong,
            maphong: maphong,
          ),
        );
        
        print('  ✅ Created Chitietdatphong for room $maphong');
      }
      print('✅ All Chitietdatphong created successfully!');

      // ===== STEP 3: TẠO SỬ DỤNG DỊCH VỤ =====
      if (services.isNotEmpty) {
        print('\n🎁 STEP 3: Creating Sudungdv for ${services.length} service(s)...');
        
        for (int i = 0; i < services.length; i++) {
          final service = services[i];
          final madv = service['madv']!;
          final soluong = service['soluong']!;
          
          print('  Creating ${i + 1}/${services.length}: Service ID $madv (Qty: $soluong)');
          
          await createSudungdv(
            Sudungdv(
              madatphong: madatphong,
              madv: madv,
              soluong: soluong,
            ),
          );
          
          print('  ✅ Created Sudungdv for service $madv');
        }
        
        print('✅ All Sudungdv created successfully!');
      } else {
        print('\n⏭️  STEP 3: No services selected, skipping...');
      }

      // ===== STEP 4: TẠO HÓA ĐƠN =====
      print('\n🧾 STEP 4: Creating Hoadon...');
      await createHoadon();
      print('✅ Hoadon created successfully!');

      print('\n🎉 ===== FULL BOOKING FLOW COMPLETED =====');
      print('📌 Madatphong: $madatphong\n');
      
      return madatphong;
      
    } catch (e) {
      print('\n❌ ===== BOOKING FLOW FAILED =====');
      print('Error: $e\n');
      rethrow;
    }
  }
}
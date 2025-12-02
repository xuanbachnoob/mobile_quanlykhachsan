/// Cấu hình API endpoints
class ApiConfig {
  // ============ BASE URL ============
  // Thay đổi tùy theo môi trường
  
  // Android Emulator
  static const String baseUrl = 'https://10.0.2.2:7076/api';
  
  // iOS Simulator
  // static const String baseUrl = 'http://localhost:7076/api';
  
  // Real Device (thay bằng IP máy tính)
  // static const String baseUrl = 'http://192.168.1.100:7076/api';
  
  // Production
  // static const String baseUrl = 'https://api.khachsanthanhtra.com/api';

  // ============ ENDPOINTS ============
  static const String authEndpoint = '$baseUrl/Taikhoans';
  static const String roomEndpoint = '$baseUrl/Phongs';
  static const String loaiphongEndpoint = '$baseUrl/Loaiphongs';
  static const String hinhanhEndpoint = '$baseUrl/Hinhanhphongs';
  static const String khachhangEndpoint = '$baseUrl/Khachhangs';
  static const String dichvuEndpoint = '$baseUrl/Dichvus';
  static const String paymentEndpoint = '$baseUrl/Payment';
  static const String bookingEndpoint = '$baseUrl/Datphongs';  
  static const String chitietDatphongEndpoint = '$baseUrl/Chitietdatphongs';
  static const String sudungdvEndpoint = '$baseUrl/Sudungdvs';
  static const String hoadonEndpoint = '$baseUrl/Hoadons';
  // ============ TIMEOUTS ============
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ HEADERS ============
  static Map<String, String> get headers => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
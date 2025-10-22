/// Model request tạo VNPay URL
class PaymentInformationModel {
  final String orderId;       // Mã hóa đơn (MAHOADON)
  final double amount;        // Số tiền
  final String orderDescription; // Mô tả
  final String name;          // Tên người thanh toán (optional)

  PaymentInformationModel({
    required this.orderId,
    required this.amount,
    required this.orderDescription,
    this.name = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'orderDescription': orderDescription,
      'name': name,
    };
  }
}

/// Model response VNPay URL
class VnPayUrlResponse {
  final String url;

  VnPayUrlResponse({required this.url});

  factory VnPayUrlResponse.fromJson(Map<String, dynamic> json) {
    return VnPayUrlResponse(
      url: json['url'] ?? '',
    );
  }
}
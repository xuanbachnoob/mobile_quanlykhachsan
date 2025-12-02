/// Model request tạo VNPay URL
class PaymentInformationModel {
  final int orderId;    
  final String orderType;
  final int amount;       
  final String orderDescription; 
  final String name;         
  final String platform = 'mobile';

  PaymentInformationModel({
    required this.orderId,
    required this.orderType,
    required this.amount,
    required this.orderDescription,
    this.name = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderType': orderType,
      'amount': amount,
      'orderDescription': orderDescription,
      'name': name,
      'platform': platform,
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
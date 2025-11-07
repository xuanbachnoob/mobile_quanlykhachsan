class Hoadon {
  final int? mahoadon;
  final DateTime? ngaylap;
  final int? tongtien;
  final String? trangthai;
  final int? madatphong;

  Hoadon({
    required this.mahoadon,
    this.ngaylap,
    this.tongtien,
    this.trangthai,
    this.madatphong,
  });

  Map<String, dynamic> toJson() {
    return {
      'mahoadon': mahoadon,
      'ngaylap': ngaylap?.toIso8601String(),
      'tongtien': tongtien,
      'trangthai': trangthai,
      'madatphong': madatphong,
    };
  }
  factory Hoadon.fromJson(Map<String, dynamic> json) {
    return Hoadon(
      mahoadon: json['mahoadon'],
      ngaylap: json['ngaylap'] != null ? DateTime.parse(json['ngaylap']) : null,
      tongtien: json['tongtien'],
      trangthai: json['trangthai'],
      madatphong: json['madatphong'],
    );
  }
}
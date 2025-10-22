/// Model dịch vụ - Khớp với API backend
class DichVu {
  final int madv;
  final String tendv;
  final String? mota;
  final int? giatien;
  final String? trangthai;
  final int? maloaidv;

  DichVu({
    required this.madv,
    required this.tendv,
    this.mota,
    this.giatien,
    this.trangthai,
    this.maloaidv,
  });

  factory DichVu.fromJson(Map<String, dynamic> json) {
    return DichVu(
      madv: json['madv'] ?? 0,
      tendv: json['tendv'] ?? '',
      mota: json['mota'],
      giatien: json['giatien'], // ← Giữ nguyên int
      trangthai: json['trangthai'],
      maloaidv: json['maloaidv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'madv': madv,
      'tendv': tendv,
      'mota': mota,
      'giatien': giatien,
      'trangthai': trangthai,
      'maloaidv': maloaidv,
    };
  }

  // Helper getters
  bool get isAvailable => 
      trangthai?.toLowerCase() == 'hoạt động' || 
      trangthai?.toLowerCase() == 'available';
  
  // ✅ Chuyển int sang double cho tính toán
  double get gia => (giatien ?? 0).toDouble();
}

/// Model dịch vụ đã chọn với số lượng
class SelectedDichVu {
  final DichVu dichvu;
  int soluong;

  SelectedDichVu({
    required this.dichvu,
    this.soluong = 1,
  });

  // ✅ Tính tổng giá
  double get tongGia => dichvu.gia * soluong;
}
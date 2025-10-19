class Loaiphong {
  final int Maloaiphong;
  final String Tenloaiphong;
  final String? Mota; // <-- SỬA: Cho phép 'Mota' được null
  final int Songuoitoida;
  final int Sogiuong;
  final int Giacoban;
  final String? HinhAnhUrl; // <-- Đã là String?

  Loaiphong({
    required this.Maloaiphong,
    required this.Tenloaiphong,
    this.Mota, // <-- SỬA: Bỏ 'required'
    required this.Songuoitoida,
    required this.Sogiuong,
    required this.Giacoban,
    this.HinhAnhUrl, // <-- SỬA: Bỏ 'required'
  });

  factory Loaiphong.fromJson(Map<String, dynamic> json) {
    return Loaiphong(
      Maloaiphong: json['maloaiphong'] as int,
      Tenloaiphong: json['tenloaiphong'] as String,
      Mota: json['mota'] as String?, // <-- SỬA: ép kiểu sang 'String?'
      Songuoitoida: json['songuoitoida'] as int,
      Sogiuong: json['sogiuong'] as int,
      Giacoban: json['giacoban'] as int,
      HinhAnhUrl: json['hinhAnhUrl'] as String?, // <-- SỬA: ép kiểu sang 'String?'
    );
  }
}
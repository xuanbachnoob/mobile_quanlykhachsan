class Loaiphong {
  final int Maloaiphong;
  final String Tenloaiphong;
  final String? Mota; 
  final int Songuoitoida;
  final int Sogiuong;
  final int Giacoban;
  final String? HinhAnhUrl; 

  Loaiphong({
    required this.Maloaiphong,
    required this.Tenloaiphong,
    this.Mota,
    required this.Songuoitoida,
    required this.Sogiuong,
    required this.Giacoban,
    this.HinhAnhUrl,
  });

  factory Loaiphong.fromJson(Map<String, dynamic> json) {
    return Loaiphong(
      Maloaiphong: json['maloaiphong'] as int,
      Tenloaiphong: json['tenloaiphong'] as String,
      Mota: json['mota'] as String?, 
      Songuoitoida: json['songuoitoida'] as int,
      Sogiuong: json['sogiuong'] as int,
      Giacoban: json['giacoban'] as int,
      HinhAnhUrl: json['hinhAnhUrl'] as String?, 
    );
  }
}
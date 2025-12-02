class Phong {
  final int Maphong;
  final String Sophong;
  final int Succhua;
  final String Trangthai;
  final int Maloaiphong;
  final String? Mavoucher;
  final int Mahinhphong;

  Phong({
    required this.Maphong,
    required this.Sophong,
    required this.Succhua,
    required this.Trangthai,
    required this.Maloaiphong,
    this.Mavoucher, 
    required this.Mahinhphong,
  });

  factory Phong.fromJson(Map<String, dynamic> json) {
    return Phong(
      Maphong: json['maphong'] as int,
      Sophong: json['sophong'] as String,
      Succhua: json['succhua'] as int,
      Trangthai: json['trangthai'] as String,
      Maloaiphong: json['maloaiphong'] as int,
      Mavoucher: json['mavoucher'] as String?,
      Mahinhphong: json['mahinhphong'] as int,
    );
  }
}
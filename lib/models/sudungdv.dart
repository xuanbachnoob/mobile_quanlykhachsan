/// Model sử dụng dịch vụ
class Sudungdv {
  final int? masudungdv;
  final int? madatphong;
  final int? madv;
  final int? soluong;
  final int? dongia;
  final int? tongtien;
  final String? trangthai;

  Sudungdv({
    this.masudungdv,
    this.madatphong,
    this.madv,
    this.soluong,
    this.dongia,
    this.tongtien,
    this.trangthai,
  });

  Map<String, dynamic> toJson() {
    return {
      'masudungdv': masudungdv,
      'madatphong': madatphong,
      'madv': madv,
      'soluong': soluong,
      'dongia': dongia,
      'tongtien': tongtien,
      'trangthai': trangthai,
    };
  }

  factory Sudungdv.fromJson(Map<String, dynamic> json) {
    return Sudungdv(
      masudungdv: json['masudungdv'],
      madatphong: json['madatphong'],
      madv: json['madv'],
      soluong: json['soluong'],
      dongia: json['dongia'],
      tongtien: json['tongtien'],
      trangthai: json['trangthai'],
    );
  }
}
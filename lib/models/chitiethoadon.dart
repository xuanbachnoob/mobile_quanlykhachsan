
class Chitiethoadon {
  final int? macthd;
  final int? mahoadon;
  final int? madatphong;
  final String? loaiphi;
  final int? dongia;
  final int? tongtien;

  Chitiethoadon({
    this.macthd,
    this.mahoadon,
    this.madatphong,
    this.loaiphi,
    this.dongia,
    this.tongtien,
  });
  Map<String, dynamic> toJson() {
    return {
      'macthd': macthd,
      'mahoadon': mahoadon,
      'madatphong': madatphong,
      'loaiphi': loaiphi,
      'dongia': dongia,
    };
  }
  factory Chitiethoadon.fromJson(Map<String, dynamic> json) {
    return Chitiethoadon(
      macthd: json['macthd'],
      mahoadon: json['mahoadon'],
      madatphong: json['madatphong'],
      loaiphi: json['loaiphi'],
      dongia: json['dongia'],
      tongtien: json['tongtien'],
    );
  }
}
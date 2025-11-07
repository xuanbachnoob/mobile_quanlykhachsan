class Denbuthiethai {
  final int? madenbu;
    final int? mathietbi;
  final int? soluong;
  final int? dongia;
  final int? tongtien;
  final int? maphong;
  final int? madatphong;
  final String? tenthietbi;

  Denbuthiethai({
    this.madenbu,
    this.mathietbi,
    this.soluong,
    this.dongia,
    this.tongtien,
    this.maphong,
    this.madatphong,
    this.tenthietbi,
  });

  Map<String, dynamic> toJson() {
    return {
      'madenbu': madenbu,
      'mathietbi': mathietbi,
      'soluong': soluong,
      'dongia': dongia,
      'tongtien': tongtien,
      'maphong': maphong,
      'madatphong': madatphong,
    };
  }
  factory Denbuthiethai.fromJson(Map<String, dynamic> json) {
    return Denbuthiethai(
      madenbu: json['madenbu'],
      mathietbi: json['mathietbi'],
      soluong: json['soluong'],
      dongia: json['dongia'],
      tongtien: json['tongtien'],
      maphong: json['maphong'],
      madatphong: json['madatphong'],
      tenthietbi: json['tenthietbi'],
    );
  }
}
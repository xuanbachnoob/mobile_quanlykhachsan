class Hinhanhphong {
  final int Mahinhphong;
  final String? Hinhchinh; // SỬA: Thêm ?
  final String? Hinhphu1;
  final String? Hinhphu2;
  final String? Hinhphu3;
  final String? Hinhphu4;
  final String? Hinhphu5;

  Hinhanhphong({
    required this.Mahinhphong,
    this.Hinhchinh, // SỬA: Bỏ required
    this.Hinhphu1,
    this.Hinhphu2,
    this.Hinhphu3,
    this.Hinhphu4,
    this.Hinhphu5,
  });

  factory Hinhanhphong.fromJson(Map<String, dynamic> json) {
    return Hinhanhphong(
      Mahinhphong: json['mahinhphong'] as int,
      Hinhchinh: json['hinhchinh'] as String?, 
      Hinhphu1: json['hinhphu1'] as String?, 
      Hinhphu2: json['hinhphu2'] as String?, 
      Hinhphu3: json['hinhphu3'] as String?, 
      Hinhphu4: json['hinhphu4'] as String?, 
      Hinhphu5: json['hinhphu5'] as String?,
    );
  }

  List<String> get imageUrls {
    final List<String> images = [];
    if (Hinhchinh != null && Hinhchinh!.isNotEmpty) {
      images.add(Hinhchinh!);
    }
    if (Hinhphu1 != null && Hinhphu1!.isNotEmpty) {
      images.add(Hinhphu1!);
    }
    if (Hinhphu2 != null && Hinhphu2!.isNotEmpty) {
      images.add(Hinhphu2!);
    }
    if (Hinhphu3 != null && Hinhphu3!.isNotEmpty) {
      images.add(Hinhphu3!);
    }
    if (Hinhphu4 != null && Hinhphu4!.isNotEmpty) {
      images.add(Hinhphu4!);
    }
    if (Hinhphu5 != null && Hinhphu5!.isNotEmpty) {
      images.add(Hinhphu5!);
    }
    return images;
  }
}
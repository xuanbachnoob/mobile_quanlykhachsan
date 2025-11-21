class Review {
  final int makh;
  final int madatphong;
  final int sosao;
  final String danhgia;

  Review({
    required this.makh,
    required this.madatphong,
    required this.sosao,
    required this.danhgia,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      makh: json['makh'] as int,
      madatphong: json['madatphong'] as int,
      sosao: json['sosao'] as int? ?? 0,
      danhgia: json['danhgia'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makh': makh,
      'madatphong': madatphong,
      'sosao': sosao,
      'danhgia': danhgia,
    };
  }
}
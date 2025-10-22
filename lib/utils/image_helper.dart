/// Helper xử lý image URLs
class ImageHelper {
  /// Base URL cho images (nếu API trả về relative path)
  static const String imageBaseUrl = 'https://your-api.com/images/';

  /// Lấy URL đầy đủ của ảnh
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return getPlaceholderUrl();
    }

    // Nếu là URL đầy đủ
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Nếu là asset local
    if (imagePath.startsWith('images/')) {
      return imagePath; // For Image.asset()
    }

    // Nếu là relative path từ API
    return imageBaseUrl + imagePath;
  }

  /// Placeholder image URL
  static String getPlaceholderUrl() {
    return 'images/placeholder.jpg';
  }

  /// Avatar placeholder
  static String getAvatarPlaceholder() {
    return 'images/avatar_placeholder.jpg';
  }

  /// Helper để check xem có phải local asset không
  static bool isLocalAsset(String? path) {
    if (path == null) return false;
    return path.startsWith('images/') ||
        path.startsWith('assets/');
  }

  /// Helper để check xem có phải network image không
  static bool isNetworkImage(String? path) {
    if (path == null) return false;
    return path.startsWith('http://') || path.startsWith('https://');
  }
}
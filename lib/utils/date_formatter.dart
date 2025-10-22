import 'package:intl/intl.dart';

/// Format ngày tháng
class DateFormatter {
  /// Format: 19/10/2024
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format: 19-20/10
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.month == end.month) {
      return '${start.day}-${end.day}/${start.month}';
    }
    return '${start.day}/${start.month}-${end.day}/${end.month}';
  }

  /// Format: 19 Tháng 10, 2024
  static String formatDateVerbose(DateTime date) {
    return DateFormat('dd \'Tháng\' MM, yyyy', 'vi_VN').format(date);
  }

  /// Format: Thứ 7, 19/10/2024
  static String formatDateWithDay(DateTime date) {
    final weekday = _getWeekdayInVietnamese(date.weekday);
    return '$weekday, ${formatDate(date)}';
  }

  /// Format: 14:30
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  /// Format: 19/10/2024 14:30
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Tính số đêm
  static int calculateNights(DateTime checkIn, DateTime checkOut) {
    final nights = checkOut.difference(checkIn).inDays;
    return nights > 0 ? nights : 1;
  }

  /// Format duration: "3 ngày 2 đêm"
  static String formatDuration(DateTime checkIn, DateTime checkOut) {
    final nights = calculateNights(checkIn, checkOut);
    final days = nights + 1;
    return '$days ngày $nights đêm';
  }

  /// Helper: Lấy thứ trong tuần tiếng Việt
  static String _getWeekdayInVietnamese(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ 2';
      case 2:
        return 'Thứ 3';
      case 3:
        return 'Thứ 4';
      case 4:
        return 'Thứ 5';
      case 5:
        return 'Thứ 6';
      case 6:
        return 'Thứ 7';
      case 7:
        return 'Chủ nhật';
      default:
        return '';
    }
  }

  /// Format relative time: "2 giờ trước", "3 ngày trước"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Tạo một định dạng số cho Việt Nam (dùng dấu chấm)
  static final _formatter = NumberFormat.decimalPattern('vi_VN');

  static String format(int price) {
    return _formatter.format(price);
  }
}
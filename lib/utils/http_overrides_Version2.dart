import 'dart:io';

/// Override để cho phép self-signed certificates trong development
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Trong production, nên check cert cụ thể
        // Nhưng dev mode thì allow all
        return true;
      };
  }
}
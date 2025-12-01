import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/API/booking_api_service.dart';
import 'package:mobile_quanlykhachsan/API/khachhang_api_service.dart';
import 'package:mobile_quanlykhachsan/models/chitiethoadon.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../providers/user_provider.dart';

/// Màn hình WebView thanh toán VNPay
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final int amount;
  final int usedPoints; // ✅ THÊM: Số điểm đã sử dụng
  final int madatphong; // ✅ THÊM: Mã đặt phòng

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.amount,
    this.usedPoints = 0, // ✅ THÊM: Mặc định 0
    required this.madatphong, // ✅ THÊM: Mã đặt phòng
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌐 PAYMENT WEBVIEW INITIALIZED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Payment URL: ${widget.paymentUrl}');
    print('Order ID: ${widget.orderId}');
    print('Amount: ${widget.amount} VNĐ');
    print('Used Points: ${widget.usedPoints} điểm'); // ✅ LOG ĐIỂM
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (JavaScriptMessage message) {
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📨 MESSAGE FROM WEBVIEW');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('Message: ${message.message}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
          
          if (message.message == 'payment_success') {
            _handlePaymentSuccess();
          } else if (message.message == 'payment_failed') {
            _handlePaymentFailed();
          } else if (message.message == 'close_webview') {
            _closeAndGoHome();
          }
        },
      )
      
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            print('📊 Loading progress: $progress%');
          },
          
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('🔄 PAGE STARTED');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('URL: $url');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
            
            if (!_isProcessing && 
                (url.contains('/VNPayReturn') || 
                 url.contains('vnp_ResponseCode'))) {
              print('🎯 DETECTED VNPAY RETURN URL\n');
              _handlePaymentCallback(url);
            }
          },
          
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('✅ PAGE FINISHED');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('URL: $url');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
          },
          
          onWebResourceError: (WebResourceError error) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('❌ WEBVIEW ERROR');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('Description: ${error.description}');
            print('Error Type: ${error.errorType}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
          },
        ),
      )
      
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  Future<void> _handlePaymentCallback(String url) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);

    try {
      final uri = Uri.parse(url);
      final params = uri.queryParameters;

      final vnpResponseCode = params['vnp_ResponseCode'] ?? '';
      final vnpTxnRef = params['vnp_TxnRef'] ?? '';
      final vnpOrderInfo = params['vnp_OrderInfo'] ?? '';
      final vnpAmount = params['vnp_Amount'] ?? '';
      final platform = params['platform'] ?? 'web';

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('💳 PAYMENT CALLBACK DETECTED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Response Code: $vnpResponseCode');
      print('Txn Ref: $vnpTxnRef');
      print('Order Info: $vnpOrderInfo');
      print('Amount: $vnpAmount');
      print('Platform: $platform');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (platform == 'mobile') {
        print('📱 Mobile platform detected - Waiting for JavaScript message...\n');
        setState(() => _isProcessing = false);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (vnpResponseCode == '00') {
        _handlePaymentSuccess();
      } else {
        _handlePaymentFailed(errorCode: vnpResponseCode);
      }
    } catch (e) {
      print('❌ Error handling callback: $e\n');
      setState(() => _isProcessing = false);
    }
  }

  // ✅ CẬP NHẬT: XỬ LÝ THANH TOÁN THÀNH CÔNG + CẬP NHẬT ĐIỂM
  Future<void> _handlePaymentSuccess() async {
    if (_isProcessing && !mounted) return;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ PAYMENT SUCCESS HANDLER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Order ID: ${widget.orderId}');
    print('Amount: ${widget.amount}');
    print('Used Points: ${widget.usedPoints}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // ✅ SHOW LOADING DIALOG NGẮN GỌN
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppDimensions.md),
                  Text('Đang xử lý thanh toán...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final userProvider = context.read<UserProvider>();
      final makh = userProvider.currentUser?.makh;
      final currentPoints = userProvider.currentUser?.diemthanhvien ?? 0;

      if (makh == null) {
        throw Exception('Không tìm thấy thông tin khách hàng');
      }

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🎯 POINTS CALCULATION');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Current points: $currentPoints');
      print('Points to deduct (used): ${widget.usedPoints}');
      print('Amount paid: ${widget.amount}');
      
      // ✅ TÍNH ĐIỂM TÍCH LŨY: 1000 VND = 1 điểm
      final pointsToAdd = (widget.amount / 1000).floor();
      print('Points to add (earned): $pointsToAdd');
      
      // ✅ TÍNH TỔNG ĐIỂM MỚI
      final newTotalPoints = (currentPoints - widget.usedPoints + pointsToAdd).clamp(0, 999999999);
      print('New total points: $newTotalPoints');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // ✅ GỌI API CẬP NHẬT ĐIỂM
      final khachhangApi = KhachhangApiService();
      final updateSuccess = await khachhangApi.updatePoints(makh, newTotalPoints);
      final chitiethoadon = await BookingApiService().postChitiethoadon(
        mahoadon: widget.orderId,
        madatphong: widget.madatphong,
        diemsudung: widget.usedPoints,
      );
      if (!updateSuccess) {
        throw Exception('API trả về false');
      }

      print('✅ Points updated in database!\n');

      // ✅ REFRESH USER DATA TỪ SERVER
      print('🔄 Refreshing user data...\n');
      await userProvider.refreshUserData();
      
      final updatedPoints = userProvider.currentUser?.diemthanhvien ?? newTotalPoints;
      print('✅ User data refreshed! New points: $updatedPoints\n');

      // ✅ CLOSE LOADING DIALOG
      if (mounted) {
        Navigator.of(context).pop();
      }

      // ✅ CHUYỂN THẲNG VỀ TRANG CHỦ (KHÔNG HIỂN THỊ DIALOG)
      if (mounted) {
        print('🏠 Navigating to home screen...\n');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
      }
    } catch (e) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ ERROR UPDATING POINTS');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // ✅ CLOSE LOADING DIALOG
      if (mounted) {
        Navigator.of(context).pop();
      }

      // ✅ SHOW ERROR TOAST HOẶC SNACKBAR (KHÔNG DÙNG DIALOG)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Thanh toán thành công!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Lỗi cập nhật điểm: ${e.toString()}'),
                const SizedBox(height: 4),
                const Text(
                  'Vui lòng liên hệ CSKH',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // ✅ VỀ TRANG CHỦ SAU 2 GIÂY
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          print('🏠 Navigating to home screen after error...\n');
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      }
    }
  }

  void _handlePaymentFailed({String? errorCode}) {
    if (_isProcessing && !mounted) return;

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('❌ PAYMENT FAILED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Error Code: $errorCode');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 60,
              ),
            ),
            
            const SizedBox(height: AppDimensions.lg),
            
            const Text(
              'Thanh toán thất bại!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            
            const SizedBox(height: AppDimensions.md),
            
            Text(
              errorCode != null ? 'Mã lỗi: $errorCode' : 'Giao dịch chưa hoàn tất',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppDimensions.sm),
            
            const Text(
              'Vui lòng thử lại sau',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  void _closeAndGoHome() {
    print('🏠 Closing WebView and going home...\n');
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showCancelDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Thanh toán VNPay'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showCancelDialog(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                print('🔄 Refreshing WebView...\n');
                _controller.reload();
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      SizedBox(height: AppDimensions.md),
                      Text(
                        'Đang tải trang thanh toán...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thanh toán'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy thanh toán?\n\nĐơn đặt phòng sẽ chưa được xác nhận.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.pop(context);
            },
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    print('🗑️ PaymentWebViewScreen disposed\n');
    super.dispose();
  }
}
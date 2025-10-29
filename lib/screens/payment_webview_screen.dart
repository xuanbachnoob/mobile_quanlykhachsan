import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';

/// Màn hình WebView thanh toán VNPay
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final int amount;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.amount,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessing = false; // ✅ Tránh xử lý callback nhiều lần

  @override
  void initState() {
    super.initState();
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌐 PAYMENT WEBVIEW INITIALIZED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Payment URL: ${widget.paymentUrl}');
    print('Order ID: ${widget.orderId}');
    print('Amount: ${widget.amount} VNĐ');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      
      // ✅ THÊM JAVASCRIPT CHANNEL
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (JavaScriptMessage message) {
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('📨 MESSAGE FROM WEBVIEW');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          print('Message: ${message.message}');
          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
          
          // ✅ XỬ LÝ MESSAGE TỪ HTML
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
            
            // ✅ DETECT PAYMENT CALLBACK URL
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

  // ✅ XỬ LÝ PAYMENT CALLBACK TỪ URL
  Future<void> _handlePaymentCallback(String url) async {
    if (_isProcessing) return; // Tránh xử lý nhiều lần
    
    setState(() => _isProcessing = true);

    try {
      // Parse URL parameters
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
      print('Widget Order ID: ${widget.orderId}');
      print('Widget Amount: ${widget.amount}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // ✅ NẾU LÀ MOBILE PLATFORM - ĐỢI HTML GỬI MESSAGE
      if (platform == 'mobile') {
        print('📱 Mobile platform detected - Waiting for JavaScript message...\n');
        // Không làm gì, đợi JavaScript gửi message qua channel
        setState(() => _isProcessing = false);
        return;
      }

      // ✅ NẾU KHÔNG PHẢI MOBILE - XỬ LÝ NGAY
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

  // ✅ XỬ LÝ THANH TOÁN THÀNH CÔNG
  void _handlePaymentSuccess() {
    if (_isProcessing && !mounted) return;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ PAYMENT SUCCESS HANDLER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Order ID: ${widget.orderId}');
    print('Amount: ${widget.amount}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // ✅ SHOW SUCCESS DIALOG
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ SUCCESS ICON
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              
              const SizedBox(height: AppDimensions.lg),
              
              // ✅ TITLE
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: AppDimensions.md),
              
              // ✅ THÔNG TIN
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Mã hóa đơn', '${widget.orderId}'),
                    const SizedBox(height: AppDimensions.sm),
                    _buildInfoRow('Số tiền', '${widget.amount.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (Match m) => '${m[1]},',
                    )} VNĐ'),
                  ],
                ),
              ),
              
              const SizedBox(height: AppDimensions.lg),
              
              const Text(
                'Đang chuyển về trang chủ...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // ✅ DELAY 2 GIÂY RỒI VỀ HOME
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print('🏠 Navigating to home screen...\n');
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // ✅ Route trang chủ
          (route) => false, // Remove tất cả routes
        );
      }
    });
  }

  // ✅ XỬ LÝ THANH TOÁN THẤT BẠI
  void _handlePaymentFailed({String? errorCode}) {
    if (_isProcessing && !mounted) return;
    
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('❌ PAYMENT FAILED HANDLER');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('Error Code: ${errorCode ?? "Unknown"}');
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
            // ✅ ERROR ICON
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
              Navigator.of(context).pop(); // Đóng dialog
              Navigator.of(context).pop(); // Đóng WebView
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
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

  // ✅ ĐÓNG VÀ VỀ HOME
  void _closeAndGoHome() {
    print('🏠 Closing WebView and going home...\n');
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (route) => false,
      );
    }
  }

  // ✅ BUILD INFO ROW
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
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
            // ✅ REFRESH BUTTON
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
            // ✅ WEBVIEW
            WebViewWidget(controller: _controller),
            
            // ✅ LOADING OVERLAY
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

  // ✅ CANCEL DIALOG
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
              Navigator.pop(context, true); // Close dialog
              Navigator.pop(context); // Close webview
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
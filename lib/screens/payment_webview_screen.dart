import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../screens/payment_result_screen.dart';

/// Màn hình WebView thanh toán VNPay
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderId;
  final double amount;

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

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('📄 Page Started: $url');
            
            // ✅ BẮT CALLBACK TỪ VNPAY
            // VNPay sẽ redirect về: /api/Payment/VNPayReturn?vnp_ResponseCode=...
            if (url.contains('/VNPayReturn') || url.contains('vnp_ResponseCode')) {
              _handlePaymentCallback(url);
            }
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            print('✅ Page Finished: $url');
          },
          onWebResourceError: (error) {
            print('❌ WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _handlePaymentCallback(String url) {
    print('🎯 Payment Callback: $url');

    // Parse URL parameters
    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    final vnpResponseCode = params['vnp_ResponseCode'] ?? '';
    final vnpTxnRef = params['vnp_TxnRef'] ?? '';
    final vnpOrderInfo = params['vnp_OrderInfo'] ?? '';
    final vnpAmount = params['vnp_Amount'] ?? '';

    print('✅ Response Code: $vnpResponseCode');
    print('✅ TxnRef: $vnpTxnRef');
    print('✅ OrderInfo: $vnpOrderInfo');

    // Navigate to result screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentResultScreen(
          success: vnpResponseCode == '00', // 00 = Thành công
          orderId: vnpOrderInfo.isNotEmpty ? vnpOrderInfo : widget.orderId,
          amount: widget.amount,
          transactionRef: vnpTxnRef,
          responseCode: vnpResponseCode,
        ),
      ),
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
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showCancelDialog(),
          ),
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
                      CircularProgressIndicator(),
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
}
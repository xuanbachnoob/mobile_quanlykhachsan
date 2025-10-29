// import 'package:flutter/material.dart';
// import '../config/app_colors.dart';
// import '../config/app_dimensions.dart';
// import '../config/app_text_styles.dart';
// import '../utils/currency_formatter.dart';
// import '../widgets/primary_button.dart';
// import '../screens/home_screen.dart';

// /// Màn hình kết quả thanh toán
// class PaymentResultScreen extends StatelessWidget {
//   final bool success;
//   final int orderId;
//   final int amount;
//   final String transactionRef;
//   final String responseCode;

//   const PaymentResultScreen({
//     super.key,
//     required this.success,
//     required this.orderId,
//     required this.amount,
//     required this.transactionRef,
//     required this.responseCode,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateToHome(context);
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: success ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(AppDimensions.lg),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Icon
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: success ? AppColors.success : AppColors.error,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     success ? Icons.check_circle_outline : Icons.error_outline,
//                     size: 80,
//                     color: Colors.white,
//                   ),
//                 ),

//                 const SizedBox(height: AppDimensions.xl),

//                 // Title
//                 Text(
//                   success ? 'Thanh toán thành công!' : 'Thanh toán thất bại!',
//                   style: AppTextStyles.h1.copyWith(
//                     color: success ? AppColors.success : AppColors.error,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: AppDimensions.sm),

//                 // Subtitle
//                 Text(
//                   success
//                       ? 'Đơn đặt phòng của bạn đã được xác nhận\nCảm ơn bạn đã sử dụng dịch vụ!'
//                       : 'Giao dịch không thành công\nVui lòng thử lại sau',
//                   style: AppTextStyles.body1.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: AppDimensions.xl),

//                 // Payment details
//                 Container(
//                   padding: const EdgeInsets.all(AppDimensions.lg),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _buildDetailRow('Mã đơn hàng', orderId.toString()),
//                       const Divider(height: AppDimensions.lg),
//                       _buildDetailRow('Mã giao dịch', transactionRef.isNotEmpty ? transactionRef : '-'),
//                       const Divider(height: AppDimensions.lg),
//                       _buildDetailRow(
//                         'Số tiền',
//                         '${CurrencyFormatter.format(amount)} VNĐ',
//                         valueColor: AppColors.primary,
//                       ),
//                       const Divider(height: AppDimensions.lg),
//                       _buildDetailRow(
//                         'Trạng thái',
//                         success ? 'Thành công' : 'Thất bại',
//                         valueColor: success ? AppColors.success : AppColors.error,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: AppDimensions.xl),

//                 // Buttons
//                 if (success) ...[
//                   PrimaryButton(
//                     text: 'Về trang chủ',
//                     onPressed: () => _navigateToHome(context),
//                   ),
//                   const SizedBox(height: AppDimensions.md),
//                   OutlinedButton(
//                     onPressed: () {
//                       // TODO: Navigate to booking history
//                       _navigateToHome(context);
//                     },
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.primary,
//                       side: const BorderSide(color: AppColors.primary, width: 2),
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//                       ),
//                     ),
//                     child: const Text('Xem đơn đặt phòng'),
//                   ),
//                 ] else ...[
//                   PrimaryButton(
//                     text: 'Thử lại',
//                     onPressed: () => Navigator.pop(context),
//                     backgroundColor: Color.fromARGB(255, 210, 4, 4),
//                   ),
//                   const SizedBox(height: AppDimensions.md),
//                   OutlinedButton(
//                     onPressed: () => _navigateToHome(context),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: AppColors.textSecondary,
//                       side: const BorderSide(color: AppColors.divider, width: 2),
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//                       ),
//                     ),
//                     child: const Text('Về trang chủ'),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: AppTextStyles.body2.copyWith(
//             color: AppColors.textSecondary,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: AppTextStyles.body1.copyWith(
//               fontWeight: FontWeight.w600,
//               color: valueColor,
//             ),
//             textAlign: TextAlign.end,
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   void _navigateToHome(BuildContext context) {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => const HomeScreen()),
//       (route) => false,
//     );
//   }
// }
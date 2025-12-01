import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/API/booking_api_service.dart';
import 'package:mobile_quanlykhachsan/API/payment_api_service.dart';
import 'package:mobile_quanlykhachsan/models/datphong.dart';
import 'package:mobile_quanlykhachsan/models/payment_information_model.dart';
import 'package:mobile_quanlykhachsan/providers/user_provider.dart';
import 'package:mobile_quanlykhachsan/screens/payment_webview_screen.dart';
import 'package:mobile_quanlykhachsan/widgets/points_widget.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../providers/booking_provider.dart';
import '../providers/booking_cart_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/show_message.dart';
import '../widgets/primary_button.dart';
import '../widgets/service_selection_dialog.dart';

/// Màn hình xác nhận đặt phòng
class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  int _usedPoints = 0;
  int _pointsDiscount = 0;

  void _updatePointsDiscount(int points) {
    setState(() {
      _usedPoints = points;
      _pointsDiscount = points; // 1 điểm = 1 VND
    });
  }

  void _removePointsDiscount() {
    setState(() {
      _usedPoints = 0;
      _pointsDiscount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Thông tin đặt phòng'), elevation: 0),
      body: Consumer<BookingProvider>(
        builder: (context, booking, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchInfo(booking),
                _buildSelectedRooms(context, booking),
                _buildAddServiceButton(context),
                _buildSelectedServices(context, booking),
                _buildSummary(booking),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      bottomSheet: Consumer<BookingProvider>(
        builder: (context, booking, child) {
          return _buildBottomButton(context, booking);
        },
      ),
    );
  }

  /// Search info
  Widget _buildSearchInfo(BookingProvider booking) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thông tin tìm kiếm', style: AppTextStyles.h4),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ngày nhận phòng:', style: AppTextStyles.body2),
              Text(
                booking.checkInDate != null
                    ? DateFormatter.formatDate(booking.checkInDate!)
                    : '-',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Số người:', style: AppTextStyles.body2),
              Text(
                '${booking.guestCount} người',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Selected rooms
  Widget _buildSelectedRooms(BuildContext context, BookingProvider booking) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phòng đã chọn', style: AppTextStyles.h4),
              Icon(Icons.expand_more, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...booking.selectedRooms.asMap().entries.map((entry) {
            final index = entry.key;
            final room = entry.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index < booking.selectedRooms.length - 1
                    ? AppDimensions.md
                    : 0,
              ),
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.loaiphong.Tenloaiphong,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () {
                          _removeRoom(context, room.phong.Maphong);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    'Phòng ${room.phong.Sophong}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (room.hasVoucher) ...[
                        Text(
                          '${CurrencyFormatter.format(room.loaiphong.Giacoban)} VNĐ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Row(
                        children: [
                          Text(
                            '${CurrencyFormatter.format(room.giaSauGiam)} VNĐ',
                            style: AppTextStyles.body2.copyWith(
                              color: room.hasVoucher ? Colors.red : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(' / phòng', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      if (room.hasVoucher)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_offer, size: 10, color: Colors.red.shade700),
                              const SizedBox(width: 4),
                              Text(
                                room.voucher!.tenvoucher,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Add service button
  Widget _buildAddServiceButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      child: OutlinedButton.icon(
        onPressed: () => _showServiceDialog(context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Thêm dịch vụ'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.5),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  /// Selected services
  Widget _buildSelectedServices(BuildContext context, BookingProvider booking) {
    if (booking.selectedServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        0,
        AppDimensions.md,
        AppDimensions.md,
      ),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dịch vụ đã chọn', style: AppTextStyles.h4),
              TextButton(
                onPressed: () {
                  _showClearServicesDialog(context, booking);
                },
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...booking.selectedServices.asMap().entries.map((entry) {
            final index = entry.key;
            final service = entry.value;

            return Container(
              margin: EdgeInsets.only(
                bottom: index < booking.selectedServices.length - 1
                    ? AppDimensions.sm
                    : 0,
              ),
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.dichvu.tendv,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (service.dichvu.mota != null &&
                            service.dichvu.mota!.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.xs),
                          Text(
                            service.dichvu.mota!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${CurrencyFormatter.format(service.dichvu.gia.toInt())} đ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              if (service.soluong > 1) {
                                booking.updateServiceQuantity(
                                  service.dichvu.madv,
                                  service.soluong - 1,
                                );
                              } else {
                                booking.removeService(service.dichvu.madv);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: const Icon(
                                Icons.remove,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.sm,
                            ),
                            child: Text(
                              '${service.soluong}',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              booking.updateServiceQuantity(
                                service.dichvu.madv,
                                service.soluong + 1,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSm,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Summary với Discount và Points
  Widget _buildSummary(BookingProvider booking) {
    return Consumer2<BookingCartProvider, UserProvider>(
      builder: (context, cart, userProvider, child) {
        final finalTotal = (cart.totalPrice + booking.servicesTotal.toInt() - _pointsDiscount)
            .clamp(0, double.infinity)
            .toInt();

        return Container(
          margin: const EdgeInsets.all(AppDimensions.md),
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discount banner
              if (cart.discountPercentage > 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  margin: const EdgeInsets.only(bottom: AppDimensions.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            cart.discountIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cart.discountMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tiết kiệm ${CurrencyFormatter.format(cart.discountAmount)} VNĐ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-${(cart.discountPercentage * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Discount progress
              if (cart.nextDiscountTier != null && cart.discountPercentage == 0) ...[
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  margin: const EdgeInsets.only(bottom: AppDimensions.md),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Đặt thêm ${cart.roomsNeededForNextTier} phòng để giảm ${cart.nextDiscountTier!.percentage}%',
                              style: TextStyle(
                                color: Colors.orange[900],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: cart.progressToNextTier,
                          minHeight: 5,
                          backgroundColor: Colors.orange[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange[600]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cart.roomCount}/${cart.nextDiscountTier!.minRooms} phòng',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ✅ POINTS WIDGET
              PointsWidget(
                currentPoints: userProvider.currentUser?.diemthanhvien ?? 0,
                maxAmount: (cart.totalPrice + booking.servicesTotal.toInt()),
                initialUsedPoints: _usedPoints,
                onApply: _updatePointsDiscount,
                onRemove: _removePointsDiscount,
              ),

              const SizedBox(height: AppDimensions.md),

              // Room count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng phòng:', style: AppTextStyles.body2),
                  Text(
                    '${booking.selectedRooms.length} phòng',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.sm),

              // Nights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Số đêm:', style: AppTextStyles.body2),
                  Text(
                    '${booking.numberOfNights} đêm',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              // Price details
              const Divider(height: AppDimensions.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tiền phòng:', style: AppTextStyles.body2),
                  Text(
                    '${CurrencyFormatter.format(booking.roomsTotal.toInt())} VNĐ',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              if (booking.selectedServices.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tiền dịch vụ:', style: AppTextStyles.body2),
                    Text(
                      '${CurrencyFormatter.format(booking.servicesTotal.toInt())} VNĐ',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],

              if (cart.discountPercentage > 0) ...[
                const SizedBox(height: AppDimensions.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tạm tính:', style: AppTextStyles.body2),
                    Text(
                      '${CurrencyFormatter.format((cart.subtotal + booking.servicesTotal).toInt())} VNĐ',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.lineThrough,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Giảm giá ',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.green[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${(cart.discountPercentage * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-${CurrencyFormatter.format(cart.discountAmount)} VNĐ',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ],

              // Points discount
              if (_usedPoints > 0) ...[
                const SizedBox(height: AppDimensions.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Điểm thành viên ',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.blue[700],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-$_usedPoints điểm',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-${CurrencyFormatter.format(_pointsDiscount)} VNĐ',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],

              // Total
              const Divider(height: AppDimensions.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng cộng', style: AppTextStyles.h3),
                  Text(
                    '${CurrencyFormatter.format(finalTotal)} VNĐ',
                    style: AppTextStyles.price.copyWith(fontSize: 20),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.sm),

              // Points accumulation
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 194, 239, 255),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color.fromARGB(255, 38, 150, 226),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Bạn sẽ được tích lũy ${finalTotal ~/ 1000} Điểm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 4, 118, 159),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Total savings
              if (cart.discountPercentage > 0 || _usedPoints > 0) ...[
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tổng tiết kiệm: ${CurrencyFormatter.format(cart.discountAmount + _pointsDiscount)} VNĐ!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Bottom button
  Widget _buildBottomButton(BuildContext context, BookingProvider booking) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: PrimaryButton(
          text: 'ĐẶT NGAY',
          onPressed: booking.selectedRooms.isEmpty
              ? null
              : () => _confirmBooking(context, booking),
        ),
      ),
    );
  }

  void _removeRoom(BuildContext context, int maphong) {
    final cart = context.read<BookingCartProvider>();
    final booking = context.read<BookingProvider>();

    cart.removeRoom(maphong);
    booking.setSelectedRooms(cart.selectedRooms);

    if (cart.selectedRooms.isEmpty) {
      Navigator.pop(context);
      showInfoMessage(context, 'Không còn phòng nào được chọn');
    }
  }

  void _showServiceDialog(BuildContext context) {
    showServiceSelectionDialog(context);
  }

  void _showClearServicesDialog(BuildContext context, BookingProvider booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dịch vụ'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dịch vụ đã chọn?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              booking.clearServices();
              Navigator.pop(context);
              showSuccessMessage(context, 'Đã xóa tất cả dịch vụ');
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(BuildContext context, BookingProvider booking) async {
    final userProvider = context.read<UserProvider>();
    final makh = userProvider.currentUser?.makh;

    if (makh == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi'),
          content: const Text('Vui lòng đăng nhập để đặt phòng'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
      return;
    }

    if (booking.selectedRooms.isEmpty) {
      showErrorMessage(context, 'Vui lòng chọn ít nhất 1 phòng');
      return;
    }

    if (booking.checkInDate == null || booking.checkOutDate == null) {
      showErrorMessage(context, 'Vui lòng chọn ngày nhận phòng và trả phòng');
      return;
    }

    final cart = context.read<BookingCartProvider>();
    final finalTotal = (cart.totalPrice + booking.servicesTotal.toInt() - _pointsDiscount)
        .clamp(0, double.infinity)
        .toInt();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Xác nhận đặt phòng',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn đặt ${booking.selectedRooms.length} phòng?',
                style: AppTextStyles.body1,
              ),
              const SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tiền phòng:', style: AppTextStyles.body2),
                        Text(
                          '${CurrencyFormatter.format(booking.roomsTotal.toInt())} VNĐ',
                          style: AppTextStyles.body2.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (booking.selectedServices.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tiền dịch vụ:', style: AppTextStyles.body2),
                          Text(
                            '${CurrencyFormatter.format(booking.servicesTotal.toInt())} VNĐ',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (cart.discountPercentage > 0) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Giảm giá:', style: AppTextStyles.body2),
                          Text(
                            '-${CurrencyFormatter.format(cart.discountAmount)} VNĐ',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_usedPoints > 0) ...[
                      const SizedBox(height: AppDimensions.xs),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Điểm thành viên:', style: AppTextStyles.body2),
                          Text(
                            '-${CurrencyFormatter.format(_pointsDiscount)} VNĐ',
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: AppDimensions.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng tiền:',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${CurrencyFormatter.format(finalTotal)} VNĐ',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (cart.discountPercentage > 0 || _usedPoints > 0) ...[
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        color: Colors.green[700],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tiết kiệm: ${CurrencyFormatter.format(cart.discountAmount + _pointsDiscount)} VNĐ!',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

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
                  Text('Đang xử lý đặt phòng...'),
                  SizedBox(height: AppDimensions.xs),
                  Text(
                    'Vui lòng không tắt ứng dụng',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final bookingApi = BookingApiService();
      final paymentApi = PaymentApiService();

      print('📋 Preparing booking data...');

      final datphong = Datphong(
        ngaynhanphong: booking.checkInDate!,
        ngaytraphong: booking.checkOutDate!,
        ghichu: 'Đặt qua mobile app',
        makh: makh,
        trangthai: 'Đã hủy',
        trangthaithanhtoan: 'Chưa thanh toán',
      );

      final nights = booking.checkOutDate!.difference(booking.checkInDate!).inDays;
      final rooms = booking.selectedRooms.map((selectedRoom) {
        final tongcong = selectedRoom.giaSauGiam * nights;
        return {'maphong': selectedRoom.phong.Maphong, 'tongcong': tongcong};
      }).toList();

      final services = booking.selectedServices
          .map((s) => {'madv': s.dichvu.madv, 'soluong': s.soluong})
          .toList();

      final result = await bookingApi.createFullBooking(
        datphong: datphong,
        rooms: rooms,
        services: services,
      );

      final mahoadon = result['mahoadon']!;

      print('\n💳 Creating payment URL...');

      final paymentModel = PaymentInformationModel(
        orderId: mahoadon,
        orderType: 'billpayment',
        amount: finalTotal,
        orderDescription: 'Thanh toan dat phong khach san',
        name: userProvider.currentUser?.hoten ?? 'Khach hang',
      );

      print('   - OrderId: $mahoadon');
      print('   - Amount: $finalTotal VNĐ');
      print('   - Points used: $_usedPoints ($_pointsDiscount VNĐ)');

      final paymentResponse = await paymentApi.createVnPayUrl(paymentModel);
      print('✅ Payment URL created');

      Navigator.pop(context);

      booking.clearAll();
      cart.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            paymentUrl: paymentResponse.url,
            orderId: mahoadon,
            amount: finalTotal,
            usedPoints: _usedPoints,
            madatphong: result['madatphong']!,
          ),
        ),
      );
    } catch (e) {
      print('❌ Booking failed: $e');

      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Lỗi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Không thể tạo đặt phòng:'),
              const SizedBox(height: AppDimensions.sm),
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(e.toString(), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }
}
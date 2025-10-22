import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../models/loaiphong.dart';
import '../utils/currency_formatter.dart';


/// Dialog hiển thị chi tiết loại phòng
class RoomDetailDialog extends StatefulWidget {
  final Loaiphong room;

  const RoomDetailDialog({
    super.key,
    required this.room,
  });

  @override
  State<RoomDetailDialog> createState() => _RoomDetailDialogState();
}

class _RoomDetailDialogState extends State<RoomDetailDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fake images - Thay bằng images thật từ API
    final images = [
      widget.room.HinhAnhUrl ?? 'placeholder.jpg',
      widget.room.HinhAnhUrl ?? 'placeholder.jpg',
      widget.room.HinhAnhUrl ?? 'placeholder.jpg',
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.md),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Image carousel
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.asset(
                          'assets/images/${images[index]}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.hotel,
                                size: 64,
                                color: AppColors.textHint,
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Page indicators
                    Positioned(
                      bottom: AppDimensions.md,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Room name
                      Text(
                        widget.room.Tenloaiphong,
                        style: AppTextStyles.h2,
                      ),

                      const SizedBox(height: AppDimensions.sm),

                      // Price
                      Text(
                        '${CurrencyFormatter.format(widget.room.Giacoban)} VNĐ / đêm',
                        style: AppTextStyles.price,
                      ),

                      const SizedBox(height: AppDimensions.lg),

                      // Features
                      Row(
                        children: [
                          _buildFeature(
                            Icons.king_bed_outlined,
                            '${widget.room.Sogiuong} giường',
                          ),
                          const SizedBox(width: AppDimensions.lg),
                          _buildFeature(
                            Icons.person_outline,
                            '${widget.room.Songuoitoida} người',
                          ),
                        ],
                      ),

                      const SizedBox(height: AppDimensions.lg),

                      // Description
                      Text(
                        'Mô tả',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        widget.room.Mota ?? 'Phòng được trang bị đầy đủ tiện nghi hiện đại, mang đến không gian thoải mái và sang trọng cho kỳ nghỉ của bạn.',
                        style: AppTextStyles.body2,
                      ),

                      const SizedBox(height: AppDimensions.lg),

                      // Amenities
                      Text(
                        'Tiện nghi',
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      _buildAmenities(),

                      const SizedBox(height: AppDimensions.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.xs),
        Text(
          text,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAmenities() {
    final amenities = [
      {'icon': Icons.wifi, 'name': 'WiFi miễn phí'},
      {'icon': Icons.tv, 'name': 'TV màn hình phẳng'},
      {'icon': Icons.ac_unit, 'name': 'Điều hòa'},
      {'icon': Icons.bathtub_outlined, 'name': 'Bồn tắm'},
      {'icon': Icons.restaurant, 'name': 'Minibar'},
    ];

    return Wrap(
      spacing: AppDimensions.md,
      runSpacing: AppDimensions.md,
      children: amenities.map((amenity) {
        return Container(
          width: (MediaQuery.of(context).size.width - 80) / 2,
          padding: const EdgeInsets.all(AppDimensions.sm),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                amenity['icon'] as IconData,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  amenity['name'] as String,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Show room detail dialog
void showRoomDetailDialog(BuildContext context, Loaiphong room) {
  showDialog(
    context: context,
    builder: (context) => RoomDetailDialog(room: room),
  );
}
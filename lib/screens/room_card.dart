import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../models/phongandloaiphong.dart';
import '../providers/booking_cart_provider.dart';
import '../utils/currency_formatter.dart';

/// Room card hiện đại với animations
class RoomCard extends StatefulWidget {
  final Phongandloaiphong item;

  const RoomCard({super.key, required this.item});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<BookingCartProvider>();
    final isSelected = cart.isRoomSelected(widget.item.phong.Maphong);
    final imageUrls = widget.item.hinhanhphong.imageUrls;
    if (cart.discountPercentage > 0) {
  print('Giảm ${cart.discountPercentage * 100}%');
  print('Tiết kiệm: ${cart.discountAmount} VNĐ');
}

// Hiển thị message
Text(cart.discountMessage);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 6 : 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            _buildImageCarousel(imageUrls),

            // Room info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room name
                  Text(
                    widget.item.loaiphong.Tenloaiphong,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),

                  const SizedBox(height: AppDimensions.sm),

                  // Room features
                  Row(
                    children: [
                      _buildFeatureChip(
                        Icons.king_bed_outlined,
                        '${widget.item.loaiphong.Sogiuong} giường',
                      ),
                      const SizedBox(width: AppDimensions.sm),
                      _buildFeatureChip(
                        Icons.person_outline,
                        '${widget.item.loaiphong.Songuoitoida} người',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.md),

                  // Price and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${CurrencyFormatter.format(widget.item.loaiphong.Giacoban)} VNĐ',
                              style: AppTextStyles.price,
                            ),
                            Text(
                              '/ đêm',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      _buildSelectButton(isSelected, cart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Image carousel
  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return _buildPlaceholderImage();
    }

    return Stack(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Image.asset(
                'images/${imageUrls[index]}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              );
            },
          ),
        ),

        // Page indicators
        if (imageUrls.length > 1)
          Positioned(
            bottom: AppDimensions.sm,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 220,
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.hotel,
          size: 64,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  /// Feature chip
  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Select button
  Widget _buildSelectButton(bool isSelected, BookingCartProvider cart) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        onTapCancel: () => _animationController.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Colors.grey, Colors.grey],
                  )
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? Colors.grey : AppColors.primary)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (isSelected) {
                  cart.removeRoom(widget.item.phong.Maphong);
                } else {
                  cart.addRoom(widget.item);
                }
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                  if (isSelected) const SizedBox(width: AppDimensions.xs),
                  Text(
                    isSelected ? 'Đã chọn' : 'Chọn phòng',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
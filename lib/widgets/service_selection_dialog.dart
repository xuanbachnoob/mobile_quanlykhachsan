import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';
import '../models/dichvu.dart';
import '../providers/booking_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/primary_button.dart';
import '../widgets/empty_state.dart';
import '../API/dichvu_api_service.dart';

/// Dialog chọn dịch vụ
class ServiceSelectionDialog extends StatefulWidget {
  const ServiceSelectionDialog({super.key});

  @override
  State<ServiceSelectionDialog> createState() => _ServiceSelectionDialogState();
}

class _ServiceSelectionDialogState extends State<ServiceSelectionDialog> {
  final _apiService = DichVuApiService();
  List<DichVu> _services = [];
  bool _isLoading = true;
  bool _hasError = false;
  Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadServices();
    
    // Load services đã chọn
    final booking = context.read<BookingProvider>();
    _selectedIds = booking.selectedServices
        .map((s) => s.dichvu.madv)
        .toSet();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final services = await _apiService.getAllDichVu();
      setState(() {
        _services = services;
        _isLoading = false; 
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppDimensions.md),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Chọn dịch vụ',
                      style: AppTextStyles.h3,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Flexible(
              child: _buildContent(),
            ),

            const Divider(height: 1),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: PrimaryButton(
                text: 'Lưu dịch vụ',
                onPressed: _isLoading ? null : _saveServices,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Có lỗi xảy ra',
        subtitle: 'Không thể tải danh sách dịch vụ',
        actionText: 'Thử lại',
        onAction: _loadServices,
      );
    }

    if (_services.isEmpty) {
      return const EmptyState(
        icon: Icons.room_service_outlined,
        title: 'Chưa có dịch vụ',
        subtitle: 'Hiện tại chưa có dịch vụ nào',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.md),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        final isSelected = _selectedIds.contains(service.madv);

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedIds.add(service.madv);
                } else {
                  _selectedIds.remove(service.madv);
                }
              });
            },
            title: Text(
              service.tendv,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (service.mota != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    service.mota!,
                    style: AppTextStyles.caption,
                  ),
                ],
                const SizedBox(height: AppDimensions.xs),
                Text(
                  '${CurrencyFormatter.format(service.gia.toInt())} đ',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            activeColor: AppColors.primary,
            isThreeLine: service.mota != null,
          ),
        );
      },
    );
  }

  void _saveServices() {
    final booking = context.read<BookingProvider>();
    
    // Remove unselected services
    final toRemove = booking.selectedServices
        .where((s) => !_selectedIds.contains(s.dichvu.madv))
        .map((s) => s.dichvu.madv)
        .toList();
    
    for (var id in toRemove) {
      booking.removeService(id);
    }
    
    // Add new selected services
    for (var service in _services) {
      if (_selectedIds.contains(service.madv)) {
        final existing = booking.selectedServices
            .where((s) => s.dichvu.madv == service.madv);
        if (existing.isEmpty) {
          booking.addService(service);
        }
      }
    }
    
    Navigator.pop(context);
  }
}

/// Show service selection dialog
void showServiceSelectionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ServiceSelectionDialog(),
  );
}
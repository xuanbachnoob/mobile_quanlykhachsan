import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_dimensions.dart';
import '../config/app_text_styles.dart';

/// Text field tùy chỉnh với floating label và validation
class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: _errorText != null
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : AppColors.divider,
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Focus(
            onFocusChange: (focused) {
              setState(() {
                _isFocused = focused;
              });
            },
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              style: AppTextStyles.body1,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                labelStyle: AppTextStyles.body2.copyWith(
                  color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                ),
                hintStyle: AppTextStyles.body2.copyWith(
                  color: AppColors.textHint,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused ? AppColors.primary : AppColors.textSecondary,
                        size: AppDimensions.iconSm,
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? IconButton(
                        icon: Icon(
                          widget.suffixIcon,
                          color: AppColors.textSecondary,
                          size: AppDimensions.iconSm,
                        ),
                        onPressed: widget.onSuffixTap,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.md,
                ),
                errorStyle: const TextStyle(height: 0),
              ),
              validator: (value) {
                if (widget.validator != null) {
                  final error = widget.validator!(value);
                  setState(() {
                    _errorText = error;
                  });
                  return error;
                }
                return null;
              },
              onChanged: widget.onChanged,
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppDimensions.xs),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: AppDimensions.xs),
              Expanded(
                child: Text(
                  _errorText!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
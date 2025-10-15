// lib/presentation/widgets/common/custom_button.dart
import 'package:flutter/material.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'package:koa_app/core/constants/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimary;
  final bool isExpanded;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isPrimary = true,
    this.isExpanded = true,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isPrimary ? Colors.white : AppColors.primaryGreen,
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20,
                  color: isPrimary ? Colors.white : AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isPrimary
                      ? Colors.white
                      : textColor ?? AppColors.primaryGreen,
                ),
              ),
            ],
          );

    return Container(
      width: isExpanded ? double.infinity : null,
      height: AppConstants.buttonHeight,
      decoration: isPrimary
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColor != null
                    ? [backgroundColor!, backgroundColor!]
                    : [AppColors.primaryGreen, AppColors.greenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.transparent,
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              border: Border.all(
                  color: backgroundColor ?? AppColors.primaryGreen, width: 2),
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Center(child: buttonChild),
        ),
      ),
    );
  }
}

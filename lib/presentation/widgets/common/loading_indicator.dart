// lib/presentation/widgets/common/loading_indicator.dart
import 'package:flutter/material.dart';
import 'package:koa_app/core/theme/colors.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.color = AppColors.primaryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

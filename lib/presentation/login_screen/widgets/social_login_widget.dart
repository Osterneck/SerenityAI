import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? onGooglePressed;
  final VoidCallback? onApplePressed;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    this.onGooglePressed,
    this.onApplePressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                context,
                icon: 'g_translate',
                label: 'Google',
                onPressed: isLoading ? null : onGooglePressed,
                backgroundColor: Colors.white,
                textColor: AppTheme.lightTheme.colorScheme.onSurface,
                borderColor: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildSocialButton(
                context,
                icon: 'apple',
                label: 'Apple',
                onPressed: isLoading ? null : onApplePressed,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    VoidCallback? onPressed,
  }) {
    return Container(
      height: 6.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 20,
              color: textColor,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

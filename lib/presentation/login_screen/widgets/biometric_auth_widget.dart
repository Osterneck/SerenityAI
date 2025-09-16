import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class BiometricAuthWidget extends StatelessWidget {
  final VoidCallback? onBiometricPressed;
  final bool isLoading;

  const BiometricAuthWidget({
    Key? key,
    this.onBiometricPressed,
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
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBiometricButton(
              context,
              icon: 'fingerprint',
              label: 'Touch ID',
              onPressed: isLoading ? null : onBiometricPressed,
            ),
            _buildBiometricButton(
              context,
              icon: 'face',
              label: 'Face ID',
              onPressed: isLoading ? null : onBiometricPressed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiometricButton(
    BuildContext context, {
    required String icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 35.w,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          side: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

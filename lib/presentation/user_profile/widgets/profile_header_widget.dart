import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String userName;
  final String joinDate;
  final String subscriptionStatus;
  final String avatarUrl;
  final VoidCallback onAvatarTap;
  final VoidCallback onUpgradeTap;

  const ProfileHeaderWidget({
    Key? key,
    required this.userName,
    required this.joinDate,
    required this.subscriptionStatus,
    required this.avatarUrl,
    required this.onAvatarTap,
    required this.onUpgradeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPremium = subscriptionStatus.toLowerCase() != 'free';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.lightTheme.primaryColor,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: avatarUrl,
                  width: 25.w,
                  height: 25.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // User Name
          Text(
            userName,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Join Date
          Text(
            'Member since $joinDate',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Subscription Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isPremium
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : AppTheme.warningLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPremium
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.warningLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: isPremium ? 'star' : 'star_border',
                  color: isPremium
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.warningLight,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  subscriptionStatus,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isPremium
                        ? AppTheme.lightTheme.primaryColor
                        : AppTheme.warningLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Upgrade Button for Free Users
          if (!isPremium) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onUpgradeTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'upgrade',
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Upgrade to Premium',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

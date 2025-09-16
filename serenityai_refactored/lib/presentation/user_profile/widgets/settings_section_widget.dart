import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final Function(String) onSettingTap;

  const SettingsSectionWidget({
    Key? key,
    required this.onSettingTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsGroups = [
      {
        'title': 'Account',
        'items': [
          {
            'title': 'Email & Password',
            'subtitle': 'Update your login credentials',
            'icon': 'email',
            'action': 'email_password',
          },
          {
            'title': 'Notifications',
            'subtitle': 'Manage your notification preferences',
            'icon': 'notifications',
            'action': 'notifications',
          },
        ],
      },
      {
        'title': 'Privacy',
        'items': [
          {
            'title': 'Data Sharing',
            'subtitle': 'Control how your data is shared',
            'icon': 'share',
            'action': 'data_sharing',
          },
          {
            'title': 'Anonymous Mode',
            'subtitle': 'Hide your identity in community',
            'icon': 'visibility_off',
            'action': 'anonymous_mode',
          },
        ],
      },
      {
        'title': 'Preferences',
        'items': [
          {
            'title': 'Meditation Reminders',
            'subtitle': 'Set daily meditation reminders',
            'icon': 'schedule',
            'action': 'reminders',
          },
          {
            'title': 'App Theme',
            'subtitle': 'Choose light or dark theme',
            'icon': 'palette',
            'action': 'theme',
          },
        ],
      },
      {
        'title': 'Support',
        'items': [
          {
            'title': 'Help Center',
            'subtitle': 'Find answers to common questions',
            'icon': 'help',
            'action': 'help_center',
          },
          {
            'title': 'Contact Us',
            'subtitle': 'Get in touch with our support team',
            'icon': 'contact_support',
            'action': 'contact_us',
          },
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Settings',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ...settingsGroups.map((group) => _buildSettingsGroup(group)).toList(),
      ],
    );
  }

  Widget _buildSettingsGroup(Map<String, dynamic> group) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
            child: Text(
              group['title'],
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ),
          ...((group['items'] as List).asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == (group['items'] as List).length - 1;

            return Column(
              children: [
                ListTile(
                  onTap: () => onSettingTap(item['action']),
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: item['icon'],
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item['title'],
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryLight,
                    ),
                  ),
                  trailing: CustomIconWidget(
                    iconName: 'chevron_right',
                    color: AppTheme.textSecondaryLight,
                    size: 20,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.borderLight,
                    indent: 16.w,
                    endIndent: 4.w,
                  ),
              ],
            );
          }).toList()),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}

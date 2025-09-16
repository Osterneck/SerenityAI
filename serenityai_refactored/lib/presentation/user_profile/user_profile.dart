import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:serenityai/core/app_export.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/progress_cards_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/subscription_management_widget.dart';
import './widgets/weekly_progress_chart_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _currentIndex = 4; // Profile tab active
  bool _isDarkMode = false;

  // Mock user data
  final Map<String, dynamic> userData = {
    "id": 1,
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "joinDate": "January 2024",
    "subscriptionStatus": "Premium",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=400&ixlib=rb-4.0.3",
    "meditationMinutes": 1250,
    "currentStreak": 42,
    "moodEntries": 156,
    "communityPosts": 23,
  };

  final Map<String, dynamic> subscriptionData = {
    "plan": "Premium",
    "cost": "\$9.99",
    "nextBilling": "September 23, 2025",
    "autoRenewal": true,
  };

  final List<Map<String, dynamic>> achievements = [
    {
      "id": 1,
      "title": "First Steps",
      "description": "Complete your first meditation",
      "icon": "self_improvement",
      "unlocked": true,
      "unlockedDate": "2024-01-15",
    },
    {
      "id": 2,
      "title": "Week Warrior",
      "description": "Meditate for 7 days straight",
      "icon": "local_fire_department",
      "unlocked": true,
      "unlockedDate": "2024-02-01",
    },
    {
      "id": 3,
      "title": "Mood Master",
      "description": "Log 100 mood entries",
      "icon": "mood",
      "unlocked": true,
      "unlockedDate": "2024-06-15",
    },
    {
      "id": 4,
      "title": "Community Helper",
      "description": "Make 50 community posts",
      "icon": "forum",
      "unlocked": false,
      "unlockedDate": null,
    },
    {
      "id": 5,
      "title": "Zen Master",
      "description": "Meditate for 1000 minutes",
      "icon": "emoji_events",
      "unlocked": true,
      "unlockedDate": "2024-07-20",
    },
    {
      "id": 6,
      "title": "Consistency King",
      "description": "Maintain a 30-day streak",
      "icon": "trending_up",
      "unlocked": true,
      "unlockedDate": "2024-08-10",
    },
  ];

  final List<Map<String, dynamic>> weeklyData = [
    {"day": "Monday", "minutes": 25},
    {"day": "Tuesday", "minutes": 30},
    {"day": "Wednesday", "minutes": 15},
    {"day": "Thursday", "minutes": 45},
    {"day": "Friday", "minutes": 20},
    {"day": "Saturday", "minutes": 35},
    {"day": "Sunday", "minutes": 40},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _handleSettingTap('theme'),
            icon: CustomIconWidget(
              iconName: _isDarkMode ? 'light_mode' : 'dark_mode',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () => _handleSettingTap('settings'),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.primaryColor,
              size: 24,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Profile Header
            ProfileHeaderWidget(
              userName: userData['name'],
              joinDate: userData['joinDate'],
              subscriptionStatus: userData['subscriptionStatus'],
              avatarUrl: userData['avatar'],
              onAvatarTap: _handleAvatarTap,
              onUpgradeTap: _handleUpgrade,
            ),

            SizedBox(height: 3.h),

            // Progress Cards
            ProgressCardsWidget(
              meditationMinutes: userData['meditationMinutes'],
              currentStreak: userData['currentStreak'],
              moodEntries: userData['moodEntries'],
              communityPosts: userData['communityPosts'],
            ),

            SizedBox(height: 3.h),

            // Achievement Badges
            AchievementBadgesWidget(
              achievements: achievements,
              onBadgeTap: _handleBadgeTap,
            ),

            SizedBox(height: 3.h),

            // Weekly Progress Chart
            WeeklyProgressChartWidget(
              weeklyData: weeklyData,
            ),

            SizedBox(height: 3.h),

            // Subscription Management
            SubscriptionManagementWidget(
              subscriptionData: subscriptionData,
              onManageSubscription: _handleManageSubscription,
              onCancelSubscription: _handleCancelSubscription,
            ),

            SizedBox(height: 3.h),

            // Settings Section
            SettingsSectionWidget(
              onSettingTap: _handleSettingTap,
            ),

            SizedBox(height: 3.h),

            // Data Export & Account Deletion
            _buildDataActionsSection(),

            SizedBox(height: 4.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDataActionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data & Account',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Export Data
          ListTile(
            onTap: _handleDataExport,
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.successLight,
                size: 20,
              ),
            ),
            title: Text(
              'Export My Data',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Download your wellness data in CSV format',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textSecondaryLight,
              size: 20,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          Divider(
            height: 3.h,
            thickness: 1,
            color: AppTheme.borderLight,
          ),

          // Delete Account
          ListTile(
            onTap: _handleAccountDeletion,
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'delete_forever',
                color: AppTheme.errorLight,
                size: 20,
              ),
            ),
            title: Text(
              'Delete Account',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.errorLight,
              ),
            ),
            subtitle: Text(
              'Permanently delete your account and data',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryLight,
              ),
            ),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.textSecondaryLight,
              size: 20,
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _handleBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondaryLight,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: _currentIndex == 0
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textSecondaryLight,
            size: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'mood',
            color: _currentIndex == 1
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textSecondaryLight,
            size: 24,
          ),
          label: 'Mood',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'self_improvement',
            color: _currentIndex == 2
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textSecondaryLight,
            size: 24,
          ),
          label: 'Meditate',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'forum',
            color: _currentIndex == 3
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textSecondaryLight,
            size: 24,
          ),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentIndex == 4
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.textSecondaryLight,
            size: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home-dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/mood-tracking');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/meditation-player');
        break;
      case 3:
        // Community screen navigation would go here
        Fluttertoast.showToast(
          msg: "Community feature coming soon!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
      case 4:
        // Already on profile screen
        break;
    }
  }

  void _handleAvatarTap() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Change Profile Picture',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPhotoOption(
                  'Camera',
                  'camera_alt',
                  () {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Camera feature would open here",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
                _buildPhotoOption(
                  'Gallery',
                  'photo_library',
                  () {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Gallery feature would open here",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.primaryColor,
              size: 32,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    Fluttertoast.showToast(
      msg: "Redirecting to subscription upgrade...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleBadgeTap(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: achievement['icon'] ?? 'emoji_events',
              color: achievement['unlocked']
                  ? AppTheme.accentLight
                  : AppTheme.textDisabledLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                achievement['title'],
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement['description'],
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            if (achievement['unlocked'] &&
                achievement['unlockedDate'] != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.successLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Unlocked on ${achievement['unlockedDate']}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleSettingTap(String action) {
    switch (action) {
      case 'theme':
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
        Fluttertoast.showToast(
          msg: _isDarkMode ? "Dark mode enabled" : "Light mode enabled",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
      case 'settings':
      case 'email_password':
      case 'notifications':
      case 'data_sharing':
      case 'anonymous_mode':
      case 'reminders':
      case 'help_center':
      case 'contact_us':
        Fluttertoast.showToast(
          msg: "Opening ${action.replaceAll('_', ' ')} settings...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        break;
    }
  }

  void _handleManageSubscription() {
    Fluttertoast.showToast(
      msg: "Opening subscription management...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleCancelSubscription() {
    Fluttertoast.showToast(
      msg: "Subscription cancellation processed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _handleDataExport() async {
    try {
      // Create wellness data export
      final Map<String, dynamic> exportData = {
        'user_profile': {
          'name': userData['name'],
          'email': userData['email'],
          'join_date': userData['joinDate'],
          'subscription_status': userData['subscriptionStatus'],
        },
        'meditation_stats': {
          'total_minutes': userData['meditationMinutes'],
          'current_streak': userData['currentStreak'],
          'weekly_data': weeklyData,
        },
        'mood_tracking': {
          'total_entries': userData['moodEntries'],
          'sample_entries': [
            {
              'date': '2024-08-20',
              'mood': 'Happy',
              'notes': 'Great meditation session'
            },
            {'date': '2024-08-21', 'mood': 'Calm', 'notes': 'Feeling peaceful'},
            {
              'date': '2024-08-22',
              'mood': 'Energetic',
              'notes': 'Morning workout helped'
            },
          ],
        },
        'achievements': achievements,
        'community_activity': {
          'total_posts': userData['communityPosts'],
          'sample_posts': [
            {
              'date': '2024-08-15',
              'content': 'Just completed my 30-day streak!'
            },
            {
              'date': '2024-08-10',
              'content': 'Loving the new breathing exercises'
            },
          ],
        },
        'export_info': {
          'generated_on': DateTime.now().toIso8601String(),
          'format_version': '1.0',
          'data_retention_policy':
              'Data will be retained according to our privacy policy',
        },
      };

      final String csvContent = _convertToCSV(exportData);
      final String filename =
          'serenity_ai_wellness_data_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        // Web download
        final bytes = utf8.encode(csvContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile would save to documents directory
        Fluttertoast.showToast(
          msg: "Data export would be saved to device storage",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }

      Fluttertoast.showToast(
        msg: "Wellness data exported successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Export failed. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  String _convertToCSV(Map<String, dynamic> data) {
    final StringBuffer csv = StringBuffer();

    // Header
    csv.writeln('SerenityAI Wellness Data Export');
    csv.writeln('Generated on: ${DateTime.now().toString()}');
    csv.writeln('');

    // User Profile
    csv.writeln('USER PROFILE');
    csv.writeln('Name,Email,Join Date,Subscription');
    csv.writeln(
        '${data['user_profile']['name']},${data['user_profile']['email']},${data['user_profile']['join_date']},${data['user_profile']['subscription_status']}');
    csv.writeln('');

    // Meditation Stats
    csv.writeln('MEDITATION STATISTICS');
    csv.writeln('Total Minutes,Current Streak');
    csv.writeln(
        '${data['meditation_stats']['total_minutes']},${data['meditation_stats']['current_streak']}');
    csv.writeln('');

    // Weekly Data
    csv.writeln('WEEKLY MEDITATION DATA');
    csv.writeln('Day,Minutes');
    for (var day in data['meditation_stats']['weekly_data']) {
      csv.writeln('${day['day']},${day['minutes']}');
    }
    csv.writeln('');

    // Achievements
    csv.writeln('ACHIEVEMENTS');
    csv.writeln('Title,Description,Unlocked,Date');
    for (var achievement in data['achievements']) {
      csv.writeln(
          '${achievement['title']},${achievement['description']},${achievement['unlocked']},${achievement['unlockedDate'] ?? 'N/A'}');
    }

    return csv.toString();
  }

  void _handleAccountDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.errorLight,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Delete Account',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.errorLight,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All your data will be permanently deleted including:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ...[
              'Meditation history and progress',
              'Mood tracking data',
              'Community posts and interactions',
              'Achievement badges',
              'Subscription information'
            ]
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'circle',
                          color: AppTheme.errorLight,
                          size: 8,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorLight,
                  width: 1,
                ),
              ),
              child: Text(
                'We recommend exporting your data before deletion if you want to keep a copy of your wellness journey.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorLight,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                msg: "Account deletion would be processed here",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete Account',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

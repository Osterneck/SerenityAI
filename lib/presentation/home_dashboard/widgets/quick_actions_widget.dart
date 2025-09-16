import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> quickActions = const [
    {
      "id": 1,
      "title": "Breathing",
      "subtitle": "4-7-8 Exercise",
      "icon": "air",
      "color": 0xFF10B981,
      "route": "/breathing-exercises"
    },
    {
      "id": 2,
      "title": "Community",
      "subtitle": "Connect & Share",
      "icon": "groups",
      "color": 0xFF3B82F6,
      "route": "/community-forums"
    },
    {
      "id": 3,
      "title": "Library",
      "subtitle": "Browse Sessions",
      "icon": "library_music",
      "color": 0xFF8B5CF6,
      "route": "/meditation-library"
    },
  ];

  void _handleActionTap(BuildContext context, Map<String, dynamic> action) {
    // Navigate to the respective screen
    Navigator.pushNamed(context, action['route']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Text(
              'Quick Actions',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: quickActions.map((action) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  child: GestureDetector(
                    onTap: () => _handleActionTap(context, action),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              color:
                                  Color(action['color']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: action['icon'],
                                color: Color(action['color']),
                                size: 24,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            action['title'],
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            action['subtitle'],
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

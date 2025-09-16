import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class ProgressCardsWidget extends StatefulWidget {
  final int meditationMinutes;
  final int currentStreak;
  final int moodEntries;
  final int communityPosts;

  const ProgressCardsWidget({
    Key? key,
    required this.meditationMinutes,
    required this.currentStreak,
    required this.moodEntries,
    required this.communityPosts,
  }) : super(key: key);

  @override
  State<ProgressCardsWidget> createState() => _ProgressCardsWidgetState();
}

class _ProgressCardsWidgetState extends State<ProgressCardsWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
        4,
        (index) => AnimationController(
              duration: Duration(milliseconds: 800 + (index * 200)),
              vsync: this,
            ));

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut)))
        .toList();

    // Start animations with staggered delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> progressData = [
      {
        'title': 'Meditation Minutes',
        'value': widget.meditationMinutes.toString(),
        'icon': 'self_improvement',
        'color': AppTheme.lightTheme.primaryColor,
        'milestone': widget.meditationMinutes >= 1000,
      },
      {
        'title': 'Current Streak',
        'value': '${widget.currentStreak} days',
        'icon': 'local_fire_department',
        'color': AppTheme.accentLight,
        'milestone': widget.currentStreak >= 30,
      },
      {
        'title': 'Mood Entries',
        'value': widget.moodEntries.toString(),
        'icon': 'mood',
        'color': AppTheme.successLight,
        'milestone': widget.moodEntries >= 100,
      },
      {
        'title': 'Community Posts',
        'value': widget.communityPosts.toString(),
        'icon': 'forum',
        'color': AppTheme.secondaryLight,
        'milestone': widget.communityPosts >= 50,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Your Progress',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.1,
          ),
          itemCount: progressData.length,
          itemBuilder: (context, index) {
            final data = progressData[index];
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _animations[index].value,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: data['milestone']
                          ? Border.all(
                              color: data['color'],
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: data['color'].withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: data['icon'],
                                color: data['color'],
                                size: 24,
                              ),
                            ),
                            if (data['milestone'])
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'celebration',
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          data['value'],
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: data['color'],
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          data['title'],
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

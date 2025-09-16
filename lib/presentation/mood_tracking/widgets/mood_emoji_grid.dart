import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/theme/app_theme.dart';

class MoodEmojiGrid extends StatefulWidget {
  final Function(int) onMoodSelected;
  final int? selectedMood;

  const MoodEmojiGrid({
    Key? key,
    required this.onMoodSelected,
    this.selectedMood,
  }) : super(key: key);

  @override
  State<MoodEmojiGrid> createState() => _MoodEmojiGridState();
}

class _MoodEmojiGridState extends State<MoodEmojiGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😢', 'label': 'Very Sad', 'value': 1},
    {'emoji': '😔', 'label': 'Sad', 'value': 2},
    {'emoji': '😐', 'label': 'Neutral', 'value': 3},
    {'emoji': '🙂', 'label': 'Happy', 'value': 4},
    {'emoji': '😄', 'label': 'Very Happy', 'value': 5},
    {'emoji': '😰', 'label': 'Anxious', 'value': 6},
    {'emoji': '😴', 'label': 'Tired', 'value': 7},
    {'emoji': '😌', 'label': 'Calm', 'value': 8},
    {'emoji': '⚡', 'label': 'Energetic', 'value': 9},
    {'emoji': '🤯', 'label': 'Overwhelmed', 'value': 10},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onMoodTap(int moodValue) {
    HapticFeedback.mediumImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onMoodSelected(moodValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 2.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 0.8,
            ),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = widget.selectedMood == mood['value'];

              return GestureDetector(
                onTap: () => _onMoodTap(mood['value']),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mood['emoji'],
                              style: TextStyle(fontSize: 20.sp),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              mood['label'],
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 8.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

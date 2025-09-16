import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class EmotionTagsSection extends StatefulWidget {
  final Function(List<String>) onEmotionsSelected;
  final List<String> selectedEmotions;

  const EmotionTagsSection({
    Key? key,
    required this.onEmotionsSelected,
    required this.selectedEmotions,
  }) : super(key: key);

  @override
  State<EmotionTagsSection> createState() => _EmotionTagsSectionState();
}

class _EmotionTagsSectionState extends State<EmotionTagsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  final List<Map<String, dynamic>> emotions = [
    {'label': 'Anxious', 'color': Color(0xFFFF6B6B)},
    {'label': 'Stressed', 'color': Color(0xFFFF8E53)},
    {'label': 'Calm', 'color': Color(0xFF4ECDC4)},
    {'label': 'Energetic', 'color': Color(0xFF45B7D1)},
    {'label': 'Overwhelmed', 'color': Color(0xFF96CEB4)},
    {'label': 'Focused', 'color': Color(0xFF9B59B6)},
    {'label': 'Tired', 'color': Color(0xFF95A5A6)},
    {'label': 'Excited', 'color': Color(0xFFF39C12)},
    {'label': 'Peaceful', 'color': Color(0xFF3498DB)},
    {'label': 'Frustrated', 'color': Color(0xFFE74C3C)},
    {'label': 'Grateful', 'color': Color(0xFF2ECC71)},
    {'label': 'Lonely', 'color': Color(0xFF8E44AD)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _toggleEmotion(String emotion) {
    List<String> updatedEmotions = List.from(widget.selectedEmotions);
    if (updatedEmotions.contains(emotion)) {
      updatedEmotions.remove(emotion);
    } else {
      updatedEmotions.add(emotion);
    }
    widget.onEmotionsSelected(updatedEmotions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'How are you feeling?',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: Duration(milliseconds: 300),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
                    child: Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: emotions.map((emotion) {
                        final isSelected =
                            widget.selectedEmotions.contains(emotion['label']);
                        return GestureDetector(
                          onTap: () => _toggleEmotion(emotion['label']),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? emotion['color']
                                  : emotion['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: emotion['color'],
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              emotion['label'],
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : emotion['color'],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

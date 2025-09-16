import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class MoodCalendarView extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  const MoodCalendarView({
    Key? key,
    required this.onDateSelected,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<MoodCalendarView> createState() => _MoodCalendarViewState();
}

class _MoodCalendarViewState extends State<MoodCalendarView> {
  late DateTime _currentMonth;
  late PageController _pageController;

  final Map<DateTime, Map<String, dynamic>> mockMoodData = {
    DateTime(2025, 8, 20): {'mood': 4, 'color': Color(0xFF4ECDC4)},
    DateTime(2025, 8, 21): {'mood': 3, 'color': Color(0xFFFFA726)},
    DateTime(2025, 8, 22): {'mood': 2, 'color': Color(0xFFFF6B6B)},
    DateTime(2025, 8, 23): {'mood': 4, 'color': Color(0xFF4ECDC4)},
    DateTime(2025, 8, 19): {'mood': 5, 'color': Color(0xFF66BB6A)},
    DateTime(2025, 8, 18): {'mood': 3, 'color': Color(0xFFFFA726)},
    DateTime(2025, 8, 17): {'mood': 4, 'color': Color(0xFF4ECDC4)},
  };

  @override
  void initState() {
    super.initState();
    _currentMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    List<DateTime> days = [];

    // Add empty days for proper week alignment
    final firstWeekday = firstDay.weekday % 7;
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0));
    }

    // Add actual days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Color(0xFFFF6B6B);
      case 2:
        return Color(0xFFFF8E53);
      case 3:
        return Color(0xFFFFA726);
      case 4:
        return Color(0xFF4ECDC4);
      case 5:
        return Color(0xFF66BB6A);
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _previousMonth,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'chevron_left',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                Text(
                  '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'chevron_right',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Calendar Grid
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                if (day.year == 0) {
                  return Container(); // Empty cell
                }

                final isToday = day.day == DateTime.now().day &&
                    day.month == DateTime.now().month &&
                    day.year == DateTime.now().year;

                final isSelected = day.day == widget.selectedDate.day &&
                    day.month == widget.selectedDate.month &&
                    day.year == widget.selectedDate.year;

                final moodData = mockMoodData[day];
                final hasMood = moodData != null;

                return GestureDetector(
                  onTap: () => widget.onDateSelected(day),
                  child: Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : (isToday
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            day.day.toString(),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.lightTheme.colorScheme.onSurface,
                              fontWeight:
                                  isToday ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (hasMood)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 4.w,
                              height: 4.w,
                              decoration: BoxDecoration(
                                color: moodData['color'],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  _getMoodEmoji(moodData['mood']),
                                  style: TextStyle(fontSize: 8.sp),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

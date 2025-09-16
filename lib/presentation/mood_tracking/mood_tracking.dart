import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import './widgets/ai_insights_panel.dart';
import './widgets/emotion_tags_section.dart';
import './widgets/journal_entry_section.dart';
import './widgets/mood_calendar_view.dart';
import './widgets/mood_emoji_grid.dart';
import './widgets/voice_note_recorder.dart';

class MoodTracking extends StatefulWidget {
  const MoodTracking({Key? key}) : super(key: key);

  @override
  State<MoodTracking> createState() => _MoodTrackingState();
}

class _MoodTrackingState extends State<MoodTracking>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _saveButtonController;
  late Animation<double> _saveButtonAnimation;

  int? _selectedMood;
  List<String> _selectedEmotions = [];
  String _journalText = '';
  String? _voiceNotePath;
  DateTime _selectedDate = DateTime.now();
  bool _showCalendar = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _saveButtonController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _saveButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _saveButtonController,
      curve: Curves.easeInOut,
    ));

    _checkSaveButtonVisibility();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _saveButtonController.dispose();
    super.dispose();
  }

  void _checkSaveButtonVisibility() {
    if (_selectedMood != null) {
      _saveButtonController.forward();
    } else {
      _saveButtonController.reverse();
    }
  }

  void _onMoodSelected(int mood) {
    setState(() {
      _selectedMood = mood;
    });
    _checkSaveButtonVisibility();
  }

  void _onEmotionsSelected(List<String> emotions) {
    setState(() {
      _selectedEmotions = emotions;
    });
  }

  void _onJournalTextChanged(String text) {
    setState(() {
      _journalText = text;
    });
  }

  void _onVoiceNoteRecorded(String? path) {
    setState(() {
      _voiceNotePath = path;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _showCalendar = false;
    });
    // Load mood data for selected date
    _loadMoodDataForDate(date);
  }

  void _loadMoodDataForDate(DateTime date) {
    // Simulate loading mood data for the selected date
    // In a real app, this would fetch from a database
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Reset form for new date
          if (date.day != DateTime.now().day) {
            _selectedMood = null;
            _selectedEmotions = [];
            _journalText = '';
            _voiceNotePath = null;
          }
        });
        _checkSaveButtonVisibility();
      }
    });
  }

  void _previousDay() {
    final previousDay = _selectedDate.subtract(Duration(days: 1));
    _onDateSelected(previousDay);
  }

  void _nextDay() {
    final nextDay = _selectedDate.add(Duration(days: 1));
    if (nextDay.isBefore(DateTime.now().add(Duration(days: 1)))) {
      _onDateSelected(nextDay);
    }
  }

  void _toggleCalendarView() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
  }

  Future<void> _saveMoodEntry() async {
    if (_selectedMood == null) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(Duration(milliseconds: 1000));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text('Mood entry saved successfully!'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back or show success animation
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  void _showCrisisSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'support_agent',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text('Crisis Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you\'re experiencing a mental health crisis, please reach out for immediate help:',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            _buildCrisisContact('National Suicide Prevention Lifeline', '988'),
            _buildCrisisContact('Crisis Text Line', 'Text HOME to 741741'),
            _buildCrisisContact('Emergency Services', '911'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisContact(String name, String contact) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            contact,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                      Text(
                        'Mood Tracking',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showCrisisSupport,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'help',
                            color: AppTheme.lightTheme.colorScheme.error,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Date Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _previousDay,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: 'chevron_left',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleCalendarView,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: _isToday(_selectedDate)
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isToday(_selectedDate)
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'calendar_today',
                                color: _isToday(_selectedDate)
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                _isToday(_selectedDate)
                                    ? 'Today'
                                    : _formatDate(_selectedDate),
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: _isToday(_selectedDate)
                                      ? Colors.white
                                      : AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _nextDay,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: 'chevron_right',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          AppTheme.lightTheme.colorScheme.primary,
                      labelStyle:
                          AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle:
                          AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(text: 'Track Mood'),
                        Tab(text: 'Calendar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Loading...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Track Mood Tab
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 2.h),
                              MoodEmojiGrid(
                                onMoodSelected: _onMoodSelected,
                                selectedMood: _selectedMood,
                              ),
                              EmotionTagsSection(
                                onEmotionsSelected: _onEmotionsSelected,
                                selectedEmotions: _selectedEmotions,
                              ),
                              JournalEntrySection(
                                onTextChanged: _onJournalTextChanged,
                                initialText: _journalText,
                              ),
                              VoiceNoteRecorder(
                                onRecordingComplete: _onVoiceNoteRecorded,
                              ),
                              AiInsightsPanel(
                                selectedMood: _selectedMood,
                                selectedEmotions: _selectedEmotions,
                              ),
                              SizedBox(
                                  height: 10.h), // Space for floating button
                            ],
                          ),
                        ),

                        // Calendar Tab
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: 2.h),
                              MoodCalendarView(
                                onDateSelected: _onDateSelected,
                                selectedDate: _selectedDate,
                              ),
                              SizedBox(height: 2.h),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // Floating Save Button
      floatingActionButton: AnimatedBuilder(
        animation: _saveButtonAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _saveButtonAnimation.value,
            child: _saveButtonAnimation.value > 0
                ? FloatingActionButton.extended(
                    onPressed: _isLoading ? null : _saveMoodEntry,
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'save',
                            color: Colors.white,
                            size: 20,
                          ),
                    label: Text(
                      _isLoading ? 'Saving...' : 'Save Entry',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

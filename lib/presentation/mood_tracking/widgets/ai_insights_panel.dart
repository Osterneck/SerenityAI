import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class AiInsightsPanel extends StatefulWidget {
  final int? selectedMood;
  final List<String> selectedEmotions;

  const AiInsightsPanel({
    Key? key,
    this.selectedMood,
    required this.selectedEmotions,
  }) : super(key: key);

  @override
  State<AiInsightsPanel> createState() => _AiInsightsPanelState();
}

class _AiInsightsPanelState extends State<AiInsightsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> mockInsights = [
    {
      'title': 'Weekly Pattern',
      'description': 'You tend to feel more stressed on Mondays and Tuesdays',
      'icon': 'trending_up',
      'color': Color(0xFFFF6B6B),
    },
    {
      'title': 'Mood Improvement',
      'description': 'Your overall mood has improved by 15% this week',
      'icon': 'mood',
      'color': Color(0xFF4ECDC4),
    },
    {
      'title': 'Sleep Connection',
      'description': 'Better sleep correlates with your calmer days',
      'icon': 'bedtime',
      'color': Color(0xFF45B7D1),
    },
  ];

  final List<Map<String, dynamic>> weeklyMoodData = [
    {'day': 'Mon', 'mood': 2.5, 'color': Color(0xFFFF6B6B)},
    {'day': 'Tue', 'mood': 2.8, 'color': Color(0xFFFF8E53)},
    {'day': 'Wed', 'mood': 3.5, 'color': Color(0xFFFFA726)},
    {'day': 'Thu', 'mood': 3.8, 'color': Color(0xFF66BB6A)},
    {'day': 'Fri', 'mood': 4.2, 'color': Color(0xFF42A5F5)},
    {'day': 'Sat', 'mood': 4.5, 'color': Color(0xFF26C6DA)},
    {'day': 'Sun', 'mood': 4.0, 'color': Color(0xFF7E57C2)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _generatePersonalizedInsight() {
    if (widget.selectedMood == null) return '';

    if (widget.selectedMood! <= 2) {
      return 'I notice you\'re feeling down today. Consider trying a 5-minute breathing exercise.';
    } else if (widget.selectedMood! >= 4) {
      return 'Great to see you\'re feeling positive! This is a good time to practice gratitude.';
    } else {
      return 'Your mood seems neutral today. A short meditation might help boost your energy.';
    }
  }

  Widget _buildTrendChart() {
    return Container(
      height: 20.h,
      padding: EdgeInsets.all(2.w),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < weeklyMoodData.length) {
                    return Text(
                      weeklyMoodData[value.toInt()]['day'],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: weeklyMoodData.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value['mood']);
              }).toList(),
              isCurved: true,
              color: AppTheme.lightTheme.colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: weeklyMoodData[index]['color'],
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
            ),
          ],
          minY: 0,
          maxY: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.05),
                    AppTheme.lightTheme.colorScheme.secondary
                        .withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 1.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'psychology',
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Insights',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Personalized observations',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.selectedMood != null) ...[
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'lightbulb',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _generatePersonalizedInsight(),
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      'Weekly Mood Trend',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildTrendChart(),
                  SizedBox(height: 2.h),
                  ...mockInsights.map((insight) {
                    return Container(
                      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 1.h),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: insight['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: insight['icon'],
                              color: insight['color'],
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  insight['title'],
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  insight['description'],
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

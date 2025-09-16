import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/theme/app_theme.dart';

class WeeklyProgressChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyProgressChartWidget({
    Key? key,
    required this.weeklyData,
  }) : super(key: key);

  @override
  State<WeeklyProgressChartWidget> createState() =>
      _WeeklyProgressChartWidgetState();
}

class _WeeklyProgressChartWidgetState extends State<WeeklyProgressChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Week',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.borderLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 0:
                            text = Text('Mon', style: style);
                            break;
                          case 1:
                            text = Text('Tue', style: style);
                            break;
                          case 2:
                            text = Text('Wed', style: style);
                            break;
                          case 3:
                            text = Text('Thu', style: style);
                            break;
                          case 4:
                            text = Text('Fri', style: style);
                            break;
                          case 5:
                            text = Text('Sat', style: style);
                            break;
                          case 6:
                            text = Text('Sun', style: style);
                            break;
                          default:
                            text = Text('', style: style);
                            break;
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: text,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textSecondaryLight,
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppTheme.borderLight,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 60,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? touchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          touchResponse == null ||
                          touchResponse.lineBarSpots == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          touchResponse.lineBarSpots!.first.spotIndex;
                    });
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: AppTheme.lightTheme.primaryColor,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        return LineTooltipItem(
                          '${flSpot.y.toInt()} min',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: AppTheme.lightTheme.primaryColor,
                          strokeWidth: 2,
                        ),
                        FlDotData(
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: AppTheme.lightTheme.primaryColor,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: widget.weeklyData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['minutes'] as num).toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightTheme.primaryColor,
                        AppTheme.accentLight,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: touchedIndex == index ? 6 : 4,
                          color: touchedIndex == index
                              ? AppTheme.accentLight
                              : AppTheme.lightTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.3),
                          AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total Minutes',
                widget.weeklyData
                    .fold<int>(0, (sum, day) => sum + (day['minutes'] as int))
                    .toString(),
                AppTheme.lightTheme.primaryColor,
              ),
              _buildStatItem(
                'Average',
                '${(widget.weeklyData.fold<int>(0, (sum, day) => sum + (day['minutes'] as int)) / 7).round()}',
                AppTheme.accentLight,
              ),
              _buildStatItem(
                'Best Day',
                '${widget.weeklyData.reduce((a, b) => (a['minutes'] as int) > (b['minutes'] as int) ? a : b)['minutes']}',
                AppTheme.successLight,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class StressLevelCard extends StatefulWidget {
  const StressLevelCard({Key? key}) : super(key: key);

  @override
  State<StressLevelCard> createState() => _StressLevelCardState();
}

class _StressLevelCardState extends State<StressLevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  final double currentStressLevel = 0.35; // 35% stress level
  final double previousStressLevel = 0.42; // Previous reading for trend
  final String stressCategory = "Low";
  final Color stressColor = Color(0xFF10B981); // Green for low stress

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: currentStressLevel,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStressColor(double level) {
    if (level <= 0.3) return Color(0xFF10B981); // Green - Low
    if (level <= 0.6) return Color(0xFFF59E0B); // Amber - Medium
    return Color(0xFFDC2626); // Red - High
  }

  String _getStressCategory(double level) {
    if (level <= 0.3) return "Low";
    if (level <= 0.6) return "Medium";
    return "High";
  }

  IconData _getTrendIcon() {
    if (currentStressLevel < previousStressLevel) return Icons.trending_down;
    if (currentStressLevel > previousStressLevel) return Icons.trending_up;
    return Icons.trending_flat;
  }

  Color _getTrendColor() {
    if (currentStressLevel < previousStressLevel) return Color(0xFF10B981);
    if (currentStressLevel > previousStressLevel) return Color(0xFFDC2626);
    return Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Stress Level',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getStressColor(currentStressLevel)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getTrendIcon().codePoint ==
                              Icons.trending_down.codePoint
                          ? 'trending_down'
                          : _getTrendIcon().codePoint ==
                                  Icons.trending_up.codePoint
                              ? 'trending_up'
                              : 'trending_flat',
                      color: _getTrendColor(),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${((previousStressLevel - currentStressLevel) * 100).abs().toInt()}%',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getTrendColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Stress gauge
          Center(
            child: Container(
              width: 40.w,
              height: 40.w,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: StressGaugePainter(
                      progress: _progressAnimation.value,
                      color: _getStressColor(currentStressLevel),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _getStressColor(currentStressLevel),
                            ),
                          ),
                          Text(
                            _getStressCategory(_progressAnimation.value),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Insights
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color:
                  _getStressColor(currentStressLevel).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: _getStressColor(currentStressLevel),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Insight',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: _getStressColor(currentStressLevel),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  currentStressLevel <= 0.3
                      ? 'Great job! Your stress levels are well managed. Keep up the good work with your mindfulness practice.'
                      : currentStressLevel <= 0.6
                          ? 'Your stress levels are moderate. Consider taking a short meditation break or trying some breathing exercises.'
                          : 'Your stress levels are elevated. It might be helpful to take some time for relaxation and consider speaking with someone.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/meditation-player');
                  },
                  icon: CustomIconWidget(
                    iconName: 'self_improvement',
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text('Meditate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStressColor(currentStressLevel),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to breathing exercises
                  },
                  icon: CustomIconWidget(
                    iconName: 'air',
                    color: _getStressColor(currentStressLevel),
                    size: 18,
                  ),
                  label: Text('Breathe'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _getStressColor(currentStressLevel),
                    side:
                        BorderSide(color: _getStressColor(currentStressLevel)),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StressGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  StressGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    const startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

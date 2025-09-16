import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/theme/app_theme.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Function(Duration) onSeek;
  final bool isBreathingMode;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.onSeek,
    this.isBreathingMode = false,
  });

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    if (widget.isBreathingMode) {
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBreathingMode && !oldWidget.isBreathingMode) {
      _breathingController.repeat(reverse: true);
    } else if (!widget.isBreathingMode && oldWidget.isBreathingMode) {
      _breathingController.stop();
      _breathingController.reset();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalDuration.inMilliseconds > 0
        ? widget.currentPosition.inMilliseconds /
            widget.totalDuration.inMilliseconds
        : 0.0;

    return Container(
      width: 70.w,
      height: 70.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),

          // Progress circle
          SizedBox(
            width: 70.w,
            height: 70.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),

          // Breathing guide circle (if enabled)
          if (widget.isBreathingMode)
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),

          // Time display
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(widget.currentPosition),
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'of ${_formatDuration(widget.totalDuration)}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              if (widget.isBreathingMode) ...[
                SizedBox(height: 2.h),
                Text(
                  _getBreathingInstruction(),
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),

          // Invisible gesture detector for seeking
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                final center = Offset(35.w, 35.w);
                final tapPosition = details.localPosition;
                final distance = (tapPosition - center).distance;

                if (distance <= 35.w && distance >= 25.w) {
                  final angle = (tapPosition - center).direction;
                  final normalizedAngle =
                      (angle + (3.14159 / 2)) / (2 * 3.14159);
                  final seekPosition = Duration(
                    milliseconds:
                        (normalizedAngle * widget.totalDuration.inMilliseconds)
                            .round(),
                  );
                  widget.onSeek(seekPosition);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getBreathingInstruction() {
    final animationValue = _breathingAnimation.value;
    if (animationValue < 1.0) {
      return 'Breathe Out';
    } else {
      return 'Breathe In';
    }
  }
}

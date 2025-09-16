import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class VolumeControlWidget extends StatelessWidget {
  final double volume;
  final Function(double) onVolumeChanged;

  const VolumeControlWidget({
    super.key,
    required this.volume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Column(
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'volume_down',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                size: 6.w,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
                    inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    thumbColor: AppTheme.lightTheme.colorScheme.primary,
                    overlayColor: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
                    valueIndicatorColor:
                        AppTheme.lightTheme.colorScheme.primary,
                    valueIndicatorTextStyle:
                        AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(volume * 100).round()}%',
                    onChanged: (value) {
                      // Haptic feedback at 25%, 50%, 75%, and 100%
                      if ((value * 100).round() % 25 == 0) {
                        HapticFeedback.lightImpact();
                      }
                      onVolumeChanged(value);
                    },
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              CustomIconWidget(
                iconName: 'volume_up',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                size: 6.w,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '${(volume * 100).round()}%',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

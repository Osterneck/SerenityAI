import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class PlaybackControlsWidget extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final double playbackSpeed;
  final Function(double) onSpeedChanged;

  const PlaybackControlsWidget({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRewind,
    required this.onForward,
    required this.playbackSpeed,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      child: Column(
        children: [
          // Main playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 15-second rewind button
              _buildControlButton(
                onTap: onRewind,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'replay_15',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 8.w,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '15s',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Play/Pause button (larger)
              _buildControlButton(
                onTap: onPlayPause,
                isLarge: true,
                child: CustomIconWidget(
                  iconName: isPlaying ? 'pause' : 'play_arrow',
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 12.w,
                ),
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),

              // 15-second forward button
              _buildControlButton(
                onTap: onForward,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'forward_15',
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      size: 8.w,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '15s',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Speed control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'speed',
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Speed: ${playbackSpeed}x',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              SizedBox(width: 3.w),
              _buildSpeedSelector(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required Widget child,
    bool isLarge = false,
    Color? backgroundColor,
  }) {
    final size = isLarge ? 18.w : 14.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ??
              AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: backgroundColor == null
              ? Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: isLarge
              ? [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildSpeedSelector() {
    return PopupMenuButton<double>(
      initialValue: playbackSpeed,
      onSelected: onSpeedChanged,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${playbackSpeed}x',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
              size: 4.w,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 0.5, child: Text('0.5x')),
        PopupMenuItem(value: 0.75, child: Text('0.75x')),
        PopupMenuItem(value: 1.0, child: Text('1.0x')),
        PopupMenuItem(value: 1.25, child: Text('1.25x')),
        PopupMenuItem(value: 1.5, child: Text('1.5x')),
        PopupMenuItem(value: 2.0, child: Text('2.0x')),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/services/audio_service.dart';
import './widgets/completion_dialog_widget.dart';
import './widgets/playback_controls_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/session_header_widget.dart';
import './widgets/sleep_timer_widget.dart';
import './widgets/volume_control_widget.dart';

class MeditationPlayer extends StatefulWidget {
  const MeditationPlayer({super.key});

  @override
  State<MeditationPlayer> createState() => _MeditationPlayerState();
}

class _MeditationPlayerState extends State<MeditationPlayer>
    with TickerProviderStateMixin {
  // Audio playback state
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration(minutes: 15, seconds: 30);
  double _volume = 0.7;
  double _playbackSpeed = 1.0;

  // Audio service instance
  final AudioService _audioService = AudioService.instance;
  bool _hasMeditationMusic = false;

  // UI state
  bool _isBreathingMode = false;
  bool _showControls = true;

  // Sleep timer state
  bool _sleepTimerActive = false;
  Duration? _sleepTimerRemaining;

  // Animation controllers
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  late AnimationController _controlsController;
  late Animation<double> _controlsOpacity;

  // Session data
  Map<String, dynamic>? _sessionData;

  // Auto-hide timer
  Timer? _autoHideTimer;
  Timer? _sleepTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeMeditationSession();
    _startAutoHideTimer();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
    );

    _backgroundAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
      end: AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
    ).animate(_backgroundController);

    _controlsController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _controlsOpacity =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controlsController);

    _backgroundController.repeat(reverse: true);
    _controlsController.forward();
  }

  void _initializeMeditationSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get session arguments
      final arguments = ModalRoute.of(context)?.settings.arguments;
      String? sessionId;

      if (arguments is Map<String, dynamic> &&
          arguments.containsKey('sessionId')) {
        sessionId = arguments['sessionId'] as String?;
      }

      // Initialize meditation audio service with local assets
      await _initializeMeditationAudio(sessionId: sessionId);

      // Get session data from audio service
      _sessionData = _audioService.currentSession;

      if (_sessionData != null) {
        _totalDuration =
            Duration(seconds: _sessionData!['duration_seconds'] ?? 930);
      }

      // Set up audio listeners
      _setupAudioListeners();

      // Start session tracking
      if (sessionId != null) {
        await _startSessionTracking(sessionId);
      }

      setState(() {
        _isLoading = false;
        _hasMeditationMusic = _audioService.hasMeditationMusic;
      });

      print(
          '✅ Meditation session initialized: ${_sessionData?['session_title'] ?? 'Unknown Session'}');
    } catch (error) {
      print('❌ Error initializing meditation session: $error');
      setState(() {
        _isLoading = false;
        _hasMeditationMusic = false;
      });

      // Show error message to user
      _showErrorMessage('Failed to load meditation audio. Please try again.');
    }
  }

  Future<void> _initializeMeditationAudio({String? sessionId}) async {
    try {
      await _audioService.initializeAudio(
      audioUrl: 'asset:assets/audio/audio_070923.mp3',
      sessionId: sessionId,
    );
      print('🎵 Meditation audio service initialized');
    } catch (error) {
      print('❌ Failed to initialize meditation audio: $error');
      throw error;
    }
  }

  void _setupAudioListeners() {
    // Listen to position updates
    _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    // Listen to duration changes
    _audioService.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    // Listen to volume changes
    _audioService.volumeStream.listen((volume) {
      if (mounted) {
        setState(() {
          _volume = volume;
        });
      }
    });

    // Listen to player state changes
    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        // Handle completion
        if (state.processingState == ProcessingState.completed) {
          _onMeditationComplete();
        }
      }
    });
  }

  Future<void> _startSessionTracking(String sessionId) async {
    try {
      // Start session tracking logic here if needed
      print('📊 Session tracking started for: $sessionId');
    } catch (error) {
      print('❌ Session tracking failed: $error');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(Duration(seconds: 5), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
        _controlsController.reverse();
      }
    });
  }

  void _showControlsTemporarily() {
    if (!_showControls) {
      setState(() {
        _showControls = true;
      });
      _controlsController.forward();
    }
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _audioService.stop().catchError((error) => print('Dispose error: $error'));
    _autoHideTimer?.cancel();
    _sleepTimer?.cancel();
    _backgroundController.dispose();
    _controlsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: _showControlsTemporarily,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.scaffoldBackgroundColor,
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Background image
                _buildBackgroundImage(),

                // Main content
                Column(
                  children: [
                    // Session header
                    AnimatedBuilder(
                      animation: _controlsOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _controlsOpacity.value,
                          child: SessionHeaderWidget(
                            sessionTitle: _sessionData?['session_title'] ??
                                'Meditation Session',
                            instructorName: _sessionData?['instructor_name'] ??
                                'Serenity Guide',
                            onClose: _onClose,
                            onSettings: _onSettings,
                          ),
                        );
                      },
                    ),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Progress indicator or loading
                          if (_isLoading)
                            _buildLoadingIndicator()
                          else
                            ProgressIndicatorWidget(
                              currentPosition: _currentPosition,
                              totalDuration: _totalDuration,
                              onSeek: _onSeek,
                              isBreathingMode: _isBreathingMode,
                            ),

                          SizedBox(height: 6.h),

                          // Playback controls
                          AnimatedBuilder(
                            animation: _controlsOpacity,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _controlsOpacity.value,
                                child: PlaybackControlsWidget(
                                  isPlaying: _isPlaying,
                                  onPlayPause: _onPlayPause,
                                  onRewind: _onRewind,
                                  onForward: _onForward,
                                  playbackSpeed: _playbackSpeed,
                                  onSpeedChanged: _onSpeedChanged,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Bottom controls
                    AnimatedBuilder(
                      animation: _controlsOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _controlsOpacity.value,
                          child: Column(
                            children: [
                              // Volume control
                              if (_hasMeditationMusic)
                                VolumeControlWidget(
                                  volume: _volume,
                                  onVolumeChanged: _onVolumeChanged,
                                ),

                              // Sleep timer
                              SleepTimerWidget(
                                remainingTime: _sleepTimerRemaining,
                                isActive: _sleepTimerActive,
                                onToggle: _onSleepTimerToggle,
                                onSetTimer: _onSetSleepTimer,
                              ),

                              SizedBox(height: 2.h),

                              // Audio status and breathing mode
                              _buildAudioStatusAndBreathingMode(),

                              SizedBox(height: 2.h),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: _backgroundAnimation.value,
            ),
            child: CustomImageWidget(
              imageUrl: _sessionData?['image_url'] ??
                  'https://images.pexels.com/photos/2840243/pexels-photo-2840243.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: 70.w,
      height: 70.w,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Loading meditation audio...',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Preparing soothing sounds for your meditation session',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioStatusAndBreathingMode() {
    return Column(
      children: [
        // Audio status indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
          margin: EdgeInsets.only(bottom: 2.h, left: 8.w, right: 8.w),
          decoration: BoxDecoration(
            color: _hasMeditationMusic
                ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
                : AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hasMeditationMusic
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.error
                      .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: _hasMeditationMusic ? 'volume_up' : 'volume_off',
                color: _hasMeditationMusic
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                _hasMeditationMusic
                    ? 'Playing: ${_sessionData?['category'] ?? 'Meditation Audio'}'
                    : 'Timer mode - Audio loading failed',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _hasMeditationMusic
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Breathing mode toggle
        GestureDetector(
          onTap: () {
            setState(() {
              _isBreathingMode = !_isBreathingMode;
            });
            HapticFeedback.lightImpact();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: _isBreathingMode
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _isBreathingMode
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'air',
                  color: _isBreathingMode
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  _isBreathingMode
                      ? 'Breathing Guide On'
                      : 'Enable Breathing Guide',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: _isBreathingMode
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Event handlers
  void _onPlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.play();
      }
      HapticFeedback.lightImpact();
      print('🎵 Meditation ${_isPlaying ? 'paused' : 'playing'}');
    } catch (error) {
      print('❌ Play/pause error: $error');
      _showErrorMessage('Playback error occurred');
    }
  }

  void _onRewind() async {
    try {
      await _audioService.skipBackward(duration: Duration(seconds: 15));
      HapticFeedback.lightImpact();
    } catch (error) {
      print('❌ Rewind error: $error');
    }
  }

  void _onForward() async {
    try {
      await _audioService.skipForward(duration: Duration(seconds: 15));
      HapticFeedback.lightImpact();
    } catch (error) {
      print('❌ Forward error: $error');
    }
  }

  void _onSeek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (error) {
      print('❌ Seek error: $error');
    }
  }

  void _onVolumeChanged(double volume) async {
    try {
      await _audioService.setVolume(volume);
      setState(() {
        _volume = volume;
      });
    } catch (error) {
      print('❌ Volume change error: $error');
    }
  }

  void _onSpeedChanged(double speed) async {
    try {
      await _audioService.setSpeed(speed);
      setState(() {
        _playbackSpeed = speed;
      });
      HapticFeedback.lightImpact();
    } catch (error) {
      print('❌ Speed change error: $error');
    }
  }

  void _onSleepTimerToggle() {
    setState(() {
      _sleepTimerActive = !_sleepTimerActive;
      if (!_sleepTimerActive) {
        _sleepTimerRemaining = null;
        _sleepTimer?.cancel();
      }
    });
  }

  void _onSetSleepTimer(Duration duration) {
    setState(() {
      _sleepTimerActive = true;
      _sleepTimerRemaining = duration;
    });

    _sleepTimer?.cancel();
    _sleepTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_sleepTimerActive || _sleepTimerRemaining == null) {
        timer.cancel();
        return;
      }

      setState(() {
        _sleepTimerRemaining = Duration(
          milliseconds: _sleepTimerRemaining!.inMilliseconds - 1000,
        );

        if (_sleepTimerRemaining!.inMilliseconds <= 0) {
          _onSleepTimerComplete();
          timer.cancel();
        }
      });
    });
  }

  void _onSleepTimerComplete() async {
    setState(() {
      _sleepTimerActive = false;
      _sleepTimerRemaining = null;
    });

    await _audioService.pause();

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _onMeditationComplete() async {
    try {
      await _audioService.stop();
      print(
          '🏁 Meditation session completed: ${_sessionData?['session_title']}');

      // Show completion dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => CompletionDialogWidget(
            sessionTitle:
                _sessionData?['session_title'] ?? 'Meditation Session',
            sessionDuration: _totalDuration,
            onRate: _onRateSession,
            onShare: _onShareProgress,
            onStartRelated: _onStartRelatedMeditation,
            onClose: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        );
      }
    } catch (error) {
      print('❌ Completion error: $error');
    }
  }

  void _onClose() async {
    if (_isPlaying) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('End Session?'),
          content:
              Text('Are you sure you want to end your meditation session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Continue'),
            ),
            TextButton(
              onPressed: () async {
                await _audioService.stop();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('End Session'),
            ),
          ],
        ),
      );
    } else {
      await _audioService.stop();
      Navigator.pop(context);
    }
  }

  void _onSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Session Settings',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'info',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text('Session Info'),
              subtitle: Text(_sessionData?['description'] ??
                  'Meditation session with soothing audio'),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text('Guide'),
              subtitle: Text(_sessionData?['instructor_name'] ?? 'Serenity AI'),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text('Duration'),
              subtitle: Text(
                  '${(_totalDuration.inMinutes)}:${(_totalDuration.inSeconds % 60).toString().padLeft(2, '0')} minutes'),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: _hasMeditationMusic ? 'music_note' : 'timer',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text('Audio Mode'),
              subtitle: Text(_hasMeditationMusic
                  ? '${_sessionData?['category'] ?? 'Meditation'} audio with local assets'
                  : 'Timer mode (audio unavailable)'),
            ),
            if (_hasMeditationMusic)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'storage',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 6.w,
                ),
                title: Text('Audio Source'),
                subtitle: Text('Local asset - guaranteed to work offline'),
              ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _onRateSession() {
    Navigator.pop(context);
  }

  void _onShareProgress() {
    Navigator.pop(context);
  }

  void _onStartRelatedMeditation() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/meditation-player');
  }
}

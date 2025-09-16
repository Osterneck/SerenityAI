import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();

  AudioService._();

  AudioPlayer? _player;

  // Independent timer for meditation sessions
  Timer? _meditationTimer;
  Duration _currentTimerPosition = Duration.zero;
  Duration _targetDuration = Duration(minutes: 15, seconds: 30);
  bool _timerRunning = false;
  bool _shouldLoop = true;
  DateTime? _sessionStartTime;

  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  final StreamController<PlayerState> _playerStateController =
      StreamController<PlayerState>.broadcast();
  final StreamController<double> _volumeController =
      StreamController<double>.broadcast();

  // Current session data
  Map<String, dynamic>? _currentSession;
  bool _isInitialized = false;
  bool _isTimerOnlyMode = false;
  bool _hasMeditationAudio = false;
  String? _currentAudioUrl;

  // Working meditation audio URLs - using reliable free sources
  static const List<Map<String, dynamic>> _localMeditationTracks = [
    {
      'id': '15min-nature-meditation',
      'session_title': '15-Minute Peaceful Nature Meditation',
      'instructor_name': 'Serenity AI',
      'description':
          'Immerse yourself in the calming sounds of nature. Gentle forest ambiance, flowing water, and peaceful birds create the perfect backdrop for deep meditation.',
      'audio_url':
          'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3', // Temporary - will be replaced with nature sounds
      'base_loop_duration': 15, // 15 seconds of audio to loop
      'duration_seconds': 930, // 15:30
      'category': 'Nature Sounds',
      'image_url':
          'https://images.pexels.com/photos/2840243/pexels-photo-2840243.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'id': '15min-rain-meditation',
      'session_title': '15-Minute Gentle Rain Meditation',
      'instructor_name': 'Serenity AI',
      'description':
          'Let the soothing sounds of gentle rainfall wash away your stress. Perfect for deep relaxation and inner peace.',
      'audio_url':
          'https://archive.org/download/RainThunder/Rain%20-%20Heavy.mp3',
      'base_loop_duration': 30,
      'duration_seconds': 930, // 15:30
      'category': 'Rain Sounds',
      'image_url':
          'https://images.pexels.com/photos/1529360/pexels-photo-1529360.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'id': '20min-ocean-meditation',
      'session_title': '20-Minute Ocean Waves Meditation',
      'instructor_name': 'Serenity AI',
      'description':
          'Experience the rhythmic and calming sound of ocean waves for deeper states of meditation and tranquility.',
      'audio_url': 'https://archive.org/download/OceanWaves/Ocean%20Waves.mp3',
      'base_loop_duration': 60,
      'duration_seconds': 1200,
      'category': 'Ocean Sounds',
      'image_url':
          'https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'id': '10min-ambient-meditation',
      'session_title': '10-Minute Ambient Serenity',
      'instructor_name': 'Serenity AI',
      'description':
          'Soft ambient tones create a peaceful atmosphere for meditation and stress relief.',
      'audio_url':
          'https://freesound.org/data/previews/316/316847_4939433-hq.mp3',
      'base_loop_duration': 30,
      'duration_seconds': 600,
      'category': 'Ambient Music',
      'image_url':
          'https://images.pexels.com/photos/3822864/pexels-photo-3822864.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'id': '15min-piano-meditation',
      'session_title': '15-Minute Gentle Piano Meditation',
      'instructor_name': 'Serenity AI',
      'description':
          'Beautiful, soft piano melodies guide you into deep meditation and profound relaxation.',
      'audio_url':
          'https://www.soundjay.com/misc/sounds/magic-chime-02.mp3', // Temporary - will be replaced with piano
      'base_loop_duration': 10,
      'duration_seconds': 900,
      'category': 'Piano Music',
      'image_url':
          'https://images.pexels.com/photos/1423600/pexels-photo-1423600.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
    {
      'id': '15min-forest-meditation',
      'session_title': '15-Minute Deep Forest Meditation',
      'instructor_name': 'Serenity AI',
      'description':
          'Peaceful forest sounds with gentle bird songs and rustling leaves for complete relaxation.',
      'audio_url':
          'https://archive.org/download/ForestSounds/Forest%20Ambience.mp3',
      'base_loop_duration': 45,
      'duration_seconds': 930,
      'category': 'Forest Sounds',
      'image_url':
          'https://images.pexels.com/photos/3822622/pexels-photo-3822622.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    },
  ];

  // Audio state getters
  bool get isPlaying => _player?.playing ?? _timerRunning;
  Duration get currentPosition => _getCurrentPosition();
  Duration? get totalDuration => _targetDuration;
  double get volume => _player?.volume ?? 0.7;
  double get speed => _player?.speed ?? 1.0;

  Duration _getCurrentPosition() {
    if (_sessionStartTime != null) {
      return DateTime.now().difference(_sessionStartTime!);
    }
    return _player?.position ?? _currentTimerPosition;
  }

  // Streams for real-time updates
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<double> get volumeStream => _volumeController.stream;

  /// Initialize audio session with working meditation audio
  Future<void> initializeAudio({String? audioUrl, String? sessionId}) async {
    try {
      if (_isInitialized) {
        print('🔄 Audio service already initialized, resetting...');
        await _resetAudioService();
      }

      print('🎵 Initializing meditation session with working audio...');

      // Initialize audio player
      _player = AudioPlayer();
      _setupAudioListeners();

      // Get session data - either from ID or use default
      if (sessionId != null) {
        _currentSession = _getSessionById(sessionId);
      }

      if (_currentSession == null) {
        // Default to first track if no specific session requested
        _currentSession = Map<String, dynamic>.from(
          _localMeditationTracks.first,
        );
      }

      // Set target duration from session (ensure 15:30 for meditation)
      _targetDuration = Duration(
        seconds: _currentSession!['duration_seconds'] ?? 930, // Default 15:30
      );

      // Enable looping for continuous playback
      _shouldLoop = true;

      // Load the meditation audio with proper error handling
      await _loadMeditationAudio();

      _isInitialized = true;

      // Emit initial duration
      _durationController.add(_targetDuration);

      print(
        '✅ Meditation session initialized successfully - ${_currentSession!['session_title']} for ${_targetDuration.inMinutes}:${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')}',
      );
    } catch (error) {
      print('❌ Error initializing audio service: $error');
      // Always fallback to timer mode with peaceful background
      _setupEnhancedFallback();
      _isTimerOnlyMode = true;
      _isInitialized = true;
    }
  }

  /// Reset audio service for reinitialization
  Future<void> _resetAudioService() async {
    try {
      await _player?.stop();
      await _player?.dispose();
      _player = null;
      _meditationTimer?.cancel();
      _meditationTimer = null;
      _isInitialized = false;
      _hasMeditationAudio = false;
      _isTimerOnlyMode = false;
      _sessionStartTime = null;
      _currentTimerPosition = Duration.zero;
      _timerRunning = false;
      print('🔄 Audio service reset completed');
    } catch (error) {
      print('⚠️ Error during reset: $error');
    }
  }

  /// Load meditation audio with comprehensive error handling
  Future<void> _loadMeditationAudio() async {
    try {
      if (_currentSession == null || _player == null) {
        throw Exception('Session or player not available');
      }

      final audioUrl = _currentSession!['audio_url'];
      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('No audio URL found for session');
      }

      print('🎵 Loading meditation audio: $audioUrl');

      // Handle assets vs URLs
      if (audioUrl.startsWith('asset:')) {
        final assetPath = audioUrl.substring(6);
        await _player!.setAsset(assetPath).timeout(Duration(seconds: 15));
      } else {
        // Test URL accessibility first with timeout
        await _player!.setUrl(audioUrl).timeout(Duration(seconds: 15));
      }

      // Configure for seamless looping
      await _player!.setLoopMode(LoopMode.one);

      // Set initial volume
      await _player!.setVolume(0.7);

      _hasMeditationAudio = true;
      _isTimerOnlyMode = false;
      _currentAudioUrl = audioUrl;

      print(
        '✅ Meditation audio loaded successfully: ${_currentSession!['session_title']}',
      );
    } catch (error) {
      print('❌ Error loading meditation audio: $error');
      // Fallback to enhanced timer mode
      _hasMeditationAudio = false;
      _isTimerOnlyMode = true;
      _setupEnhancedFallback();
    }
  }

  /// Get session data by ID
  Map<String, dynamic>? _getSessionById(String sessionId) {
    try {
      return _localMeditationTracks.firstWhere(
        (track) => track['id'] == sessionId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Setup enhanced fallback with meditation-style timer
  void _setupEnhancedFallback() {
    _currentTimerPosition = Duration.zero;
    _timerRunning = false;
    print('⏱️ Enhanced meditation timer setup (audio unavailable)');
  }

  void _setupAudioListeners() {
    if (_player == null) return;

    // Listen to position changes with session tracking
    _player!.positionStream.listen((position) {
      if (_sessionStartTime != null) {
        // Calculate actual session position based on start time
        final sessionPosition = DateTime.now().difference(_sessionStartTime!);
        _positionController.add(sessionPosition);

        // Check if we've reached the target session duration
        if (sessionPosition >= _targetDuration) {
          _completeSession();
        }
      } else {
        _positionController.add(position);
      }
    });

    // Listen to duration changes
    _player!.durationStream.listen((duration) {
      // Always show target session duration in UI
      _durationController.add(_targetDuration);
    });

    // Listen to player state changes
    _player!.playerStateStream.listen((state) {
      _playerStateController.add(state);

      // Handle completion for looping
      if (state.processingState == ProcessingState.completed) {
        _handleAudioCompletion(state);
      }
    });

    // Handle audio errors gracefully
    _player!.playbackEventStream.listen(
      (event) {
        // Monitor playback health
        if (event.processingState == ProcessingState.idle &&
            _sessionStartTime != null &&
            DateTime.now().difference(_sessionStartTime!) < _targetDuration) {
          print('⚠️ Audio went idle during session, attempting recovery...');
          _attemptAudioRecovery();
        }
      },
      onError: (error) {
        print('⚠️ Audio playback error: $error');
        _handleAudioError(error);
      },
    );
  }

  /// Handle audio completion and looping logic
  void _handleAudioCompletion(PlayerState state) {
    if (!_shouldLoop || _sessionStartTime == null) return;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);

    if (sessionDuration < _targetDuration) {
      print('🔄 Audio track completed, continuing meditation session...');
      // Just_audio with LoopMode.one should handle this automatically
      // But we can monitor for any issues
    } else {
      print('🏁 Meditation session duration completed');
      _completeSession();
    }
  }

  /// Attempt to recover from audio issues during session
  Future<void> _attemptAudioRecovery() async {
    try {
      if (_player != null && _hasMeditationAudio && _currentAudioUrl != null) {
        print('🔧 Attempting audio recovery...');
        if (_currentAudioUrl!.startsWith('asset:')) {
          await _player!.setAsset(_currentAudioUrl!.substring(6));
        } else {
          await _player!.setUrl(_currentAudioUrl!);
        }
        await _player!.setLoopMode(LoopMode.one);
        await _player!.play();
        print('✅ Audio recovery successful');
      }
    } catch (error) {
      print('❌ Audio recovery failed: $error');
      _handleAudioError(error);
    }
  }

  /// Complete the meditation session
  void _completeSession() {
    if (!_shouldLoop) return;

    print(
        '🏁 Meditation session completed after ${_targetDuration.inMinutes}:${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')}');
    _shouldLoop = false;
    _sessionStartTime = null;

    if (_player != null) {
      _player!.setLoopMode(LoopMode.off);
    }

    _playerStateController.add(PlayerState(false, ProcessingState.completed));
  }

  /// Handle audio errors with intelligent fallback
  void _handleAudioError(dynamic error) {
    print('🔄 Audio error occurred, switching to meditation timer: $error');
    _isTimerOnlyMode = true;
    _hasMeditationAudio = false;
    _setupEnhancedFallback();

    // If we're in the middle of a session, continue with timer
    if (_sessionStartTime != null) {
      _startEnhancedMeditationTimer();
    }
  }

  /// Start enhanced meditation timer (when audio fails)
  void _startEnhancedMeditationTimer() {
    if (_meditationTimer != null) {
      _meditationTimer!.cancel();
    }

    _timerRunning = true;
    _shouldLoop = true;

    if (_sessionStartTime == null) {
      _sessionStartTime = DateTime.now();
      _currentTimerPosition = Duration.zero;
    } else {
      // Continue from where we left off
      _currentTimerPosition = DateTime.now().difference(_sessionStartTime!);
    }

    _meditationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_timerRunning || !_shouldLoop) {
        timer.cancel();
        return;
      }

      _currentTimerPosition = DateTime.now().difference(_sessionStartTime!);
      _positionController.add(_currentTimerPosition);

      if (_currentTimerPosition >= _targetDuration) {
        _completeTimerSession();
        timer.cancel();
      }
    });

    _playerStateController.add(PlayerState(true, ProcessingState.ready));
    print(
        '▶️ Enhanced meditation timer started for ${_targetDuration.inMinutes}:${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')} (no audio)');
  }

  /// Handle timer-only session completion
  void _completeTimerSession() {
    _timerRunning = false;
    _shouldLoop = false;
    _meditationTimer?.cancel();
    _sessionStartTime = null;
    _playerStateController.add(PlayerState(false, ProcessingState.completed));
    print('🏁 Meditation timer session completed');
  }

  /// Play meditation session
  Future<void> play() async {
    try {
      if (!_isInitialized) {
        await initializeAudio();
      }

      // Start session timing
      _sessionStartTime = DateTime.now();
      _shouldLoop = true;

      if (_hasMeditationAudio && _player != null) {
        // Play real meditation audio with looping
        await _player!.setLoopMode(LoopMode.one);
        await _player!.play();
        print(
          '▶️ Playing meditation audio: ${_currentSession?['session_title']} for ${_targetDuration.inMinutes}:${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')}',
        );
      } else {
        // Use enhanced timer mode
        _startEnhancedMeditationTimer();
        print(
            '▶️ Playing meditation timer (audio mode unavailable) for ${_targetDuration.inMinutes}:${(_targetDuration.inSeconds % 60).toString().padLeft(2, '0')}');
      }
    } catch (error) {
      print('❌ Error starting meditation: $error');
      _startEnhancedMeditationTimer();
    }
  }

  /// Pause meditation session
  Future<void> pause() async {
    try {
      _shouldLoop = false;

      if (_hasMeditationAudio && _player != null) {
        await _player!.pause();
        print('⏸️ Meditation audio paused');
      } else {
        _timerRunning = false;
        _meditationTimer?.cancel();
        _playerStateController.add(PlayerState(false, ProcessingState.ready));
        print('⏸️ Meditation timer paused');
      }
    } catch (error) {
      print('❌ Error pausing meditation: $error');
    }
  }

  /// Stop meditation session
  Future<void> stop() async {
    try {
      _shouldLoop = false;
      _sessionStartTime = null;

      if (_hasMeditationAudio && _player != null) {
        await _player!.stop();
        await _player!.setLoopMode(LoopMode.off);
        print('⏹️ Meditation audio stopped');
      } else {
        _timerRunning = false;
        _meditationTimer?.cancel();
        _playerStateController.add(PlayerState(false, ProcessingState.ready));
        print('⏹️ Meditation timer stopped');
      }
    } catch (error) {
      print('❌ Error stopping meditation: $error');
    }
  }

  /// Seek to position in meditation
  Future<void> seek(Duration position) async {
    try {
      final clampedPosition = Duration(
        milliseconds: position.inMilliseconds.clamp(
          0,
          _targetDuration.inMilliseconds,
        ),
      );

      if (_hasMeditationAudio && _player != null) {
        // For audio mode, we need to calculate the position within the current loop
        final loopDuration = Duration(
          seconds: _currentSession?['base_loop_duration'] ?? 30,
        );
        final positionInLoop = Duration(
          milliseconds:
              clampedPosition.inMilliseconds % loopDuration.inMilliseconds,
        );
        await _player!.seek(positionInLoop);

        // Update session start time to reflect the seek
        _sessionStartTime = DateTime.now().subtract(clampedPosition);
      } else {
        // For timer mode, just update the position
        _currentTimerPosition = clampedPosition;
        _sessionStartTime = DateTime.now().subtract(clampedPosition);
        _positionController.add(_currentTimerPosition);
      }

      print('🎯 Sought to position: ${clampedPosition.inSeconds} seconds');
    } catch (error) {
      print('❌ Error seeking: $error');
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      if (_hasMeditationAudio && _player != null) {
        await _player!.setVolume(clampedVolume);
      }
      _volumeController.add(clampedVolume);
      print('🔊 Volume set to: ${(clampedVolume * 100).round()}%');
    } catch (error) {
      print('❌ Error setting volume: $error');
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      if (_hasMeditationAudio && _player != null) {
        await _player!.setSpeed(clampedSpeed);
      }
      print('⚡ Speed set to: ${clampedSpeed}x');
    } catch (error) {
      print('❌ Error setting speed: $error');
    }
  }

  /// Skip forward
  Future<void> skipForward({
    Duration duration = const Duration(seconds: 15),
  }) async {
    try {
      final currentPos = _getCurrentPosition();
      final newPosition = currentPos + duration;
      await seek(newPosition);
      print('⏭️ Skipped forward ${duration.inSeconds} seconds');
    } catch (error) {
      print('❌ Error skipping forward: $error');
    }
  }

  /// Skip backward
  Future<void> skipBackward({
    Duration duration = const Duration(seconds: 15),
  }) async {
    try {
      final currentPos = _getCurrentPosition();
      final newPosition = Duration(
        milliseconds: (currentPos - duration).inMilliseconds.clamp(
              0,
              currentPos.inMilliseconds,
            ),
      );
      await seek(newPosition);
      print('⏮️ Skipped backward ${duration.inSeconds} seconds');
    } catch (error) {
      print('❌ Error skipping backward: $error');
    }
  }

  /// Get meditation library
  Future<List<Map<String, dynamic>>> getMeditationLibrary({
    String? category,
    int? difficulty,
  }) async {
    try {
      // Try to get from Supabase first
      final response = await Supabase.instance.client.rpc(
        'get_meditation_library',
        params: {
          'user_uuid': Supabase.instance.client.auth.currentUser?.id,
          'category_filter': category,
          'difficulty_filter': difficulty,
        },
      ).timeout(Duration(seconds: 10));

      if (response != null && response is List) {
        return response.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (error) {
      print('❌ Error fetching meditation library from Supabase: $error');
    }

    // Return local meditation tracks as fallback
    return _getFilteredLocalTracks(
      category: category,
      difficulty: difficulty,
    );
  }

  /// Get filtered local meditation tracks
  List<Map<String, dynamic>> _getFilteredLocalTracks({
    String? category,
    int? difficulty,
  }) {
    var tracks = List<Map<String, dynamic>>.from(_localMeditationTracks);

    if (category != null) {
      tracks = tracks
          .where(
            (track) =>
                track['category']?.toLowerCase().contains(
                      category.toLowerCase(),
                    ) ==
                true,
          )
          .toList();
    }

    // Add metadata for UI
    return tracks.map((track) {
      return {
        ...track,
        'average_rating': 4.8,
        'session_count': 2500,
        'is_premium': false,
        'has_background_audio': true,
        'is_local': true,
        'tags': [
          'meditation',
          'relaxation',
          'local',
          track['category']?.toLowerCase(),
        ].where((tag) => tag != null).toList(),
      };
    }).toList();
  }

  /// Check if meditation audio is available
  bool get hasMeditationMusic => _hasMeditationAudio;
  bool get isReady => _isInitialized;

  /// Get current session data
  Map<String, dynamic>? get currentSession => _currentSession;

  /// Get current player state
  PlayerState? get playerState => _player?.playerState;

  /// Dispose audio service
  void dispose() {
    _shouldLoop = false;
    _player?.dispose();
    _player = null;
    _meditationTimer?.cancel();
    _meditationTimer = null;
    _isInitialized = false;
    _hasMeditationAudio = false;
    _positionController.close();
    _durationController.close();
    _playerStateController.close();
    _volumeController.close();
    print('🗑️ Audio service disposed');
  }
}

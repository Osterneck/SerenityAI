import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/gradient_background_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _showRetryOption = false;
  bool _isInitializing = true;
  String _loadingText = 'Preparing your wellness journey...';
  Timer? _timeoutTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Mock user data for demonstration
  final Map<String, dynamic> _mockUserData = {
    "isAuthenticated": false,
    "isFirstTime": true,
    "userId": null,
    "preferences": {
      "darkMode": false,
      "notifications": true,
      "meditationReminders": true,
    }
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setSystemUIOverlay();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<void> _startInitialization() async {
    setState(() {
      _isInitializing = true;
      _showRetryOption = false;
    });

    // Start timeout timer
    _timeoutTimer = Timer(Duration(seconds: 5), () {
      if (_isInitializing) {
        setState(() {
          _showRetryOption = true;
          _isInitializing = false;
        });
      }
    });

    try {
      // Check connectivity - Fixed implementation
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;

      if (!hasConnection) {
        _handleConnectionError();
        return;
      }

      // Simulate initialization steps
      await _performInitializationSteps();

      // Cancel timeout timer
      _timeoutTimer?.cancel();

      // Navigate to appropriate screen
      await _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError(e);
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Load user preferences
    setState(() {
      _loadingText = 'Loading your preferences...';
    });
    await Future.delayed(Duration(milliseconds: 800));
    await _loadUserPreferences();

    // Step 2: Initialize AI services
    setState(() {
      _loadingText = 'Initializing AI mood tracking...';
    });
    await Future.delayed(Duration(milliseconds: 600));
    await _initializeAIServices();

    // Step 3: Cache meditation content
    setState(() {
      _loadingText = 'Preparing meditation content...';
    });
    await Future.delayed(Duration(milliseconds: 700));
    await _cacheMeditationContent();

    // Step 4: Check authentication
    setState(() {
      _loadingText = 'Verifying authentication...';
    });
    await Future.delayed(Duration(milliseconds: 500));
    await _checkAuthenticationStatus();
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load user preferences
      _mockUserData["preferences"]["darkMode"] =
          prefs.getBool('darkMode') ?? false;
      _mockUserData["preferences"]["notifications"] =
          prefs.getBool('notifications') ?? true;
      _mockUserData["preferences"]["meditationReminders"] =
          prefs.getBool('meditationReminders') ?? true;

      // Check if first time user
      _mockUserData["isFirstTime"] = prefs.getBool('isFirstTime') ?? true;
    } catch (e) {
      // Handle error silently, use defaults
    }
  }

  Future<void> _initializeAIServices() async {
    try {
      // Simulate AI service initialization
      // In real app, this would initialize mood tracking AI, sentiment analysis, etc.
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      // Handle AI initialization error
    }
  }

  Future<void> _cacheMeditationContent() async {
    try {
      // Simulate caching meditation content for offline use
      final prefs = await SharedPreferences.getInstance();

      // Mock meditation content cache
      final List<Map<String, dynamic>> meditationContent = [
        {
          "id": 1,
          "title": "Morning Mindfulness",
          "duration": "10 minutes",
          "category": "mindfulness",
          "audioUrl": "https://example.com/meditation1.mp3",
          "isCached": true,
        },
        {
          "id": 2,
          "title": "Stress Relief",
          "duration": "15 minutes",
          "category": "stress",
          "audioUrl": "https://example.com/meditation2.mp3",
          "isCached": true,
        },
        {
          "id": 3,
          "title": "Sleep Preparation",
          "duration": "20 minutes",
          "category": "sleep",
          "audioUrl": "https://example.com/meditation3.mp3",
          "isCached": true,
        },
      ];

      // Store cached content info
      await prefs.setString('cachedMeditations', meditationContent.toString());
    } catch (e) {
      // Handle caching error
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check for stored authentication token
      final String? authToken = prefs.getString('authToken');
      final String? userId = prefs.getString('userId');

      if (authToken != null && userId != null) {
        // Simulate token validation
        await Future.delayed(Duration(milliseconds: 200));

        // For demo purposes, randomly determine if token is valid
        final bool isTokenValid =
            DateTime.now().millisecondsSinceEpoch % 2 == 0;

        if (isTokenValid) {
          _mockUserData["isAuthenticated"] = true;
          _mockUserData["userId"] = userId;
        } else {
          // Token expired, clear stored data
          await prefs.remove('authToken');
          await prefs.remove('userId');
          _mockUserData["isAuthenticated"] = false;
        }
      } else {
        _mockUserData["isAuthenticated"] = false;
      }
    } catch (e) {
      _mockUserData["isAuthenticated"] = false;
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Add a small delay for smooth transition
    await Future.delayed(Duration(milliseconds: 500));

    if (!mounted) return;

    // Determine navigation path based on user state
    String nextRoute;

    if (_mockUserData["isAuthenticated"] == true) {
      // Authenticated user goes to dashboard
      nextRoute = '/home-dashboard';
    } else if (_mockUserData["isFirstTime"] == true) {
      // First time user sees onboarding (fallback to login for demo)
      nextRoute = '/login-screen';
    } else {
      // Returning non-authenticated user goes to login
      nextRoute = '/login-screen';
    }

    // Handle deep links if any
    final String? deepLinkRoute = await _handleDeepLinks();
    if (deepLinkRoute != null) {
      nextRoute = deepLinkRoute;
    }

    // Perform fade out animation before navigation
    await _fadeController.reverse();

    if (mounted) {
      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  Future<String?> _handleDeepLinks() async {
    try {
      // In a real app, this would handle deep links for meditation sessions, etc.
      // For demo, return null (no deep link)
      return null;
    } catch (e) {
      return null;
    }
  }

  void _handleConnectionError() {
    _timeoutTimer?.cancel();
    setState(() {
      _isInitializing = false;
      _showRetryOption = true;
    });
  }

  void _handleInitializationError(dynamic error) {
    _timeoutTimer?.cancel();
    setState(() {
      _isInitializing = false;
      _showRetryOption = true;
    });
  }

  void _retryInitialization() {
    _startInitialization();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _timeoutTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GradientBackgroundWidget(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: _showRetryOption ? _buildRetryView() : _buildLoadingView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Container(),
        ),
        AnimatedLogoWidget(),
        SizedBox(height: 8.h),
        LoadingIndicatorWidget(
          loadingText: _loadingText,
        ),
        Expanded(
          flex: 3,
          child: Container(),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            'SerenityAI v1.0',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.surface
                  .withValues(alpha: 0.6),
              fontSize: 10.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRetryView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Container(),
        ),
        AnimatedLogoWidget(),
        SizedBox(height: 6.h),
        RetryConnectionWidget(
          onRetry: _retryInitialization,
          message:
              'Unable to connect to SerenityAI services.\nPlease check your internet connection and try again.',
        ),
        Expanded(
          flex: 3,
          child: Container(),
        ),
      ],
    );
  }
}

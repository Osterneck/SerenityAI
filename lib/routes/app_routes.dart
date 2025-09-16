import 'package:flutter/material.dart';
import 'package:serenityai/presentation/splash_screen/splash_screen.dart';
import 'package:serenityai/presentation/home_dashboard/home_dashboard.dart';
import 'package:serenityai/presentation/user_profile/user_profile.dart';
import 'package:serenityai/presentation/login_screen/login_screen.dart';
import 'package:serenityai/presentation/signup_screen/signup_screen.dart';
import 'package:serenityai/presentation/mood_tracking/mood_tracking.dart';
import 'package:serenityai/presentation/meditation_player/meditation_player.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String userProfile = '/user-profile';
  static const String login = '/login-screen';
  static const String signup = '/signup-screen';
  static const String moodTracking = '/mood-tracking';
  static const String meditationPlayer = '/meditation-player';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    moodTracking: (context) => const MoodTracking(),
    meditationPlayer: (context) => const MeditationPlayer(),
    // TODO: Add your other routes here
  };
}

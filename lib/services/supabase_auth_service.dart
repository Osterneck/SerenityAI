import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import './user_profile_service.dart';

class SupabaseAuthService {
  static const String _supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String _supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static SupabaseClient get _client => SupabaseService.instance.client;

  // Get current authenticated user
  static User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  // Get current user session
  static Session? get currentSession => _client.auth.currentSession;

  /// Sign up a new user with email and password
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': 'user',
        },
      );

      if (response.user != null) {
        // Ensure user profile exists in database
        await UserProfileService.ensureUserProfileExists(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );

        return {
          'success': true,
          'user': {
            'id': response.user!.id,
            'email': response.user!.email,
            'full_name': response.user!.userMetadata?['full_name'] ?? fullName,
          },
          'message':
              'Account created successfully! Please check your email for verification.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create account. Please try again.',
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Supabase sign up error: $error');
      }

      String errorMessage = 'An error occurred during sign up.';
      if (error.toString().contains('User already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (error.toString().contains('Password should be')) {
        errorMessage = 'Password must be at least 6 characters long.';
      } else if (error.toString().contains('Invalid email')) {
        errorMessage = 'Please enter a valid email address.';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  /// Sign in existing user with email and password
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Fetch user profile data
        final userProfile = await UserProfileService.getCurrentUserProfile();

        return {
          'success': true,
          'user': {
            'id': response.user!.id,
            'email': response.user!.email,
            'full_name': userProfile?['full_name'] ??
                response.user!.userMetadata?['full_name'] ??
                'User',
            'role': userProfile?['role'] ?? 'user',
          },
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid email or password.',
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Supabase sign in error: $error');
      }

      String errorMessage = 'An error occurred during sign in.';
      if (error.toString().contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password.';
      } else if (error.toString().contains('Email not confirmed')) {
        errorMessage = 'Please verify your email before signing in.';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  /// Sign out current user
  static Future<Map<String, dynamic>> signOut() async {
    try {
      await _client.auth.signOut();
      return {
        'success': true,
        'message': 'Signed out successfully.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Supabase sign out error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to sign out. Please try again.',
      };
    }
  }

  /// Reset password via email
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Password reset error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to send password reset email. Please try again.',
      };
    }
  }

  /// Get user profile data
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (error) {
      if (kDebugMode) {
        print('Get user profile error: $error');
      }
      return null;
    }
  }

  /// Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return {
        'success': true,
        'user': response,
        'message': 'Profile updated successfully.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Update profile error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to update profile. Please try again.',
      };
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  /// Social login with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(OAuthProvider.google);

      if (response) {
        return {
          'success': true,
          'message': 'Google sign-in initiated. Please complete in browser.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to initiate Google sign-in.',
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Google sign-in error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to sign in with Google. Please try again.',
      };
    }
  }

  /// Social login with Apple
  static Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(OAuthProvider.apple);

      if (response) {
        return {
          'success': true,
          'message': 'Apple sign-in initiated. Please complete in browser.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to initiate Apple sign-in.',
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Apple sign-in error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to sign in with Apple. Please try again.',
      };
    }
  }

  /// Check if user needs to verify email
  static bool get needsEmailVerification {
    final user = currentUser;
    return user != null;
  }

  /// Resend email verification
  static Future<Map<String, dynamic>> resendEmailVerification() async {
    try {
      final user = currentUser;
      if (user?.email != null) {
        await _client.auth.resend(
          type: OtpType.signup,
          email: user!.email!,
        );
        return {
          'success': true,
          'message': 'Verification email sent successfully.',
        };
      } else {
        return {
          'success': false,
          'error': 'No user email found.',
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Resend verification error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to resend verification email.',
      };
    }
  }

  /// Development helper: Check service configuration
  static bool get isConfigured {
    return _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty;
  }

  /// Development helper: Get configuration status
  static Map<String, dynamic> get configurationStatus {
    return {
      'supabase_url': _supabaseUrl.isNotEmpty ? 'Configured' : 'Missing',
      'supabase_anon_key':
          _supabaseAnonKey.isNotEmpty ? 'Configured' : 'Missing',
      'is_ready': isConfigured,
    };
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileService {
  static final _client = Supabase.instance.client;

  /// Get current user's profile with real-time fallback
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // First try to get from user_profiles table
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        return response;
      }

      // If no profile exists, create one from auth metadata
      final userMetadata = user.userMetadata ?? {};
      final newProfile = {
        'id': user.id,
        'email': user.email ?? '',
        'full_name': userMetadata['full_name'] ?? 'User',
        'role': 'user',
        'is_active': true,
        'timezone': 'UTC',
        'preferred_meditation_duration': 300,
      };

      // Insert the new profile
      final insertResponse = await _client
          .from('user_profiles')
          .insert(newProfile)
          .select()
          .single();

      return insertResponse;
    } catch (error) {
      print('Error fetching user profile: $error');

      // Fallback to auth metadata
      final user = _client.auth.currentUser;
      if (user != null) {
        return {
          'id': user.id,
          'email': user.email ?? '',
          'full_name': user.userMetadata?['full_name'] ?? 'User',
          'role': 'user',
        };
      }

      return null;
    }
  }

  /// Listen to auth state changes and update profile accordingly
  static Stream<Map<String, dynamic>?> get userProfileStream {
    return _client.auth.onAuthStateChange.asyncMap((authState) async {
      if (authState.event == AuthChangeEvent.signedIn) {
        return await getCurrentUserProfile();
      } else if (authState.event == AuthChangeEvent.signedOut) {
        return null;
      }
      return null;
    });
  }

  /// Extract first name from full name
  static String getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    final parts = fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : 'User';
  }

  /// Update user profile
  static Future<bool> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('user_profiles').update(updates).eq('id', userId);

      return true;
    } catch (error) {
      print('Error updating user profile: $error');
      return false;
    }
  }

  /// Ensure user profile exists after signup
  static Future<void> ensureUserProfileExists({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      final existingProfile = await _client
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (existingProfile == null) {
        await _client.from('user_profiles').insert({
          'id': userId,
          'email': email,
          'full_name': fullName,
          'role': 'user',
          'is_active': true,
          'timezone': 'UTC',
          'preferred_meditation_duration': 300,
        });
      }
    } catch (error) {
      print('Error ensuring user profile exists: $error');
    }
  }
}

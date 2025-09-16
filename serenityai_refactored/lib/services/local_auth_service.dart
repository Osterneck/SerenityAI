import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalAuthService {
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';

  // Get all registered users from local storage
  static Future<Map<String, dynamic>> _getStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      return {};
    }
    try {
      return Map<String, dynamic>.from(json.decode(usersJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing stored users: $e');
      }
      return {};
    }
  }

  // Save users to local storage
  static Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, json.encode(users));
  }

  // Sign up a new user
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Get existing users
      final users = await _getStoredUsers();

      // Check if user already exists
      if (users.containsKey(email.toLowerCase())) {
        return {
          'success': false,
          'error': 'An account with this email already exists',
        };
      }

      // Validate email format
      if (!_isValidEmail(email)) {
        return {
          'success': false,
          'error': 'Please enter a valid email address',
        };
      }

      // Validate password strength
      if (password.length < 6) {
        return {
          'success': false,
          'error': 'Password must be at least 6 characters long',
        };
      }

      // Create new user
      final newUser = {
        'email': email.toLowerCase(),
        'fullName': fullName.trim(),
        'password': password, // In production, this should be hashed
        'createdAt': DateTime.now().toIso8601String(),
        'profileComplete': false,
      };

      // Add user to storage
      users[email.toLowerCase()] = newUser;
      await _saveUsers(users);

      // Set as current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, email.toLowerCase());

      return {
        'success': true,
        'user': {
          'email': newUser['email'],
          'fullName': newUser['fullName'],
          'createdAt': newUser['createdAt'],
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      return {
        'success': false,
        'error': 'An error occurred during sign up. Please try again.',
      };
    }
  }

  // Sign in user
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final users = await _getStoredUsers();
      final userKey = email.toLowerCase();

      if (!users.containsKey(userKey)) {
        return {
          'success': false,
          'error': 'No account found with this email address',
        };
      }

      final user = users[userKey];
      if (user['password'] != password) {
        return {'success': false, 'error': 'Incorrect password'};
      }

      // Set as current user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, userKey);

      return {
        'success': true,
        'user': {
          'email': user['email'],
          'fullName': user['fullName'],
          'createdAt': user['createdAt'],
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('Sign in error: $e');
      }
      return {
        'success': false,
        'error': 'An error occurred during sign in. Please try again.',
      };
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserEmail = prefs.getString(_currentUserKey);

      if (currentUserEmail == null) {
        return null;
      }

      final users = await _getStoredUsers();
      final user = users[currentUserEmail];

      if (user == null) {
        return null;
      }

      return {
        'email': user['email'],
        'fullName': user['fullName'],
        'createdAt': user['createdAt'],
      };
    } catch (e) {
      if (kDebugMode) {
        print('Get current user error: $e');
      }
      return null;
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user is signed in
  static Future<bool> isSignedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  // Email validation helper
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get all registered users count (for debugging)
  static Future<int> getRegisteredUsersCount() async {
    final users = await _getStoredUsers();
    return users.length;
  }

  // Clear all local data (for testing purposes)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
  }
}

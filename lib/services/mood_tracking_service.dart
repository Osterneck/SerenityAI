import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

enum MoodLevel { veryPoor, poor, neutral, good, excellent }

class MoodEntry {
  final String id;
  final String userId;
  final MoodLevel moodLevel;
  final String? notes;
  final List<String> emotionTags;
  final int? energyLevel;
  final int? stressLevel;
  final double? sleepHours;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodLevel,
    this.notes,
    this.emotionTags = const [],
    this.energyLevel,
    this.stressLevel,
    this.sleepHours,
    required this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      moodLevel: _parseMoodLevel(json['mood_level'] as String),
      notes: json['notes'] as String?,
      emotionTags: List<String>.from(json['emotion_tags'] ?? []),
      energyLevel: json['energy_level'] as int?,
      stressLevel: json['stress_level'] as int?,
      sleepHours: json['sleep_hours']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mood_level': _moodLevelToString(moodLevel),
      'notes': notes,
      'emotion_tags': emotionTags,
      'energy_level': energyLevel,
      'stress_level': stressLevel,
      'sleep_hours': sleepHours,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static MoodLevel _parseMoodLevel(String level) {
    switch (level) {
      case 'very_poor':
        return MoodLevel.veryPoor;
      case 'poor':
        return MoodLevel.poor;
      case 'neutral':
        return MoodLevel.neutral;
      case 'good':
        return MoodLevel.good;
      case 'excellent':
        return MoodLevel.excellent;
      default:
        return MoodLevel.neutral;
    }
  }

  static String _moodLevelToString(MoodLevel level) {
    switch (level) {
      case MoodLevel.veryPoor:
        return 'very_poor';
      case MoodLevel.poor:
        return 'poor';
      case MoodLevel.neutral:
        return 'neutral';
      case MoodLevel.good:
        return 'good';
      case MoodLevel.excellent:
        return 'excellent';
    }
  }
}

class MoodTrackingService {
  static SupabaseClient get _client => SupabaseService.instance.client;

  /// Add a new mood entry
  static Future<Map<String, dynamic>> addMoodEntry({
    required String userId,
    required MoodLevel moodLevel,
    String? notes,
    List<String> emotionTags = const [],
    int? energyLevel,
    int? stressLevel,
    double? sleepHours,
  }) async {
    try {
      final response = await _client
          .from('mood_entries')
          .insert({
            'user_id': userId,
            'mood_level': MoodEntry._moodLevelToString(moodLevel),
            'notes': notes,
            'emotion_tags': emotionTags,
            'energy_level': energyLevel,
            'stress_level': stressLevel,
            'sleep_hours': sleepHours,
          })
          .select()
          .single();

      return {
        'success': true,
        'moodEntry': MoodEntry.fromJson(response),
        'message': 'Mood entry saved successfully.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Add mood entry error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to save mood entry. Please try again.',
      };
    }
  }

  /// Get user's mood entries with optional filtering
  static Future<Map<String, dynamic>> getMoodEntries({
    required String userId,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('mood_entries').select().eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response =
          await query.order('created_at', ascending: false).limit(limit ?? 50);

      final moodEntries =
          (response as List).map((entry) => MoodEntry.fromJson(entry)).toList();

      return {
        'success': true,
        'moodEntries': moodEntries,
      };
    } catch (error) {
      if (kDebugMode) {
        print('Get mood entries error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to load mood entries.',
        'moodEntries': <MoodEntry>[],
      };
    }
  }

  /// Get today's mood entry for a user
  static Future<Map<String, dynamic>> getTodaysMoodEntry({
    required String userId,
  }) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('mood_entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return {
          'success': true,
          'moodEntry': MoodEntry.fromJson(response.first),
          'hasEntry': true,
        };
      } else {
        return {
          'success': true,
          'moodEntry': null,
          'hasEntry': false,
        };
      }
    } catch (error) {
      if (kDebugMode) {
        print('Get today mood entry error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to load today\'s mood entry.',
        'hasEntry': false,
      };
    }
  }

  /// Update an existing mood entry
  static Future<Map<String, dynamic>> updateMoodEntry({
    required String entryId,
    required String userId,
    MoodLevel? moodLevel,
    String? notes,
    List<String>? emotionTags,
    int? energyLevel,
    int? stressLevel,
    double? sleepHours,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (moodLevel != null) {
        updates['mood_level'] = MoodEntry._moodLevelToString(moodLevel);
      }
      if (notes != null) updates['notes'] = notes;
      if (emotionTags != null) updates['emotion_tags'] = emotionTags;
      if (energyLevel != null) updates['energy_level'] = energyLevel;
      if (stressLevel != null) updates['stress_level'] = stressLevel;
      if (sleepHours != null) updates['sleep_hours'] = sleepHours;

      final response = await _client
          .from('mood_entries')
          .update(updates)
          .eq('id', entryId)
          .eq('user_id',
              userId) // Ensure user can only update their own entries
          .select()
          .single();

      return {
        'success': true,
        'moodEntry': MoodEntry.fromJson(response),
        'message': 'Mood entry updated successfully.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Update mood entry error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to update mood entry. Please try again.',
      };
    }
  }

  /// Delete a mood entry
  static Future<Map<String, dynamic>> deleteMoodEntry({
    required String entryId,
    required String userId,
  }) async {
    try {
      await _client.from('mood_entries').delete().eq('id', entryId).eq(
          'user_id', userId); // Ensure user can only delete their own entries

      return {
        'success': true,
        'message': 'Mood entry deleted successfully.',
      };
    } catch (error) {
      if (kDebugMode) {
        print('Delete mood entry error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to delete mood entry. Please try again.',
      };
    }
  }

  /// Get mood statistics for a user
  static Future<Map<String, dynamic>> getMoodStats({
    required String userId,
    int? days,
  }) async {
    try {
      final daysToAnalyze = days ?? 30;
      final startDate = DateTime.now().subtract(Duration(days: daysToAnalyze));

      final response = await _client
          .from('mood_entries')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false);

      final entries =
          (response as List).map((entry) => MoodEntry.fromJson(entry)).toList();

      if (entries.isEmpty) {
        return {
          'success': true,
          'stats': {
            'averageMood': 0.0,
            'totalEntries': 0,
            'moodDistribution': {},
            'recentTrend': 'no_data',
          },
        };
      }

      // Calculate average mood (1-5 scale)
      final moodValues = entries.map((entry) {
        switch (entry.moodLevel) {
          case MoodLevel.veryPoor:
            return 1.0;
          case MoodLevel.poor:
            return 2.0;
          case MoodLevel.neutral:
            return 3.0;
          case MoodLevel.good:
            return 4.0;
          case MoodLevel.excellent:
            return 5.0;
        }
      }).toList();

      final averageMood =
          moodValues.reduce((a, b) => a + b) / moodValues.length;

      // Calculate mood distribution
      final distribution = <String, int>{};
      for (final entry in entries) {
        final moodString = MoodEntry._moodLevelToString(entry.moodLevel);
        distribution[moodString] = (distribution[moodString] ?? 0) + 1;
      }

      // Calculate recent trend (last 7 days vs previous 7 days)
      String trend = 'stable';
      if (entries.length >= 7) {
        final recentEntries = entries.take(7).toList();
        final previousEntries = entries.skip(7).take(7).toList();

        if (previousEntries.isNotEmpty) {
          final recentAvg = recentEntries
                  .map((e) => moodValues[entries.indexOf(e)])
                  .reduce((a, b) => a + b) /
              recentEntries.length;

          final previousAvg = previousEntries
                  .map((e) => moodValues[entries.indexOf(e)])
                  .reduce((a, b) => a + b) /
              previousEntries.length;

          if (recentAvg > previousAvg + 0.3) {
            trend = 'improving';
          } else if (recentAvg < previousAvg - 0.3) {
            trend = 'declining';
          }
        }
      }

      return {
        'success': true,
        'stats': {
          'averageMood': double.parse(averageMood.toStringAsFixed(2)),
          'totalEntries': entries.length,
          'moodDistribution': distribution,
          'recentTrend': trend,
        },
      };
    } catch (error) {
      if (kDebugMode) {
        print('Get mood stats error: $error');
      }
      return {
        'success': false,
        'error': 'Failed to load mood statistics.',
        'stats': {},
      };
    }
  }

  /// Get common emotion tags for suggestions
  static Future<List<String>> getPopularEmotionTags({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final response = await _client
          .from('mood_entries')
          .select('emotion_tags')
          .eq('user_id', userId)
          .limit(100); // Get recent entries to analyze

      final allTags = <String>[];
      for (final entry in response) {
        final tags = List<String>.from(entry['emotion_tags'] ?? []);
        allTags.addAll(tags);
      }

      // Count tag frequency and return most popular
      final tagCounts = <String, int>{};
      for (final tag in allTags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }

      final sortedTags = tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedTags.take(limit).map((entry) => entry.key).toList();
    } catch (error) {
      if (kDebugMode) {
        print('Get popular emotion tags error: $error');
      }
      // Return default emotion tags
      return [
        'happy',
        'sad',
        'anxious',
        'calm',
        'excited',
        'stressed',
        'grateful',
        'angry',
        'hopeful',
        'tired',
        'motivated',
        'peaceful',
        'worried',
        'content',
        'energetic'
      ];
    }
  }
}

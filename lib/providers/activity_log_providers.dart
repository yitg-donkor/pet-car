// providers/activity_log_providers.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/activity_log.dart';
import '../local_db/sqflite_db.dart';
import 'offline_providers.dart';
import 'auth_providers.dart';

part 'activity_log_providers.g.dart';

// ============================================
// ACTIVITY LOG LOCAL DB PROVIDER
// ============================================

@riverpod
ActivityLogLocalDB activityLogLocalDB(ActivityLogLocalDBRef ref) {
  return ActivityLogLocalDB();
}

// ============================================
// OFFLINE-FIRST ACTIVITY LOGS PROVIDER
// ============================================

@riverpod
class ActivityLogsOffline extends _$ActivityLogsOffline {
  @override
  Future<List<ActivityLog>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    // Get all logs for the owner (across all their pets)
    final activityLogDB = ref.watch(activityLogLocalDBProvider);
    final logs = await activityLogDB.getAllLogsForOwner(user.id);

    // Sync in background
    final syncService = ref.watch(unifiedSyncServiceProvider);
    syncService.fullSync(user.id).catchError((e) {
      print('Background sync error: $e');
    });

    return logs;
  }

  Future<void> addLog(ActivityLog log) async {
    final activityLogDB = ref.read(activityLogLocalDBProvider);
    await activityLogDB.createActivityLog(log);

    // Sync in background
    final syncService = ref.read(unifiedSyncServiceProvider);
    syncService.syncActivityLogsToSupabase().catchError((e) {
      print('Background sync error: $e');
    });

    ref.invalidateSelf();
  }

  Future<void> updateLog(ActivityLog log) async {
    final activityLogDB = ref.read(activityLogLocalDBProvider);
    await activityLogDB.updateActivityLog(log);

    // Sync in background
    final syncService = ref.read(unifiedSyncServiceProvider);
    syncService.syncActivityLogsToSupabase().catchError((e) {
      print('Background sync error: $e');
    });

    ref.invalidateSelf();
  }

  Future<void> deleteLog(String logId) async {
    final activityLogDB = ref.read(activityLogLocalDBProvider);
    await activityLogDB.deleteActivityLog(logId);

    // Delete from Supabase if online
    final syncService = ref.read(unifiedSyncServiceProvider);
    if (await syncService.hasInternetConnection()) {
      try {
        await syncService.supabase
            .from('activity_logs')
            .delete()
            .eq('id', logId);
      } catch (e) {
        print('Error deleting from Supabase: $e');
      }
    }

    ref.invalidateSelf();
  }
}

// ============================================
// FILTERED ACTIVITY LOGS PROVIDERS
// ============================================

// Daily logs (today and yesterday)
@riverpod
Future<Map<String, List<ActivityLog>>> dailyActivityLogs(
  DailyActivityLogsRef ref,
) async {
  final allLogs = await ref.watch(activityLogsOfflineProvider.future);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final twoDaysAgo = today.subtract(const Duration(days: 2));

  final todayLogs =
      allLogs.where((log) {
        return log.timestamp.isAfter(today) ||
            log.timestamp.isAtSameMomentAs(today);
      }).toList();

  final yesterdayLogs =
      allLogs.where((log) {
        return log.timestamp.isAfter(yesterday) &&
            log.timestamp.isBefore(today);
      }).toList();

  return {'today': todayLogs, 'yesterday': yesterdayLogs};
}

// Health-related logs
@riverpod
Future<List<ActivityLog>> healthActivityLogs(HealthActivityLogsRef ref) async {
  final allLogs = await ref.watch(activityLogsOfflineProvider.future);

  return allLogs.where((log) => log.isHealthRelated).toList();
}

// Logs for specific pet
@riverpod
Future<List<ActivityLog>> petActivityLogs(
  PetActivityLogsRef ref,
  String petId,
) async {
  final activityLogDB = ref.watch(activityLogLocalDBProvider);
  return activityLogDB.getActivityLogsForPet(petId);
}

// Logs by date range
@riverpod
Future<List<ActivityLog>> activityLogsByDateRange(
  ActivityLogsByDateRangeRef ref,
  String petId,
  DateTime startDate,
  DateTime endDate,
) async {
  final activityLogDB = ref.watch(activityLogLocalDBProvider);
  return activityLogDB.getLogsByDateRange(petId, startDate, endDate);
}

// ============================================
// ACTIVITY LOG STATISTICS
// ============================================

@riverpod
Future<Map<String, int>> activityLogStats(ActivityLogStatsRef ref) async {
  final allLogs = await ref.watch(activityLogsOfflineProvider.future);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisWeek = today.subtract(const Duration(days: 7));

  final todayCount =
      allLogs.where((log) {
        return log.timestamp.isAfter(today);
      }).length;

  final weekCount =
      allLogs.where((log) {
        return log.timestamp.isAfter(thisWeek);
      }).length;

  final healthCount = allLogs.where((log) => log.isHealthRelated).length;

  return {
    'today': todayCount,
    'week': weekCount,
    'health': healthCount,
    'total': allLogs.length,
  };
}

// ============================================
// ACTIVITY TYPES ENUM (Helper)
// ============================================

enum ActivityType {
  walk('walk', 'Walk', Icons.directions_walk, Color(0xFF4CAF50)),
  meal('meal', 'Meal', Icons.restaurant, Color(0xFFFF9800)),
  bathroom('bathroom', 'Bathroom', Icons.grass, Color(0xFF8BC34A)),
  medication('medication', 'Medication', Icons.medication, Color(0xFFE53E3E)),
  playtime('playtime', 'Playtime', Icons.toys, Color(0xFF9C27B0)),
  health('health', 'Health Check', Icons.health_and_safety, Color(0xFFE91E63)),
  grooming('grooming', 'Grooming', Icons.clean_hands, Color(0xFF795548)),
  vet('vet', 'Vet Visit', Icons.medical_services, Color(0xFF009688)),
  weight('weight', 'Weight Check', Icons.monitor_weight, Color(0xFF3F51B5)),
  behavior('behavior', 'Behavior', Icons.psychology, Color(0xFFFF5722)),
  other('other', 'Other', Icons.note, Color(0xFF607D8B));

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const ActivityType(this.value, this.label, this.icon, this.color);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ActivityType.other,
    );
  }
}

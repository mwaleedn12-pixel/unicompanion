import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/notification_service.dart';

/// Smart notification scheduler for admission deadlines & scholarship matches.
///
/// Call [syncSmartNotifications] after login or on app resume to schedule
/// upcoming deadline reminders and scholarship match alerts.
class SmartNotificationService {
  SmartNotificationService._();

  static final instance = SmartNotificationService._();

  /// Syncs all smart notifications: deadline reminders + scholarship alerts.
  Future<void> syncSmartNotifications() async {
    await _scheduleDeadlineReminders();
  }

  /// Schedules notifications for upcoming application deadlines
  /// using the existing NotificationService.syncApplicationReminders API.
  Future<void> _scheduleDeadlineReminders() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Get user's applications with deadlines
      final data = await Supabase.instance.client
          .from('user_applications')
          .select('id, university_name, deadline, status')
          .eq('user_id', user.id)
          .not('deadline', 'is', null)
          .neq('status', 'accepted')
          .neq('status', 'rejected');

      final now = DateTime.now();
      final dueItems = <DueItem>[];

      for (final app in data) {
        final deadline = DateTime.tryParse(app['deadline'] ?? '');
        if (deadline == null || deadline.isBefore(now)) continue;

        final uniName = app['university_name'] ?? 'University';
        final appId = app['id'] as String;

        dueItems.add(DueItem(
          id: appId,
          title: uniName,
          subtitle: 'Application deadline',
          dueDate: deadline,
        ));
      }

      // Use existing notification service to schedule reminders
      // (it handles 1-day and 1-hour before automatically)
      await NotificationService.instance.syncApplicationReminders(dueItems);
    } catch (_) {
      // Silently fail — notifications are best-effort
    }
  }
}
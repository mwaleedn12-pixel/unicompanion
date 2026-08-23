import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'local_storage_service.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'deadline_reminders';
  static const _channelName = 'Deadline Reminders';
  static const _channelDescription = 'Reminders for upcoming assignments, quizzes, exams, and application deadlines';

  static const List<_ReminderOffset> _offsets = [
    _ReminderOffset(daysBefore: 3, hour: 9, minute: 0, label: 'in 3 days'),
    _ReminderOffset(daysBefore: 1, hour: 9, minute: 0, label: 'tomorrow'),
    _ReminderOffset(daysBefore: 0, hour: 8, minute: 0, label: 'today'),
  ];

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {}

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
      return granted ?? false;
    }

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }

    return true;
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  Future<void> syncAssignmentReminders(List<_DueItem> items) async {
    if (!LocalStorageService.remindersEnabled) return;
    await init();
    for (final item in items) {
      await _scheduleFor(source: 'assignment', item: item);
    }
  }

  Future<void> cancelForAssignment(String assignmentId) async {
    await init();
    for (final offset in _offsets) {
      await _plugin.cancel(_idFor('assignment', assignmentId, offset.daysBefore));
    }
  }

  Future<void> syncApplicationReminders(List<_DueItem> items) async {
    if (!LocalStorageService.remindersEnabled) return;
    await init();
    for (final item in items) {
      await _scheduleFor(source: 'application', item: item);
    }
  }

  Future<void> cancelForApplication(String applicationId) async {
    await init();
    for (final offset in _offsets) {
      await _plugin.cancel(_idFor('application', applicationId, offset.daysBefore));
    }
  }

  Future<void> _scheduleFor({required String source, required _DueItem item}) async {
    for (final offset in _offsets) {
      final id = _idFor(source, item.id, offset.daysBefore);
      final fireDate = item.dueDate.subtract(Duration(days: offset.daysBefore));
      final scheduled = tz.TZDateTime(
        tz.local,
        fireDate.year,
        fireDate.month,
        fireDate.day,
        offset.hour,
        offset.minute,
      );

      if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) {
        await _plugin.cancel(id);
        continue;
      }

      try {
        await _plugin.zonedSchedule(
          id,
          item.title,
          'Due ${offset.label} — ${item.subtitle}',
          scheduled,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              _channelName,
              channelDescription: _channelDescription,
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('NotificationService: failed to schedule $id — $e');
      }
    }
  }

  int _idFor(String source, String itemId, int daysBefore) {
    final key = '$source:$itemId:$daysBefore';
    var hash = 0;
    for (final codeUnit in key.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}

class _ReminderOffset {
  final int daysBefore;
  final int hour;
  final int minute;
  final String label;
  const _ReminderOffset({required this.daysBefore, required this.hour, required this.minute, required this.label});
}

class DueItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime dueDate;
  const DueItem({required this.id, required this.title, required this.subtitle, required this.dueDate});
}

typedef _DueItem = DueItem;
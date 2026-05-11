import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/medicine/models/medicine.dart';

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const _channelId = 'medicine_reminders_sound_v2';
  static const _soundName = 'medicine_reminder';

  static const _androidChannel = AndroidNotificationChannel(
    _channelId,
    'Medicine reminders',
    description: 'Scheduled reminders for taking medicines.',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound(_soundName),
    enableVibration: true,
    enableLights: true,
  );

  Future<void> initialize() async {
    await _configureLocalTimezone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
    );

    await _requestPermissions();
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();

    if (kIsWeb) {
      return;
    }

    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.deleteNotificationChannel(
        channelId: 'medicine_reminders',
      );
      await androidPlugin?.deleteNotificationChannel(
        channelId: 'medicine_reminders_with_sound',
      );
      await androidPlugin?.createNotificationChannel(_androidChannel);
      await androidPlugin?.requestNotificationsPermission();
      try {
        await androidPlugin?.requestExactAlarmsPermission();
      } catch (_) {
        // If exact alarms are denied, reminders fall back to inexact scheduling.
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleMedicine(Medicine medicine) async {
    await _configureLocalTimezone();
    await cancelMedicine(medicine.id);
    final androidScheduleMode = await _androidScheduleMode();

    for (final day in medicine.days) {
      final notificationId = notificationIdFor(medicine.id, day);
      await _plugin.zonedSchedule(
        id: notificationId,
        title: 'Time to take ${medicine.name}',
        body: '${medicine.dosage} | ${medicine.type.label}',
        scheduledDate: _nextInstanceOfDay(day, medicine.hour, medicine.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Medicine reminders',
            channelDescription: 'Scheduled reminders for taking medicines.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            sound: RawResourceAndroidNotificationSound(_soundName),
            enableVibration: true,
            category: AndroidNotificationCategory.reminder,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'medicine_reminder.wav',
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
          macOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'medicine_reminder.wav',
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        androidScheduleMode: androidScheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<AndroidScheduleMode> _androidScheduleMode() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    try {
      final canScheduleExact =
          await androidPlugin?.canScheduleExactNotifications();
      if (canScheduleExact == false) {
        return AndroidScheduleMode.inexactAllowWhileIdle;
      }
    } catch (_) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    return AndroidScheduleMode.exactAllowWhileIdle;
  }

  Future<void> showTestNotificationNow() {
    return _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch % 2147483647,
      title: 'Reminder sound test',
      body: 'This is a temporary test reminder for checking sound.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Medicine reminders',
          channelDescription: 'Scheduled reminders for taking medicines.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(_soundName),
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'medicine_reminder.wav',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'medicine_reminder.wav',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  Future<void> cancelMedicine(String medicineId) async {
    for (final day in Medicine.weekDays) {
      await _plugin.cancel(id: notificationIdFor(medicineId, day));
    }
  }

  Future<List<PendingNotificationRequest>> pendingRequests() {
    return _plugin.pendingNotificationRequests();
  }

  int notificationIdFor(String medicineId, String day) {
    final source = '$medicineId-$day';
    return source.hashCode.abs() % 2147483647;
  }

  tz.TZDateTime _nextInstanceOfDay(String day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final targetWeekday = Medicine.dayNumber(day);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduled.weekday != targetWeekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

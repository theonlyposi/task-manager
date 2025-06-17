import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/notification_model.dart';


class NotificationRepository {
  static const String _key = 'saved_notifications';

  Future<void> saveNotification(NotificationModel notification) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_key) ?? [];

    // Add new notification as JSON string
    existing.add(jsonEncode(notification.toMap()));

    await prefs.setStringList(_key, existing);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];

    return saved.map((e) => NotificationModel.fromMap(jsonDecode(e))).toList();
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

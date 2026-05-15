import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siankes/services/notification_service.dart';
import 'package:siankes/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get hasUnread => _unreadCount > 0;

  StreamSubscription? _notifSub;
  StreamSubscription? _unreadSub;

  void initStreams(String userId) {
    _notifSub?.cancel();
    _notifSub = _service.userNotificationsStream(userId).listen((data) {
      _notifications = data;
      notifyListeners();
    });

    _unreadSub?.cancel();
    _unreadSub = _service.unreadCountStream(userId).listen((count) {
      _unreadCount = count;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _service.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _service.markAllAsRead(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _service.deleteNotification(notificationId);
  }

  Future<void> clearAll(String userId) async {
    _isLoading = true;
    notifyListeners();
    await _service.clearAll(userId);
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    _unreadSub?.cancel();
    super.dispose();
  }
}

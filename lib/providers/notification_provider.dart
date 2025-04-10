import 'package:flutter/foundation.dart';
import 'package:smart_healthcare_system/models/notification_model.dart';
import 'package:smart_healthcare_system/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  Future<void> fetchNotifications(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _notifications = await _notificationService.getNotifications(userId);
      notifyListeners();
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updatedNotification = _notifications[index].copyWith(isRead: true);
        _notifications[index] = updatedNotification;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationService.markAllNotificationsAsRead(userId);
      
      // Update local state
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }
  
  Future<void> addHealthAlert({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        body: body,
        type: NotificationType.healthAlert,
        timestamp: DateTime.now(),
        isRead: false,
        data: data,
      );
      
      await _notificationService.addNotification(notification);
      
      // Update local state
      _notifications.insert(0, notification);
      notifyListeners();
      
      // Show local notification
      await _notificationService.showLocalNotification(
        notification.id,
        notification.title,
        notification.body,
        data,
      );
    } catch (e) {
      print('Error adding health alert: $e');
    }
  }
}


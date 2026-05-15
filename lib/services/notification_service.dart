import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../data/models/notification_model.dart';

/// Service for managing in-app notifications and FCM integration
class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Stream user's notifications
  Stream<List<NotificationModel>> userNotificationsStream(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList());
  }

  /// Get unread notification count
  Stream<int> unreadCountStream(String userId) {
    return _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String type = 'info',
    String? referenceId,
  }) async {
    final id = _uuid.v4();
    final notification = NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
    );
    await _db.collection(AppConstants.colNotifications).doc(id).set(notification.toMap());
  }

  /// Send queue called notification
  Future<void> sendQueueCalledNotification({
    required String userId,
    required String queueNumber,
    required String poliName,
  }) async {
    await sendNotification(
      userId: userId,
      title: '🔔 Giliran Anda!',
      body: 'Nomor antrian $queueNumber di $poliName sedang dipanggil. Silakan menuju ruangan.',
      type: 'queue',
    );
  }

  /// Send queue almost called notification
  Future<void> sendQueueAlmostCalledNotification({
    required String userId,
    required String queueNumber,
    required int remaining,
  }) async {
    await sendNotification(
      userId: userId,
      title: '⏳ Hampir Giliran Anda',
      body: 'Nomor antrian $queueNumber tinggal $remaining antrian lagi. Harap bersiap.',
      type: 'queue',
    );
  }

  /// Send booking reminder
  Future<void> sendBookingReminder({
    required String userId,
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await sendNotification(
      userId: userId,
      title: '📅 Pengingat Booking',
      body: 'Anda memiliki jadwal konsultasi dengan $doctorName pada $date pukul $time.',
      type: 'reminder',
    );
  }

  /// Send booking confirmation
  Future<void> sendBookingConfirmation({
    required String userId,
    required String doctorName,
    required String date,
    required String time,
  }) async {
    await sendNotification(
      userId: userId,
      title: '✅ Booking Dikonfirmasi',
      body: 'Booking konsultasi dengan $doctorName pada $date pukul $time telah dikonfirmasi.',
      type: 'booking',
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _db.collection(AppConstants.colNotifications).doc(notificationId).update({
      'isRead': true,
    });
  }

  /// Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection(AppConstants.colNotifications).doc(notificationId).delete();
  }

  /// Clear all notifications for user
  Future<void> clearAll(String userId) async {
    final snap = await _db
        .collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}

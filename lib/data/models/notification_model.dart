import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // queue, booking, info, reminder
  final bool isRead;
  final String? referenceId;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.isRead = false,
    this.referenceId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'type': type,
    'isRead': isRead,
    'referenceId': referenceId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory NotificationModel.fromMap(Map<String, dynamic> map) => NotificationModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    title: map['title'] ?? '',
    body: map['body'] ?? '',
    type: map['type'] ?? 'info',
    isRead: map['isRead'] ?? false,
    referenceId: map['referenceId'],
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromMap({...data, 'id': doc.id});
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id, userId: userId, title: title, body: body,
    type: type, referenceId: referenceId, createdAt: createdAt,
    isRead: isRead ?? this.isRead,
  );

  IconType get iconType {
    switch (type) {
      case 'queue': return IconType.queue;
      case 'booking': return IconType.booking;
      case 'reminder': return IconType.reminder;
      default: return IconType.info;
    }
  }
}

enum IconType { queue, booking, reminder, info }

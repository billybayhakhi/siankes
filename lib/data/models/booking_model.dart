import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String doctorId;
  final String doctorName;
  final String poliId;
  final String poliName;
  final DateTime bookingDate;
  final String timeSlot;
  final String complaint;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.doctorId,
    required this.doctorName,
    required this.poliId,
    required this.poliName,
    required this.bookingDate,
    required this.timeSlot,
    this.complaint = '',
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'userName': userName,
    'doctorId': doctorId, 'doctorName': doctorName,
    'poliId': poliId, 'poliName': poliName,
    'bookingDate': Timestamp.fromDate(bookingDate),
    'timeSlot': timeSlot, 'complaint': complaint, 'status': status,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory BookingModel.fromMap(Map<String, dynamic> map) => BookingModel(
    id: map['id'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    doctorId: map['doctorId'] ?? '',
    doctorName: map['doctorName'] ?? '',
    poliId: map['poliId'] ?? '',
    poliName: map['poliName'] ?? '',
    bookingDate: (map['bookingDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    timeSlot: map['timeSlot'] ?? '',
    complaint: map['complaint'] ?? '',
    status: map['status'] ?? 'pending',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel.fromMap({...data, 'id': doc.id});
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
}

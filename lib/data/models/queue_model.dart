import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  final String id;
  final String queueNumber;
  final String poliId;
  final String poliName;
  final String doctorId;
  final String doctorName;
  final String userId;
  final String userName;
  final String complaint;
  final String status; // waiting, called, done, skipped, cancelled
  final int position;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final String qrData;

  QueueModel({
    required this.id,
    required this.queueNumber,
    required this.poliId,
    required this.poliName,
    this.doctorId = '',
    this.doctorName = '',
    required this.userId,
    required this.userName,
    required this.complaint,
    this.status = 'waiting',
    this.position = 0,
    DateTime? createdAt,
    this.calledAt,
    this.completedAt,
    this.qrData = '',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id,
    'queueNumber': queueNumber,
    'poliId': poliId,
    'poliName': poliName,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'userId': userId,
    'userName': userName,
    'complaint': complaint,
    'status': status,
    'position': position,
    'createdAt': Timestamp.fromDate(createdAt),
    'calledAt': calledAt != null ? Timestamp.fromDate(calledAt!) : null,
    'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'qrData': qrData,
  };

  factory QueueModel.fromMap(Map<String, dynamic> map) => QueueModel(
    id: map['id'] ?? '',
    queueNumber: map['queueNumber'] ?? '',
    poliId: map['poliId'] ?? '',
    poliName: map['poliName'] ?? '',
    doctorId: map['doctorId'] ?? '',
    doctorName: map['doctorName'] ?? '',
    userId: map['userId'] ?? '',
    userName: map['userName'] ?? '',
    complaint: map['complaint'] ?? '',
    status: map['status'] ?? 'waiting',
    position: map['position'] ?? 0,
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    calledAt: (map['calledAt'] as Timestamp?)?.toDate(),
    completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    qrData: map['qrData'] ?? '',
  );

  factory QueueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QueueModel.fromMap({...data, 'id': doc.id});
  }

  QueueModel copyWith({String? status, DateTime? calledAt, DateTime? completedAt, int? position}) => QueueModel(
    id: id, queueNumber: queueNumber, poliId: poliId, poliName: poliName,
    doctorId: doctorId, doctorName: doctorName, userId: userId,
    userName: userName, complaint: complaint, createdAt: createdAt, qrData: qrData,
    status: status ?? this.status,
    position: position ?? this.position,
    calledAt: calledAt ?? this.calledAt,
    completedAt: completedAt ?? this.completedAt,
  );

  bool get isWaiting => status == 'waiting';
  bool get isCalled => status == 'called';
  bool get isDone => status == 'done';
  bool get isSkipped => status == 'skipped';
  bool get isActive => isWaiting || isCalled;
}

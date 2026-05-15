import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../data/models/queue_model.dart';
import '../data/models/booking_model.dart';
import '../data/models/doctor_model.dart';
import '../core/constants/app_constants.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final NotificationService _notifService = NotificationService();

  // ═══════════════════════════════════════════
  // POLYCLINIC OPERATIONS
  // ═══════════════════════════════════════════

  Stream<List<PolyclinicModel>> polyclinicsStream() {
    return _db.collection(AppConstants.colPolyclinics).snapshots().map(
      (snap) => snap.docs.map((d) => PolyclinicModel.fromFirestore(d)).toList(),
    );
  }

  Future<void> seedPolyclinics() async {
    final snap = await _db.collection(AppConstants.colPolyclinics).get();
    if (snap.docs.isNotEmpty) return;
    for (final poli in AppConstants.defaultPolyclinics) {
      await _db.collection(AppConstants.colPolyclinics).doc(poli['id']).set(
        PolyclinicModel(
          id: poli['id'], name: poli['name'], icon: poli['icon'],
          description: poli['description'], color: poli['color'],
        ).toMap(),
      );
    }
  }

  // ═══════════════════════════════════════════
  // DOCTOR OPERATIONS
  // ═══════════════════════════════════════════

  Stream<List<DoctorModel>> doctorsStream() {
    return _db.collection(AppConstants.colDoctors).snapshots().map(
      (snap) => snap.docs.map((d) => DoctorModel.fromFirestore(d)).toList(),
    );
  }

  Stream<List<DoctorModel>> doctorsByPoliStream(String poliId) {
    return _db.collection(AppConstants.colDoctors)
        .where('poliId', isEqualTo: poliId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DoctorModel.fromFirestore(d)).toList());
  }

  Future<void> seedDoctors() async {
    final snap = await _db.collection(AppConstants.colDoctors).get();
    if (snap.docs.isNotEmpty) return;
    for (final doc in AppConstants.defaultDoctors) {
      await _db.collection(AppConstants.colDoctors).doc(doc['id']).set(
        DoctorModel(
          id: doc['id'], name: doc['name'],
          specialization: doc['specialization'], poliId: doc['poliId'],
          photoUrl: doc['photoUrl'], rating: (doc['rating'] as num).toDouble(),
          experience: doc['experience'], schedule: doc['schedule'],
          availableSlots: ['08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30','13:00','13:30','14:00'],
        ).toMap(),
      );
    }
  }

  // ═══════════════════════════════════════════
  // QUEUE OPERATIONS (REALTIME)
  // ═══════════════════════════════════════════

  /// Stream all active queues for today
  Stream<List<QueueModel>> activeQueuesStream() {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _db.collection(AppConstants.colQueues)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueModel.fromFirestore(d)).toList());
  }

  /// Stream queues by poli
  Stream<List<QueueModel>> queuesByPoliStream(String poliId) {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _db.collection(AppConstants.colQueues)
        .where('poliId', isEqualTo: poliId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueModel.fromFirestore(d)).toList());
  }

  /// Stream user's queues
  Stream<List<QueueModel>> userQueuesStream(String userId) {
    return _db.collection(AppConstants.colQueues)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => QueueModel.fromFirestore(d)).toList());
  }

  /// Take a queue number
  Future<QueueModel> takeQueue({
    required String poliId,
    required String poliName,
    required String doctorId,
    required String doctorName,
    required String userId,
    required String userName,
    required String complaint,
  }) async {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Get count of today's queues for this poli
    final existing = await _db.collection(AppConstants.colQueues)
        .where('poliId', isEqualTo: poliId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();

    final nextNumber = existing.docs.length + 1;
    final prefix = poliId.substring(0, 1).toUpperCase();
    final queueNumber = '$prefix${nextNumber.toString().padLeft(3, '0')}';
    final id = _uuid.v4();
    final qrData = 'SIANKES|$id|$queueNumber|$poliId|${DateTime.now().toIso8601String()}';

    final queue = QueueModel(
      id: id, queueNumber: queueNumber, poliId: poliId, poliName: poliName,
      doctorId: doctorId, doctorName: doctorName, userId: userId,
      userName: userName, complaint: complaint, position: nextNumber,
      qrData: qrData,
    );

    await _db.collection(AppConstants.colQueues).doc(id).set(queue.toMap());

    // Update polyclinic totalQueue
    await _db.collection(AppConstants.colPolyclinics).doc(poliId).update({
      'totalQueue': FieldValue.increment(1),
    });

    // Send notification to user
    await _notifService.sendNotification(
      userId: userId,
      title: '✅ Antrian Berhasil Diambil',
      body: 'Nomor antrian Anda: $queueNumber di $poliName. Silakan pantau status antrian.',
      type: 'queue',
      referenceId: id,
    );

    return queue;
  }

  /// Call next patient (admin)
  Future<void> callNextPatient(String poliId) async {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Mark current "called" as "done"
    final calledSnap = await _db.collection(AppConstants.colQueues)
        .where('poliId', isEqualTo: poliId)
        .where('status', isEqualTo: 'called')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();

    for (final doc in calledSnap.docs) {
      await doc.reference.update({
        'status': 'done',
        'completedAt': Timestamp.now(),
      });
      // Notify previous patient that their visit is done
      final prevQueue = QueueModel.fromFirestore(doc);
      await _notifService.sendNotification(
        userId: prevQueue.userId,
        title: '✅ Pelayanan Selesai',
        body: 'Antrian ${prevQueue.queueNumber} di ${prevQueue.poliName} telah selesai. Terima kasih.',
        type: 'queue',
      );
    }

    // Find next waiting patient
    final waitingSnap = await _db.collection(AppConstants.colQueues)
        .where('poliId', isEqualTo: poliId)
        .where('status', isEqualTo: 'waiting')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .orderBy('createdAt')
        .limit(1)
        .get();

    if (waitingSnap.docs.isNotEmpty) {
      await waitingSnap.docs.first.reference.update({
        'status': 'called',
        'calledAt': Timestamp.now(),
      });

      // Update polyclinic currentServing
      final q = QueueModel.fromFirestore(waitingSnap.docs.first);
      await _db.collection(AppConstants.colPolyclinics).doc(poliId).update({
        'currentServing': q.position,
      });

      // Send notification to the called patient
      await _notifService.sendQueueCalledNotification(
        userId: q.userId,
        queueNumber: q.queueNumber,
        poliName: q.poliName,
      );

      // Notify next-in-line patient (2 ahead)
      final nextWaiting = await _db.collection(AppConstants.colQueues)
          .where('poliId', isEqualTo: poliId)
          .where('status', isEqualTo: 'waiting')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .orderBy('createdAt')
          .limit(2)
          .get();

      if (nextWaiting.docs.length >= 2) {
        final nextQ = QueueModel.fromFirestore(nextWaiting.docs[1]);
        await _notifService.sendQueueAlmostCalledNotification(
          userId: nextQ.userId,
          queueNumber: nextQ.queueNumber,
          remaining: 2,
        );
      }
      if (nextWaiting.docs.isNotEmpty) {
        final nextQ = QueueModel.fromFirestore(nextWaiting.docs.first);
        await _notifService.sendQueueAlmostCalledNotification(
          userId: nextQ.userId,
          queueNumber: nextQ.queueNumber,
          remaining: 1,
        );
      }
    }
  }

  /// Skip a patient
  Future<void> skipPatient(String queueId) async {
    final doc = await _db.collection(AppConstants.colQueues).doc(queueId).get();
    await _db.collection(AppConstants.colQueues).doc(queueId).update({
      'status': 'skipped',
      'completedAt': Timestamp.now(),
    });
    if (doc.exists) {
      final q = QueueModel.fromFirestore(doc);
      await _notifService.sendNotification(
        userId: q.userId,
        title: '⚠️ Antrian Terlewat',
        body: 'Antrian ${q.queueNumber} di ${q.poliName} telah dilewati. Hubungi petugas untuk info lebih lanjut.',
        type: 'queue',
      );
    }
  }

  /// Cancel queue
  Future<void> cancelQueue(String queueId) async {
    await _db.collection(AppConstants.colQueues).doc(queueId).update({
      'status': 'cancelled',
    });
  }

  /// Reset all queues for a poli (admin)
  Future<void> resetPoliQueues(String poliId) async {
    final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final snap = await _db.collection(AppConstants.colQueues)
        .where('poliId', isEqualTo: poliId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    await _db.collection(AppConstants.colPolyclinics).doc(poliId).update({
      'currentServing': 0, 'totalQueue': 0,
    });
  }

  // ═══════════════════════════════════════════
  // BOOKING OPERATIONS
  // ═══════════════════════════════════════════

  Future<BookingModel> createBooking({
    required String userId, required String userName,
    required String doctorId, required String doctorName,
    required String poliId, required String poliName,
    required DateTime bookingDate, required String timeSlot,
    String complaint = '',
  }) async {
    final id = _uuid.v4();
    final booking = BookingModel(
      id: id, userId: userId, userName: userName,
      doctorId: doctorId, doctorName: doctorName,
      poliId: poliId, poliName: poliName,
      bookingDate: bookingDate, timeSlot: timeSlot,
      complaint: complaint,
    );
    await _db.collection(AppConstants.colBookings).doc(id).set(booking.toMap());

    // Send booking confirmation notification
    await _notifService.sendBookingConfirmation(
      userId: userId,
      doctorName: doctorName,
      date: '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}',
      time: timeSlot,
    );

    return booking;
  }

  Stream<List<BookingModel>> userBookingsStream(String userId) {
    return _db.collection(AppConstants.colBookings)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => BookingModel.fromFirestore(d)).toList());
  }

  Future<void> cancelBooking(String bookingId) async {
    await _db.collection(AppConstants.colBookings).doc(bookingId).update({'status': 'cancelled'});
  }

  Future<void> confirmBooking(String bookingId) async {
    await _db.collection(AppConstants.colBookings).doc(bookingId).update({'status': 'confirmed'});
  }

  Future<void> completeBooking(String bookingId) async {
    await _db.collection(AppConstants.colBookings).doc(bookingId).update({'status': 'completed'});
  }

  // ═══════════════════════════════════════════
  // NOTIFICATIONS (legacy - for backward compat)
  // ═══════════════════════════════════════════

  Future<void> addNotification({
    required String userId, required String title, required String body,
  }) async {
    await _notifService.sendNotification(userId: userId, title: title, body: body);
  }

  Stream<List<Map<String, dynamic>>> userNotificationsStream(String userId) {
    return _db.collection(AppConstants.colNotifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }
}

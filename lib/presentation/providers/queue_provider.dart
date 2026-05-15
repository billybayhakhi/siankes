import 'dart:async';
import 'package:flutter/material.dart';
import 'package:siankes/services/firestore_service.dart';
import 'package:siankes/data/models/queue_model.dart';
import 'package:siankes/data/models/doctor_model.dart';

class QueueProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<QueueModel> _allQueues = [];
  List<QueueModel> _myQueues = [];
  List<PolyclinicModel> _polyclinics = [];
  bool _isLoading = false;
  String _error = '';

  List<QueueModel> get allQueues => _allQueues;
  List<QueueModel> get myQueues => _myQueues;
  List<PolyclinicModel> get polyclinics => _polyclinics;
  bool get isLoading => _isLoading;
  String get error => _error;

  StreamSubscription? _queueSub;
  StreamSubscription? _myQueueSub;
  StreamSubscription? _poliSub;

  void initStreams(String userId) {
    _poliSub?.cancel();
    _poliSub = _firestoreService.polyclinicsStream().listen((data) {
      _polyclinics = data;
      notifyListeners();
    });

    _queueSub?.cancel();
    _queueSub = _firestoreService.activeQueuesStream().listen((data) {
      _allQueues = data;
      notifyListeners();
    });

    _myQueueSub?.cancel();
    _myQueueSub = _firestoreService.userQueuesStream(userId).listen((data) {
      _myQueues = data;
      notifyListeners();
    });
  }

  List<QueueModel> getActiveQueuesByPoli(String poliId) =>
      _allQueues.where((q) => q.poliId == poliId && q.isActive).toList();

  List<QueueModel> get myActiveQueues =>
      _myQueues.where((q) => q.isActive).toList();

  QueueModel? getMyActiveQueueForPoli(String poliId, String userId) {
    try {
      return _allQueues.firstWhere(
        (q) => q.poliId == poliId && q.userId == userId && q.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  int getWaitingCount(String poliId) =>
      _allQueues.where((q) => q.poliId == poliId && q.isWaiting).length;

  Future<QueueModel> takeQueue({
    required String poliId, required String poliName,
    required String doctorId, required String doctorName,
    required String userId, required String userName,
    required String complaint,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      final queue = await _firestoreService.takeQueue(
        poliId: poliId, poliName: poliName,
        doctorId: doctorId, doctorName: doctorName,
        userId: userId, userName: userName, complaint: complaint,
      );
      _isLoading = false;
      notifyListeners();
      return queue;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> callNext(String poliId) async {
    await _firestoreService.callNextPatient(poliId);
  }

  Future<void> skipPatient(String queueId) async {
    await _firestoreService.skipPatient(queueId);
  }

  Future<void> cancelQueue(String queueId) async {
    await _firestoreService.cancelQueue(queueId);
  }

  Future<void> resetPoli(String poliId) async {
    await _firestoreService.resetPoliQueues(poliId);
  }

  Future<void> seedData() async {
    await _firestoreService.seedPolyclinics();
    await _firestoreService.seedDoctors();
  }

  @override
  void dispose() {
    _queueSub?.cancel();
    _myQueueSub?.cancel();
    _poliSub?.cancel();
    super.dispose();
  }
}

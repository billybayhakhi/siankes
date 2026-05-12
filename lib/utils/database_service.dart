import 'dart:async';
import '../models/queue_model.dart';
import 'db_helper.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final _dbHelper = DBHelper();

  // Daftar Poli (Integrated from AntrianService)
  final List<Map<String, dynamic>> daftarPoli = [
    {'id': 'umum', 'nama': 'Poli Umum', 'icon': '🏥', 'dokter': 'dr. Budi Santoso'},
    {'id': 'gigi', 'nama': 'Poli Gigi', 'icon': '🦷', 'dokter': 'drg. Siti Rahayu'},
    {'id': 'anak', 'nama': 'Poli Anak', 'icon': '👶', 'dokter': 'dr. Andi Wijaya'},
    {'id': 'kandungan', 'nama': 'Poli Kandungan', 'icon': '🤰', 'dokter': 'dr. Dewi Kusuma'},
    {'id': 'mata', 'nama': 'Poli Mata', 'icon': '👁️', 'dokter': 'dr. Rudi Hermawan'},
  ];

  // Streams for Real-time Updates
  final _queueStreamController = StreamController<List<QueueEntry>>.broadcast();
  final _statusStreamController = StreamController<Map<String, ClinicStatus>>.broadcast();

  Stream<List<QueueEntry>> get queueStream async* {
    yield await _dbHelper.getAllQueues();
    yield* _queueStreamController.stream;
  }
  Stream<Map<String, ClinicStatus>> get statusStream async* {
    yield await _dbHelper.getClinicStatus();
    yield* _statusStreamController.stream;
  }

  // Sync state with SQL Database
  Future<void> init() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    final queues = await _dbHelper.getAllQueues();
    final status = await _dbHelper.getClinicStatus();
    
    _queueStreamController.add(queues);
    _statusStreamController.add(status);
  }

  // --- Actions ---

  Future<QueueEntry> addQueue({
    required String poliId,
    required String poliNama,
    required String namaUser,
    required String keluhan,
  }) async {
    final status = await _dbHelper.getClinicStatus();
    final totalInPoli = status[poliId]?.totalQueue ?? 0;
    
    final nextNumber = totalInPoli + 1;
    final prefix = poliId.substring(0, 1).toUpperCase();
    final nomor = '$prefix${nextNumber.toString().padLeft(3, '0')}';

    final entry = QueueEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomor: nomor,
      poliId: poliId,
      poliNama: poliNama,
      namaUser: namaUser,
      keluhan: keluhan,
      waktu: DateTime.now(),
    );

    await _dbHelper.insertQueue(entry);
    await _refresh();
    return entry;
  }

  Future<void> approveQueue(String id) async {
    await _dbHelper.approveQueue(id);
    await _refresh();
  }

  Future<void> callNext(String poliId) async {

    await _dbHelper.callNext(poliId);
    await _refresh();
  }

  Future<void> resetQueue(String poliId) async {
    await _dbHelper.clearPoli(poliId);
    await _refresh();
  }

  void dispose() {
    _queueStreamController.close();
    _statusStreamController.close();
  }
}


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/queue_model.dart';

class DBHelper {
  static Database? _database;
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  // Mock data for Web
  final List<Map<String, dynamic>> _webQueues = [];
  final Map<String, Map<String, dynamic>> _webClinicStatus = {
    'umum': {'poliId': 'umum', 'currentServing': 0, 'totalQueue': 0},
    'gigi': {'poliId': 'gigi', 'currentServing': 0, 'totalQueue': 0},
    'anak': {'poliId': 'anak', 'currentServing': 0, 'totalQueue': 0},
    'kandungan': {'poliId': 'kandungan', 'currentServing': 0, 'totalQueue': 0},
    'mata': {'poliId': 'mata', 'currentServing': 0, 'totalQueue': 0},
  };
  final List<Map<String, dynamic>> _webUsers = [
    {
      'name': 'Administrator',
      'email': 'admin@siankes.com',
      'password': 'admin123',
      'role': 'admin',
      'phone': '08123456789'
    }
  ];

  Future<Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'siankes.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Queues
    await db.execute('''
      CREATE TABLE queues (
        id TEXT PRIMARY KEY,
        nomor TEXT,
        poliId TEXT,
        poliNama TEXT,
        namaUser TEXT,
        keluhan TEXT,
        waktu TEXT,
        status TEXT
      )
    ''');

    // Tabel Clinic Status
    await db.execute('''
      CREATE TABLE clinic_status (
        poliId TEXT PRIMARY KEY,
        currentServing INTEGER,
        totalQueue INTEGER
      )
    ''');

    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        phone TEXT,
        role TEXT
      )
    ''');


    // Insert Default Admin
    await db.insert('users', {
      'name': 'Administrator',
      'email': 'admin@siankes.com',
      'password': 'admin123',
      'role': 'admin',
      'phone': '08123456789'
    });

    // Initial data for clinic status
    final polis = ['umum', 'gigi', 'anak', 'kandungan', 'mata'];
    for (var poliId in polis) {
      await db.insert('clinic_status', {
        'poliId': poliId,
        'currentServing': 0,
        'totalQueue': 0,
      });
    }
  }

  // --- Queue Operations ---

  Future<void> insertQueue(QueueEntry queue) async {
    if (kIsWeb) {
      _webQueues.add(queue.toMap());
      final status = _webClinicStatus[queue.poliId]!;
      status['totalQueue'] = (status['totalQueue'] as int) + 1;
      return;
    }
    final db = await database;
    await db!.insert('queues', queue.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Update total queue in clinic_status
    await db!.execute(
      'UPDATE clinic_status SET totalQueue = totalQueue + 1 WHERE poliId = ?',
      [queue.poliId],
    );
  }

  Future<List<QueueEntry>> getAllQueues() async {
    if (kIsWeb) {
      return _webQueues.map((m) => QueueEntry.fromMap(m)).toList();
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('queues', orderBy: 'waktu ASC');
    return List.generate(maps.length, (i) => QueueEntry.fromMap(maps[i]));
  }

  Future<void> updateQueueStatus(String id, String status) async {
    if (kIsWeb) {
      final index = _webQueues.indexWhere((q) => q['id'] == id);
      if (index != -1) _webQueues[index]['status'] = status;
      return;
    }
    final db = await database;
    await db!.update('queues', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> approveQueue(String id) async {
    await updateQueueStatus(id, 'approved');
  }


  Future<void> callNext(String poliId) async {
    if (kIsWeb) {
      final status = _webClinicStatus[poliId]!;
      int current = status['currentServing'] as int;
      int total = status['totalQueue'] as int;

      if (current < total) {
        int next = current + 1;
        status['currentServing'] = next;
        
        // Update status in queues table for that number
        String prefix = poliId.substring(0, 1).toUpperCase();
        String nextNomor = '$prefix${next.toString().padLeft(3, '0')}';
        
        final nextIdx = _webQueues.indexWhere((q) => q['poliId'] == poliId && q['nomor'] == nextNomor);
        if (nextIdx != -1) _webQueues[nextIdx]['status'] = 'calling';
        
        // Finish previous one
        if (current > 0) {
          String prevNomor = '$prefix${current.toString().padLeft(3, '0')}';
          final prevIdx = _webQueues.indexWhere((q) => q['poliId'] == poliId && q['nomor'] == prevNomor);
          if (prevIdx != -1) _webQueues[prevIdx]['status'] = 'finished';
        }
      }
      return;
    }

    final db = await database;
    
    // Get current serving
    final result = await db!.query('clinic_status', where: 'poliId = ?', whereArgs: [poliId]);
    if (result.isNotEmpty) {
      int current = result.first['currentServing'] as int;
      int total = result.first['totalQueue'] as int;

      if (current < total) {
        int next = current + 1;
        await db!.update('clinic_status', {'currentServing': next}, where: 'poliId = ?', whereArgs: [poliId]);
        
        // Update status in queues table for that number
        String prefix = poliId.substring(0, 1).toUpperCase();
        String nextNomor = '$prefix${next.toString().padLeft(3, '0')}';
        
        await db!.update('queues', {'status': 'calling'}, where: 'poliId = ? AND nomor = ?', whereArgs: [poliId, nextNomor]);
        
        // Finish previous one
        if (current > 0) {
          String prevNomor = '$prefix${current.toString().padLeft(3, '0')}';
          await db!.update('queues', {'status': 'finished'}, where: 'poliId = ? AND nomor = ?', whereArgs: [poliId, prevNomor]);
        }
      }
    }
  }

  Future<Map<String, ClinicStatus>> getClinicStatus() async {
    if (kIsWeb) {
      return _webClinicStatus.map((key, value) => MapEntry(key, ClinicStatus(
        poliId: value['poliId'],
        currentServing: value['currentServing'],
        totalQueue: value['totalQueue'],
      )));
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('clinic_status');
    
    Map<String, ClinicStatus> statusMap = {};
    for (var m in maps) {
      statusMap[m['poliId']] = ClinicStatus(
        poliId: m['poliId'],
        currentServing: m['currentServing'],
        totalQueue: m['totalQueue'],
      );
    }
    return statusMap;
  }

  Future<void> clearPoli(String poliId) async {
    if (kIsWeb) {
      _webQueues.removeWhere((q) => q['poliId'] == poliId);
      _webClinicStatus[poliId] = {'poliId': poliId, 'currentServing': 0, 'totalQueue': 0};
      return;
    }
    final db = await database;
    await db!.delete('queues', where: 'poliId = ?', whereArgs: [poliId]);
    await db!.update('clinic_status', {'currentServing': 0, 'totalQueue': 0}, where: 'poliId = ?', whereArgs: [poliId]);
  }

  // --- Auth Operations ---

  Future<int> registerUser(String name, String email, String phone, String password) async {
    if (kIsWeb) {
      if (_webUsers.any((u) => u['email'] == email)) {
        throw Exception('UNIQUE constraint failed: users.email');
      }
      _webUsers.add({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'user' // Default role
      });
      return _webUsers.length;
    }
    final db = await database;
    return await db!.insert('users', {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'role': 'user' // Default role
    });
  }


  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    if (kIsWeb) {
      // Demo logic for easy login
      if (email == 'admin' && password == '123456') {
        return _webUsers.firstWhere((u) => u['role'] == 'admin');
      }
      try {
        return _webUsers.firstWhere((u) => u['email'] == email && u['password'] == password);
      } catch (_) {
        return null;
      }
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }
}

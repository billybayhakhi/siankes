import 'package:flutter/material.dart';
import 'db_helper.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?['role'] == 'admin';

  Future<String?> register({
    required String nama,
    required String email,
    required String noHp,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);
      
      // Simpan nama (bisa juga disimpan ke Firestore nanti)
      await userCredential.user?.updateDisplayName(nama);
      
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        return 'Email sudah terdaftar!';
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }


  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      
      if (userCredential.user != null) {
        // Buat data user sementara (nanti bisa dihubungkan ke Firestore)
        _currentUser = {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? email.split('@')[0],
          'role': email == 'admin@siankes.com' ? 'admin' : 'user', 
        };
        notifyListeners();
        return _currentUser;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:siankes/services/auth_service.dart';
import 'package:siankes/data/models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String _errorMessage = '';

  AuthState get state => _state;
  UserModel? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _state = AuthState.loading;
      notifyListeners();
      try {
        _user = await _authService.getCurrentUserProfile();
        _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
      } catch (e) {
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await _authService.login(email: email, password: password);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan. Silakan coba lagi.';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await _authService.signInWithGoogle();
      if (_user != null) {
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      } else {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Tampilkan error asli untuk memudahkan debugging
      final msg = e.toString();
      if (msg.contains('sign_in_cancelled') || msg.contains('canceled')) {
        _errorMessage = '';  // User cancel, tidak perlu error
      } else if (msg.contains('network_error') || msg.contains('SocketException')) {
        _errorMessage = 'Tidak ada koneksi internet.';
      } else if (msg.contains('sign_in_failed') || msg.contains('ApiException: 10')) {
        _errorMessage = 'Google Sign-In gagal. Pastikan SHA-1 sudah didaftarkan di Firebase Console.';
      } else {
        _errorMessage = 'Gagal login dengan Google: $msg';
      }
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name, required String email,
    required String phone, required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await _authService.register(
        name: name, email: email, phone: phone, password: password,
      );
      await _authService.logout();
      _user = null;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _state = AuthState.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan saat mendaftar: $e';
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim email reset password.';
      notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    await _authService.updateProfile(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found': return 'Akun tidak ditemukan.';
      case 'wrong-password': return 'Password salah.';
      case 'email-already-in-use': return 'Email sudah terdaftar.';
      case 'weak-password': return 'Password terlalu lemah.';
      case 'invalid-email': return 'Format email tidak valid.';
      case 'too-many-requests': return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'invalid-credential': return 'Email atau password salah.';
      default: return 'Terjadi kesalahan. ($code)';
    }
  }
}

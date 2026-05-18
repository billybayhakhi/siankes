import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Track whether GoogleSignIn.instance.initialize() has been called
  bool _googleSignInInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (!_googleSignInInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleSignInInitialized = true;
    }
  }

  /// Register new user with email & password, then save profile to Firestore
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final userModel = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email.trim(),
      phone: phone,
      role: email.trim() == AppConstants.adminEmail ? 'admin' : 'user',
    );

    await _firestore
        .collection(AppConstants.colUsers)
        .doc(userModel.uid)
        .set(userModel.toMap());

    return userModel;
  }

  /// Login with email & password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(credential.user!.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    // If user doc doesn't exist yet, create it
    final userModel = UserModel(
      uid: credential.user!.uid,
      name: credential.user!.displayName ?? email.split('@')[0],
      email: email.trim(),
      role: email.trim() == AppConstants.adminEmail ? 'admin' : 'user',
    );
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(userModel.uid)
        .set(userModel.toMap());
    return userModel;
  }

  /// Login with Google — menggunakan google_sign_in v7.x API
  Future<UserModel?> signInWithGoogle() async {
    try {
      User? user;

      if (kIsWeb) {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential =
            await _auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } else {
        // Inisialisasi GoogleSignIn singleton (hanya sekali)
        await _initGoogleSignIn();

        // Tampilkan dialog pilih akun Google (interactive)
        final GoogleSignInAccount googleUser =
            await GoogleSignIn.instance.authenticate();

        // Ambil idToken
        final GoogleSignInAuthentication googleAuth =
            googleUser.authentication;

        if (googleAuth.idToken == null) {
          throw Exception('Gagal mendapatkan idToken dari Google.');
        }

        // Ambil accessToken (opsional di v7, terpisah dari idToken)
        String? accessToken;
        try {
          final authz = await googleUser.authorizationClient
              .authorizeScopes(['email', 'profile']);
          accessToken = authz.accessToken;
        } catch (_) {
          // accessToken tidak wajib, lanjut dengan idToken saja
        }

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: accessToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (user != null) {
        final doc = await _firestore
            .collection(AppConstants.colUsers)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }

        final userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Pengguna',
          email: user.email ?? '',
          role: user.email == AppConstants.adminEmail ? 'admin' : 'user',
        );

        await _firestore
            .collection(AppConstants.colUsers)
            .doc(user.uid)
            .set(userModel.toMap());
        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile from Firestore
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.colUsers)
        .doc(user.uid)
        .get();

    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  /// Update user profile
  Future<void> updateProfile(UserModel userModel) async {
    await _firestore
        .collection(AppConstants.colUsers)
        .doc(userModel.uid)
        .update(userModel.toMap());
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Logout — sign out dari Google dan Firebase
  Future<void> logout() async {
    try {
      if (_googleSignInInitialized) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  /// Stream user profile changes
  Stream<UserModel?> userProfileStream(String uid) {
    return _firestore
        .collection(AppConstants.colUsers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}

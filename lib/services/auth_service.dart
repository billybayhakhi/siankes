import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

  /// Logout
  Future<void> logout() async {
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

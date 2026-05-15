import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String photoUrl;
  final String address;
  final String dateOfBirth;
  final String gender;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'user',
    this.photoUrl = '',
    this.address = '',
    this.dateOfBirth = '',
    this.gender = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'photoUrl': photoUrl,
    'address': address,
    'dateOfBirth': dateOfBirth,
    'gender': gender,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? 'user',
    photoUrl: map['photoUrl'] ?? '',
    address: map['address'] ?? '',
    dateOfBirth: map['dateOfBirth'] ?? '',
    gender: map['gender'] ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({...data, 'uid': doc.id});
  }

  UserModel copyWith({
    String? name, String? phone, String? photoUrl,
    String? address, String? dateOfBirth, String? gender,
  }) => UserModel(
    uid: uid, email: email, role: role, createdAt: createdAt,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    photoUrl: photoUrl ?? this.photoUrl,
    address: address ?? this.address,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
  );

  bool get isAdmin => role == 'admin';
}

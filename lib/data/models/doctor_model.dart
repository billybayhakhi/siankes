import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String specialization;
  final String poliId;
  final String photoUrl;
  final double rating;
  final String experience;
  final String schedule;
  final String description;
  final bool isAvailable;
  final List<String> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialization,
    required this.poliId,
    this.photoUrl = '',
    this.rating = 0.0,
    this.experience = '',
    this.schedule = '',
    this.description = '',
    this.isAvailable = true,
    this.availableSlots = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'specialization': specialization,
    'poliId': poliId, 'photoUrl': photoUrl, 'rating': rating,
    'experience': experience, 'schedule': schedule,
    'description': description, 'isAvailable': isAvailable,
    'availableSlots': availableSlots,
  };

  factory DoctorModel.fromMap(Map<String, dynamic> map) => DoctorModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    specialization: map['specialization'] ?? '',
    poliId: map['poliId'] ?? '',
    photoUrl: map['photoUrl'] ?? '',
    rating: (map['rating'] ?? 0.0).toDouble(),
    experience: map['experience'] ?? '',
    schedule: map['schedule'] ?? '',
    description: map['description'] ?? '',
    isAvailable: map['isAvailable'] ?? true,
    availableSlots: List<String>.from(map['availableSlots'] ?? []),
  );

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel.fromMap({...data, 'id': doc.id});
  }
}

class PolyclinicModel {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int color;
  final int currentServing;
  final int totalQueue;
  final bool isActive;

  PolyclinicModel({
    required this.id,
    required this.name,
    required this.icon,
    this.description = '',
    this.color = 0xFF1565C0,
    this.currentServing = 0,
    this.totalQueue = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'icon': icon,
    'description': description, 'color': color,
    'currentServing': currentServing, 'totalQueue': totalQueue,
    'isActive': isActive,
  };

  factory PolyclinicModel.fromMap(Map<String, dynamic> map) => PolyclinicModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    icon: map['icon'] ?? '🏥',
    description: map['description'] ?? '',
    color: map['color'] ?? 0xFF1565C0,
    currentServing: map['currentServing'] ?? 0,
    totalQueue: map['totalQueue'] ?? 0,
    isActive: map['isActive'] ?? true,
  );

  factory PolyclinicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PolyclinicModel.fromMap({...data, 'id': doc.id});
  }

  PolyclinicModel copyWith({int? currentServing, int? totalQueue}) => PolyclinicModel(
    id: id, name: name, icon: icon, description: description,
    color: color, isActive: isActive,
    currentServing: currentServing ?? this.currentServing,
    totalQueue: totalQueue ?? this.totalQueue,
  );
}

enum QueueStatus { waiting, approved, calling, finished, skipped }


class QueueEntry {
  final String id;
  final String nomor;
  final String poliId;
  final String poliNama;
  final String namaUser;
  final String keluhan;
  final DateTime waktu;
  final QueueStatus status;

  QueueEntry({
    required this.id,
    required this.nomor,
    required this.poliId,
    required this.poliNama,
    required this.namaUser,
    required this.keluhan,
    required this.waktu,
    this.status = QueueStatus.waiting,
  });

  QueueEntry copyWith({
    QueueStatus? status,
  }) {
    return QueueEntry(
      id: id,
      nomor: nomor,
      poliId: poliId,
      poliNama: poliNama,
      namaUser: namaUser,
      keluhan: keluhan,
      waktu: waktu,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor': nomor,
      'poliId': poliId,
      'poliNama': poliNama,
      'namaUser': namaUser,
      'keluhan': keluhan,
      'waktu': waktu.toIso8601String(),
      'status': status.name,
    };
  }

  factory QueueEntry.fromMap(Map<String, dynamic> map) {
    return QueueEntry(
      id: map['id'],
      nomor: map['nomor'],
      poliId: map['poliId'],
      poliNama: map['poliNama'],
      namaUser: map['namaUser'],
      keluhan: map['keluhan'],
      waktu: DateTime.parse(map['waktu']),
      status: QueueStatus.values.byName(map['status']),
    );
  }
}

class ClinicStatus {
  final String poliId;
  final int currentServing;
  final int totalQueue;

  ClinicStatus({
    required this.poliId,
    required this.currentServing,
    required this.totalQueue,
  });
}

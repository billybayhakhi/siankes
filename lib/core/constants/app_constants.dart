/// Application-wide constants for SIANKES
class AppConstants {
  AppConstants._();

  // ─── App Info ───
  static const String appName = 'SIANKES';
  static const String appFullName = 'Sistem Informasi Antrian Klinik';
  static const String appVersion = '2.0.0';
  static const String appTagline = 'Antrian Klinik Modern & Realtime';
  static const String clinicName = 'Klinik Sehat Sejahtera';
  static const String clinicAddress = 'Jl. Kesehatan No. 1, Jakarta';
  static const String clinicPhone = '(021) 1234-5678';

  // ─── Estimation ───
  static const int estimatedMinutesPerPatient = 10;

  // ─── Admin Credentials ───
  static const String adminEmail = 'admin@siankes.com';

  // ─── Shared Preferences Keys ───
  static const String prefKeyOnboarded = 'has_onboarded';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyUserId = 'user_id';

  // ─── Firestore Collections ───
  static const String colUsers = 'users';
  static const String colQueues = 'queues';
  static const String colBookings = 'bookings';
  static const String colDoctors = 'doctors';
  static const String colPolyclinics = 'polyclinics';
  static const String colNotifications = 'notifications';

  // ─── Queue Status ───
  static const String statusWaiting = 'waiting';
  static const String statusCalled = 'called';
  static const String statusDone = 'done';
  static const String statusSkipped = 'skipped';
  static const String statusCancelled = 'cancelled';

  // ─── Booking Status ───
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingCompleted = 'completed';
  static const String bookingCancelled = 'cancelled';

  // ─── User Roles ───
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
  static const String roleDoctor = 'doctor';

  // ─── Onboarding Data ───
  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'Antrian Online',
      'subtitle': 'Ambil nomor antrian klinik dari mana saja tanpa perlu datang & mengantre',
      'icon': 'queue',
    },
    {
      'title': 'Realtime Tracking',
      'subtitle': 'Pantau status antrian secara realtime dan dapatkan notifikasi saat giliran Anda',
      'icon': 'realtime',
    },
    {
      'title': 'Booking Jadwal',
      'subtitle': 'Reservasi jadwal dokter pilihan Anda kapan saja dengan mudah & cepat',
      'icon': 'booking',
    },
  ];

  // ─── Default Polyclinic Data (for seeding) ───
  static const List<Map<String, dynamic>> defaultPolyclinics = [
    {
      'id': 'umum',
      'name': 'Poli Umum',
      'icon': '🏥',
      'description': 'Layanan pemeriksaan kesehatan umum',
      'color': 0xFF1565C0,
    },
    {
      'id': 'gigi',
      'name': 'Poli Gigi',
      'icon': '🦷',
      'description': 'Layanan kesehatan gigi dan mulut',
      'color': 0xFF00897B,
    },
    {
      'id': 'anak',
      'name': 'Poli Anak',
      'icon': '👶',
      'description': 'Layanan kesehatan anak & imunisasi',
      'color': 0xFFE91E63,
    },
    {
      'id': 'kandungan',
      'name': 'Poli Kandungan',
      'icon': '🤰',
      'description': 'Layanan kesehatan ibu hamil & kandungan',
      'color': 0xFF7B1FA2,
    },
    {
      'id': 'mata',
      'name': 'Poli Mata',
      'icon': '👁️',
      'description': 'Layanan pemeriksaan kesehatan mata',
      'color': 0xFF00838F,
    },
  ];

  // ─── Default Doctors Data (for seeding) ───
  static const List<Map<String, dynamic>> defaultDoctors = [
    {
      'id': 'dr_budi',
      'name': 'dr. Budi Santoso, Sp.PD',
      'specialization': 'Dokter Umum',
      'poliId': 'umum',
      'photoUrl': '',
      'rating': 4.8,
      'experience': '12 tahun',
      'schedule': 'Senin - Jumat, 08:00 - 14:00',
    },
    {
      'id': 'drg_siti',
      'name': 'drg. Siti Rahayu',
      'specialization': 'Dokter Gigi',
      'poliId': 'gigi',
      'photoUrl': '',
      'rating': 4.9,
      'experience': '8 tahun',
      'schedule': 'Senin - Kamis, 09:00 - 15:00',
    },
    {
      'id': 'dr_andi',
      'name': 'dr. Andi Wijaya, Sp.A',
      'specialization': 'Dokter Anak',
      'poliId': 'anak',
      'photoUrl': '',
      'rating': 4.7,
      'experience': '10 tahun',
      'schedule': 'Selasa - Sabtu, 08:00 - 13:00',
    },
    {
      'id': 'dr_dewi',
      'name': 'dr. Dewi Kusuma, Sp.OG',
      'specialization': 'Dokter Kandungan',
      'poliId': 'kandungan',
      'photoUrl': '',
      'rating': 4.9,
      'experience': '15 tahun',
      'schedule': 'Senin - Rabu, 10:00 - 16:00',
    },
    {
      'id': 'dr_rudi',
      'name': 'dr. Rudi Hermawan, Sp.M',
      'specialization': 'Dokter Mata',
      'poliId': 'mata',
      'photoUrl': '',
      'rating': 4.6,
      'experience': '7 tahun',
      'schedule': 'Rabu - Sabtu, 08:00 - 14:00',
    },
  ];
}

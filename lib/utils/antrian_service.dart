class AntrianService {
  static final AntrianService _instance = AntrianService._internal();
  factory AntrianService() => _instance;
  AntrianService._internal();

  // Daftar Poli
  final List<Map<String, dynamic>> daftarPoli = [
    {'id': 'umum', 'nama': 'Poli Umum', 'icon': '🏥', 'dokter': 'dr. Budi Santoso'},
    {'id': 'gigi', 'nama': 'Poli Gigi', 'icon': '🦷', 'dokter': 'drg. Siti Rahayu'},
    {'id': 'anak', 'nama': 'Poli Anak', 'icon': '👶', 'dokter': 'dr. Andi Wijaya'},
    {'id': 'kandungan', 'nama': 'Poli Kandungan', 'icon': '🤰', 'dokter': 'dr. Dewi Kusuma'},
    {'id': 'mata', 'nama': 'Poli Mata', 'icon': '👁️', 'dokter': 'dr. Rudi Hermawan'},
  ];

  // Counter antrian per poli
  final Map<String, int> _counterPoli = {
    'umum': 0,
    'gigi': 0,
    'anak': 0,
    'kandungan': 0,
    'mata': 0,
  };

  // Antrian yang sedang dilayani per poli
  final Map<String, int> _sedangDilayani = {
    'umum': 0,
    'gigi': 0,
    'anak': 0,
    'kandungan': 0,
    'mata': 0,
  };

  // Riwayat antrian
  final List<Map<String, dynamic>> _riwayat = [];

  // Ambil nomor antrian
  Map<String, dynamic> ambilAntrian({
    required String poliId,
    required String namaUser,
    required String keluhan,
  }) {
    _counterPoli[poliId] = (_counterPoli[poliId] ?? 0) + 1;
    final nomor = _counterPoli[poliId]!;
    final nomorFormatted = 'A${nomor.toString().padLeft(3, '0')}';
    final poli = daftarPoli.firstWhere((p) => p['id'] == poliId);

    final antrian = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'nomor': nomorFormatted,
      'poliId': poliId,
      'poliNama': poli['nama'],
      'dokter': poli['dokter'],
      'namaUser': namaUser,
      'keluhan': keluhan,
      'waktu': DateTime.now().toString(),
      'status': 'Menunggu',
      'estimasi': '${(nomor - (_sedangDilayani[poliId] ?? 0)) * 10} menit',
    };

    _riwayat.insert(0, antrian);
    return antrian;
  }

  // Getter
  List<Map<String, dynamic>> get riwayat => _riwayat;
  int getSedangDilayani(String poliId) => _sedangDilayani[poliId] ?? 0;
  int getAntrianSekarang(String poliId) => _counterPoli[poliId] ?? 0;
}
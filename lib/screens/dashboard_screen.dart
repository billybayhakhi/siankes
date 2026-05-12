import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/database_service.dart';
import '../utils/auth_service.dart';
import '../models/queue_model.dart';

import 'ambil_antrian_screen.dart';
import 'status_antrian_screen.dart';
import 'riwayat_antrian_screen.dart';
import 'profil_screen.dart';
import 'admin_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Antrian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return StatusAntrianScreen(userName: widget.userName);
      case 2:
        return ProfilScreen(userName: widget.userName);

      default:
        return _buildHome();
    }
  }

  // ================= HOME =================
  Widget _buildHome() {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text('SIANKES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${widget.userName}! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selamat datang di SIANKES',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),

                    // INFO
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getTanggalHariIni(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // MENU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _menu(Icons.queue, 'Ambil Antrian', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AmbilAntrianScreen(
                            userName: widget.userName,
                          ),
                        ),
                      );
                    }),
                    _menu(Icons.history, 'Riwayat', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiwayatAntrianScreen(userName: widget.userName),
                        ),
                      );
                    }),

                    if (Provider.of<AuthService>(context, listen: false).isAdmin)
                      _menu(Icons.admin_panel_settings, 'Admin Panel', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboardScreen(),
                          ),
                        );
                      }),
                  ],

                ),
              ),

              const SizedBox(height: 24),

              // POLI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Poli Tersedia',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    StreamBuilder<Map<String, ClinicStatus>>(
                      stream: db.statusStream,
                      builder: (context, snapshot) {
                        final statusMap = snapshot.data ?? {};
                        
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: db.daftarPoli.length,
                          itemBuilder: (context, index) {
                            final poli = db.daftarPoli[index];
                            final status = statusMap[poli['id']];
                            final antrian = status?.currentServing ?? 0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(poli['icon'], style: const TextStyle(fontSize: 20)),
                                ),
                                title: Text(poli['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(poli['dokter'], style: const TextStyle(fontSize: 12)),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Melayani', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text('#$antrian', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _getTanggalHariIni() {
    final now = DateTime.now();
    const hari = ['Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'];
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];

    return '${hari[now.weekday % 7]}, ${now.day} ${bulan[now.month - 1]} ${now.year}';
  }
}
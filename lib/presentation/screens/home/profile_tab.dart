import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/constants/app_constants.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final queue = Provider.of<QueueProvider>(context);
    final booking = Provider.of<BookingProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 30),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: user?.photoUrl.isNotEmpty == true
                    ? ClipOval(child: Image.network(user!.photoUrl, fit: BoxFit.cover))
                    : Center(child: Text((user?.name ?? 'U')[0].toUpperCase(), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(height: 14),
              Text(user?.name ?? '-', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(user?.email ?? '-', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13)),
              if (auth.isAdmin) ...[
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text('ADMIN', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1))),
              ],
              const SizedBox(height: 20),
              // Stats row
              Row(children: [
                _statItem('Antrian', '${queue.myQueues.length}', Icons.confirmation_number_outlined),
                Container(width: 1, height: 40, color: Colors.white24),
                _statItem('Booking', '${booking.bookings.length}', Icons.calendar_month_outlined),
                Container(width: 1, height: 40, color: Colors.white24),
                _statItem('Selesai', '${queue.myQueues.where((q) => q.isDone).length}', Icons.check_circle_outline),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          // Menu Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(children: [
              FadeInUp(delay: const Duration(milliseconds: 100), child: _menuCard(context, Icons.person_outline_rounded, 'Edit Profil', 'Ubah informasi pribadi Anda', () => Navigator.pushNamed(context, '/edit-profile'))),
              FadeInUp(delay: const Duration(milliseconds: 150), child: _menuCard(context, Icons.lock_outline_rounded, 'Ubah Password', 'Reset password akun Anda', () => Navigator.pushNamed(context, '/forgot-password'))),
              FadeInUp(delay: const Duration(milliseconds: 200), child: _menuCard(context, Icons.notifications_outlined, 'Notifikasi', 'Kelola notifikasi Anda', () => Navigator.pushNamed(context, '/notifications'))),
              FadeInUp(delay: const Duration(milliseconds: 250), child: _menuCard(context, Icons.local_hospital_outlined, 'Daftar Poli', 'Lihat poli klinik tersedia', () => Navigator.pushNamed(context, '/polyclinics'))),
              if (auth.isAdmin) FadeInUp(delay: const Duration(milliseconds: 300), child: _menuCard(context, Icons.admin_panel_settings_rounded, 'Panel Admin', 'Kelola antrian & jadwal', () => Navigator.pushNamed(context, '/admin'))),
              FadeInUp(delay: const Duration(milliseconds: 350), child: _menuCard(context, Icons.info_outline_rounded, 'Tentang Aplikasi', 'SIANKES v${AppConstants.appVersion}', () => _showAbout(context))),
              const SizedBox(height: 12),
              // Logout
              FadeInUp(delay: const Duration(milliseconds: 400), child: GestureDetector(
                onTap: () => _confirmLogout(context, auth),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Text('Keluar', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
                  ]),
                ),
              )),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Expanded(child: Column(children: [
      Icon(icon, color: Colors.white70, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
      Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
    ]));
  }

  Widget _menuCard(BuildContext ctx, IconData icon, String title, String sub, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
            Text(sub, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ]),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Keluar?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
      content: Text('Anda yakin ingin keluar dari akun?', style: GoogleFonts.plusJakartaSans()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        TextButton(onPressed: () { Navigator.pop(ctx); auth.logout(); Navigator.pushReplacementNamed(context, '/login'); }, child: Text('Keluar', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _showAbout(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.local_hospital_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Text('SIANKES', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppConstants.appFullName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _aboutRow('Versi', AppConstants.appVersion),
        _aboutRow('Platform', 'Flutter + Firebase'),
        _aboutRow('Klinik', AppConstants.clinicName),
        _aboutRow('Alamat', AppConstants.clinicAddress),
        const SizedBox(height: 12),
        Text('Aplikasi antrian klinik modern dengan fitur realtime tracking, booking jadwal dokter, QR code, dan push notification.', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
    ));
  }

  Widget _aboutRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
      SizedBox(width: 70, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary))),
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
    ]));
  }
}

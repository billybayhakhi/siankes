import 'package:flutter/material.dart';
import 'dart:convert';
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
                    ? ClipOval(
                        child: user!.photoUrl.startsWith('data:image')
                            ? Image.memory(base64Decode(user.photoUrl.split(',').last), fit: BoxFit.cover)
                            : Image.network(user.photoUrl, fit: BoxFit.cover),
                      )
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
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  _statItem('Antrian', '${queue.myQueues.length}', Icons.confirmation_number_outlined),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _statItem('Booking', '${booking.bookings.length}', Icons.calendar_month_outlined),
                  Container(width: 1, height: 40, color: Colors.white24),
                  _statItem('Selesai', '${queue.myQueues.where((q) => q.isDone).length}', Icons.check_circle_outline),
                ]),
              ),
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
              FadeInUp(delay: const Duration(milliseconds: 400), child: Container(
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _confirmLogout(context, auth),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Text('Keluar dari Akun', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 15)),
                      ]),
                    ),
                  ),
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
        TextButton(onPressed: () { 
          Navigator.pop(ctx); 
          auth.logout(); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Anda telah berhasil keluar.', style: GoogleFonts.plusJakartaSans()), 
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            )
          );
          Navigator.pushReplacementNamed(context, '/'); 
        }, child: Text('Keluar', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700))),
      ],
    ));
  }

  void _showAbout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 36),
                        ),
                        const SizedBox(height: 12),
                        Text('SIANKES', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('Sistem Informasi Antrian Klinik Kesehatan', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  
                  // Body (Scrollable)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                            ),
                            child: Text(
                              'SIANKES membantu pasien mengambil antrian, melakukan booking jadwal, serta memantau status secara realtime.\n\nAplikasi mendukung pelayanan klinik digital dengan realtime queue tracking, QR Code check-in, push notification, dan monitoring secara efisien.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppColors.textSecondary, height: 1.5),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Informasi Sistem', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 10),
                          _aboutRow(Icons.info_outline_rounded, 'Versi', '2.0.0'),
                          _aboutRow(Icons.phone_iphone_rounded, 'Platform', 'Flutter + Firebase'),
                          _aboutRow(Icons.memory_rounded, 'Teknologi', 'Auth, Firestore, FCM'),
                          _aboutRow(Icons.code_rounded, 'Developer', 'Billy Bayhakhi'),
                          _aboutRow(Icons.event_rounded, 'Tahun', '2026'),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              '"Smart Queue System for Modern Healthcare Services."',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.primary, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Tutup', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _aboutRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

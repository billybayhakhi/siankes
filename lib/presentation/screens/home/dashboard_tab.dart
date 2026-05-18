import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import 'package:siankes/presentation/providers/notification_provider.dart';
import 'package:siankes/presentation/screens/home/health_article_screen.dart';
import '../../widgets/shared_widgets.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final queue = Provider.of<QueueProvider>(context);
    final booking = Provider.of<BookingProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);
    final user = auth.user;
    final myActive = queue.myActiveQueues;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // ─── HEADER ───
            Container(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(
                    child: Row(children: [
                      FadeInLeft(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          FadeInLeft(child: Text('Halo, Selamat Datang! 👋', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13))),
                          const SizedBox(height: 4),
                          FadeInLeft(delay: const Duration(milliseconds: 200), child: Text(user?.name ?? 'Pengguna', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                        ]),
                      ),
                    ]),
                  ),
                  Row(children: [
                    _headerIconBadge(Icons.notifications_outlined, () => Navigator.pushNamed(context, '/notifications'), notifProv.unreadCount),
                    const SizedBox(width: 8),
                    if (auth.isAdmin) _headerIcon(Icons.admin_panel_settings_rounded, () => Navigator.pushNamed(context, '/admin')),
                  ]),
                ]),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/doctors'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      const Icon(Icons.search_rounded, color: Colors.white60, size: 20),
                      const SizedBox(width: 12),
                      Text('Cari dokter atau layanan...', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13)),
                    ]),
                  ),
                ),
              ]),
            ),

            // ─── ACTIVE QUEUE CARD ───
            if (myActive.isNotEmpty) Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: FadeInUp(child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/queue-status', arguments: myActive.first),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: myActive.first.isCalled ? AppColors.successGradient : AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text(myActive.first.queueNumber, style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Antrian Aktif', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(myActive.first.poliName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(myActive.first.isCalled ? '🔔 Silakan masuk!' : '⏳ Menunggu giliran', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12)),
                    ])),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                  ]),
                ),
              )),
            ),

            // ─── SHORTCUT MENU ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: FadeInUp(delay: const Duration(milliseconds: 200), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Layanan'),
                const SizedBox(height: 14),
                Row(children: [
                  _menuItem(context, Icons.confirmation_number_rounded, 'Ambil\nAntrian', AppColors.primary, () => Navigator.pushNamed(context, '/take-queue')),
                  _menuItem(context, Icons.calendar_month_rounded, 'Booking\nJadwal', AppColors.secondary, () => Navigator.pushNamed(context, '/booking')),
                  _menuItem(context, Icons.medical_services_rounded, 'Daftar\nDokter', const Color(0xFF7B1FA2), () => Navigator.pushNamed(context, '/doctors')),
                  _menuItem(context, Icons.qr_code_scanner_rounded, 'Scan\nQR', const Color(0xFF00897B), () => Navigator.pushNamed(context, '/scan-qr')),
                ]),
              ])),
            ),

            // ─── UPCOMING BOOKING ───
            if (booking.upcomingBookings.isNotEmpty) Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: FadeInUp(delay: const Duration(milliseconds: 300), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Jadwal Mendatang'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10)]),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.event_rounded, color: AppColors.info),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(booking.upcomingBookings.first.doctorName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${DateFormatter.formatShortDate(booking.upcomingBookings.first.bookingDate)} • ${booking.upcomingBookings.first.timeSlot}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    StatusBadge(status: booking.upcomingBookings.first.status),
                  ]),
                ),
              ])),
            ),

            // ─── POLI LIST ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: FadeInUp(delay: const Duration(milliseconds: 400), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SectionHeader(title: 'Poli Tersedia', actionText: 'Lihat Semua', onAction: () => Navigator.pushNamed(context, '/polyclinics')),
                const SizedBox(height: 12),
                ...queue.polyclinics.take(4).map((poli) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
                  child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: Color(poli.color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(poli.icon, style: const TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(poli.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(poli.description, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('Melayani', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textTertiary)),
                      Text('#${poli.currentServing}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Color(poli.color))),
                    ]),
                  ]),
                )),
              ])),
            ),

            // ─── INFO CARDS ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: FadeInUp(delay: const Duration(milliseconds: 500), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SectionHeader(title: 'Informasi Kesehatan'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    _healthCard(context, 'Cuci Tangan', 'Pentingnya mencuci tangan dengan sabun untuk mencegah penyakit', Icons.clean_hands_rounded, AppColors.primary),
                    _healthCard(context, 'Vaksinasi', 'Jadwal vaksinasi anak dan dewasa tersedia di klinik', Icons.vaccines_rounded, AppColors.secondary),
                    _healthCard(context, 'Pola Hidup Sehat', 'Tips menjaga pola hidup sehat setiap hari', Icons.favorite_rounded, const Color(0xFFE91E63)),
                  ]),
                ),
              ])),
            ),
            const SizedBox(height: 120), // Tambahkan padding bawah lebih luas
          ]),
        ),
      ),
    );
  }

  Widget _headerIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _headerIconBadge(IconData icon, VoidCallback onTap, int badgeCount) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (badgeCount > 0) Positioned(
          right: 0, top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
            child: Text('$badgeCount', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.3)),
        ]),
      ),
    );
  }

  Widget _healthCard(BuildContext ctx, String title, String desc, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          ctx, 
          '/health-article',
          arguments: HealthArticleArgs(
            title: title,
            description: desc,
            icon: icon,
            color: color,
          ),
        );
      },
      child: Container(
        width: 220, margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          Text(desc, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

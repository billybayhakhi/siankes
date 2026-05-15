import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import '../../widgets/shared_widgets.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = Provider.of<QueueProvider>(context);
    final booking = Provider.of<BookingProvider>(context);
    final allHistory = queue.myQueues.where((q) => !q.isActive).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: DefaultTabController(
        length: 2,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Riwayat', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Riwayat antrian dan booking Anda', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Text('${allHistory.length + booking.bookings.length} Total', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 16),
              const TabBar(
                indicatorColor: Colors.white, indicatorWeight: 3,
                tabs: [Tab(text: 'ANTRIAN'), Tab(text: 'BOOKING')],
              ),
            ]),
          ),
          Expanded(
            child: TabBarView(children: [
              // Queue History
              allHistory.isEmpty
                  ? const EmptyStateWidget(icon: Icons.history_rounded, title: 'Belum Ada Riwayat', subtitle: 'Riwayat antrian akan muncul di sini')
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: allHistory.length,
                      itemBuilder: (ctx, i) {
                        final q = allHistory[i];
                        return FadeInUp(
                          delay: Duration(milliseconds: i * 50),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/history-detail-queue', arguments: q),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
                              child: Row(children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
                                  child: Center(child: Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(q.poliName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(DateFormatter.formatDateTime(q.createdAt), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                                ])),
                                StatusBadge(status: q.status),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
              // Booking History
              booking.bookings.isEmpty
                  ? const EmptyStateWidget(icon: Icons.calendar_month_outlined, title: 'Belum Ada Booking', subtitle: 'Riwayat booking akan muncul di sini')
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: booking.bookings.length,
                      itemBuilder: (ctx, i) {
                        final b = booking.bookings[i];
                        return FadeInUp(
                          delay: Duration(milliseconds: i * 50),
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/history-detail-booking', arguments: b),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
                              child: Row(children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(14)),
                                  child: const Icon(Icons.event_rounded, color: AppColors.info),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(b.doctorName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text('${DateFormatter.formatShortDate(b.bookingDate)} • ${b.timeSlot}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                                ])),
                                StatusBadge(status: b.status),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
            ]),
          ),
        ]),
      ),
    );
  }
}

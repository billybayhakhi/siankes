import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import 'package:siankes/services/notification_service.dart';
import '../../widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedPoliId = 'umum';
  final _notifService = NotificationService();

  @override
  void initState() {
    super.initState();
    // Inisialisasi stream booking untuk admin
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).adminInitStreams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text('Panel Admin', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/scan-qr'),
              tooltip: 'Scan QR',
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Antrian Live'),
              Tab(text: 'Booking Online'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildQueueTab(),
            _buildBookingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTab() {
    final qp = Provider.of<QueueProvider>(context);
    final poliQueues = qp.getActiveQueuesByPoli(_selectedPoliId);
    final allToday = qp.allQueues.where((q) => q.poliId == _selectedPoliId).toList();
    final waiting = allToday.where((q) => q.isWaiting).length;
    final done = allToday.where((q) => q.isDone).length;
    final currentPoli = qp.polyclinics.isNotEmpty
        ? qp.polyclinics.firstWhere((p) => p.id == _selectedPoliId, orElse: () => qp.polyclinics.first)
        : null;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(children: [
        // Poli Selector
        Container(
          height: 90, padding: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal, itemCount: qp.polyclinics.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemBuilder: (ctx, i) {
              final p = qp.polyclinics[i];
              final sel = _selectedPoliId == p.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedPoliId = p.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90, margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: sel ? AppColors.primaryGradient : null, color: sel ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: sel ? AppColors.primary.withOpacity(0.3) : AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(p.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    Text(p.name, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textPrimary)),
                  ]),
                ),
              );
            },
          ),
        ),
        // Stats
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
          Expanded(child: InfoCard(label: 'MENUNGGU', value: '$waiting', icon: Icons.hourglass_top_rounded, color: AppColors.warning)),
          const SizedBox(width: 12),
          Expanded(child: InfoCard(label: 'DILAYANI', value: '${currentPoli?.currentServing ?? 0}', icon: Icons.person_search_rounded, color: AppColors.primary)),
          const SizedBox(width: 12),
          Expanded(child: InfoCard(label: 'SELESAI', value: '$done', icon: Icons.check_circle_outline, color: AppColors.success)),
        ])),
        const SizedBox(height: 16),
        // Call Next Button
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: GestureDetector(
          onTap: () async {
            final messenger = ScaffoldMessenger.of(context);
            final waitingQueues = qp.allQueues.where((q) => q.poliId == _selectedPoliId && q.isWaiting).toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

            await qp.callNext(_selectedPoliId);

            if (waitingQueues.isNotEmpty) {
              final calledQueue = waitingQueues.first;
              await _notifService.sendQueueCalledNotification(userId: calledQueue.userId, queueNumber: calledQueue.queueNumber, poliName: calledQueue.poliName);
              if (waitingQueues.length > 1) {
                final nextQueue = waitingQueues[1];
                await _notifService.sendQueueAlmostCalledNotification(userId: nextQueue.userId, queueNumber: nextQueue.queueNumber, remaining: 1);
              }
            }
            messenger.showSnackBar(const SnackBar(content: Text('Pasien berikutnya dipanggil'), backgroundColor: AppColors.success));
          },
          child: Container(
            width: double.infinity, height: 60,
            decoration: BoxDecoration(gradient: AppColors.successGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.campaign_rounded, color: Colors.white, size: 26),
              const SizedBox(width: 12),
              Text('PANGGIL BERIKUTNYA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
            ]),
          ),
        )),
        const SizedBox(height: 20),
        // Queue List
        Container(
          width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Daftar Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            poliQueues.isEmpty
                ? const EmptyStateWidget(icon: Icons.checklist_rounded, title: 'Tidak Ada Antrian', subtitle: 'Belum ada pasien')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: poliQueues.length,
                    itemBuilder: (ctx, i) {
                      final q = poliQueues[i];
                      return FadeInUp(
                        delay: Duration(milliseconds: i * 50),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: q.isCalled ? AppColors.successLight : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: q.isCalled ? Border.all(color: AppColors.success, width: 1.5) : null,
                          ),
                          child: Row(children: [
                            Container(
                              width: 46, height: 46,
                              decoration: BoxDecoration(color: q.isCalled ? AppColors.success : AppColors.primary, borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13))),
                            ),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(q.userName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text(q.complaint, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                            ])),
                            if (q.isWaiting) IconButton(icon: const Icon(Icons.skip_next_rounded, color: AppColors.error), onPressed: () => qp.skipPatient(q.id)),
                            StatusBadge(status: q.status),
                          ]),
                        ),
                      );
                    },
                  ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBookingTab() {
    final bp = Provider.of<BookingProvider>(context);
    final bookings = bp.adminBookings;

    if (bookings.isEmpty) {
      return const EmptyStateWidget(icon: Icons.event_busy_rounded, title: 'Tidak Ada Booking', subtitle: 'Belum ada pengajuan booking baru');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) {
        final b = bookings[i];
        return FadeInUp(
          delay: Duration(milliseconds: i * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(b.userName, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800))),
                StatusBadge(status: b.status),
              ]),
              const SizedBox(height: 8),
              Text('Poli: ${b.poliName} - dr. ${b.doctorName}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
              Text('Jadwal: ${DateFormatter.formatDate(b.bookingDate)} (${b.timeSlot})', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              
              if (b.isPending) ...[
                const Divider(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => bp.cancelBooking(b.id),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => bp.confirmBooking(b.id),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      child: const Text('Setujui'),
                    ),
                  ),
                ]),
              ],
              if (b.isConfirmed) ...[
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => bp.completeBooking(b.id),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Tandai Selesai'),
                  ),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }
}

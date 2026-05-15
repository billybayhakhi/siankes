import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import '../../widgets/shared_widgets.dart';

class QueueTab extends StatelessWidget {
  const QueueTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final queue = Provider.of<QueueProvider>(context);
    final myActive = queue.myActiveQueues;
    final userId = auth.user?.uid ?? '';

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
                  Text('Status Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Pantau antrian Anda secara realtime', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70)),
                ]),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('LIVE', style: GoogleFonts.plusJakartaSans(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800)),
                ]),
              ]),
              const SizedBox(height: 16),
              const TabBar(
                indicatorColor: Colors.white, indicatorWeight: 3,
                labelColor: Colors.white, unselectedLabelColor: Colors.white54,
                tabs: [Tab(text: 'ANTRIAN SAYA'), Tab(text: 'SEMUA ANTRIAN')],
              ),
            ]),
          ),
          Expanded(
            child: TabBarView(children: [
              // My Queues
              myActive.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Belum Ada Antrian',
                      subtitle: 'Ambil nomor antrian untuk mulai',
                      buttonLabel: 'Ambil Antrian',
                      onButtonPressed: () => Navigator.pushNamed(context, '/take-queue'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: myActive.length,
                      itemBuilder: (ctx, i) {
                        final q = myActive[i];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/queue-status', arguments: q),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: q.isCalled ? AppColors.successGradient : AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [BoxShadow(color: (q.isCalled ? AppColors.success : AppColors.primary).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))],
                            ),
                            child: Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Text(q.poliName, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
                                StatusBadge(status: q.status),
                              ]),
                              const SizedBox(height: 16),
                              Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: 2)),
                              const SizedBox(height: 12),
                              Text(q.isCalled ? '🔔 SILAKAN MASUK KE RUANGAN' : '⏳ MOHON TUNGGU GILIRAN ANDA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5)),
                              if (q.isCalled) const Padding(padding: EdgeInsets.only(top: 12), child: Icon(Icons.campaign_rounded, color: Colors.white, size: 36)),
                              const SizedBox(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Icon(Icons.touch_app_rounded, color: Colors.white54, size: 16),
                                const SizedBox(width: 6),
                                Text('Tap untuk detail', style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 11)),
                              ]),
                              const SizedBox(height: 8),
                              if (q.isWaiting) OutlinedButton(
                                onPressed: () => queue.cancelQueue(q.id),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                                child: Text('Batalkan Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                              ),
                            ]),
                          ),
                        );
                      },
                    ),
              // All Queues
              queue.polyclinics.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: queue.polyclinics.length,
                      itemBuilder: (ctx, i) {
                        final poli = queue.polyclinics[i];
                        final poliQueues = queue.getActiveQueuesByPoli(poli.id);
                        if (poliQueues.isEmpty) return const SizedBox.shrink();
                        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(poli.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Text(poli.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
                            const Spacer(),
                            Text('${poliQueues.length} antrian', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textTertiary)),
                          ]),
                          const SizedBox(height: 10),
                          ...poliQueues.map((q) {
                            final isMe = q.userId == userId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: q.isCalled ? Border.all(color: AppColors.success, width: 2) : (isMe ? Border.all(color: AppColors.primary, width: 1.5) : null),
                                boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                              ),
                              child: Row(children: [
                                Container(
                                  width: 46, height: 46,
                                  decoration: BoxDecoration(color: q.isCalled ? AppColors.successLight : AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                                  child: Center(child: Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(color: q.isCalled ? AppColors.success : AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13))),
                                ),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(q.userName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                                  Text(q.isCalled ? 'Dipanggil...' : 'Menunggu', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: q.isCalled ? AppColors.success : AppColors.textSecondary)),
                                ])),
                                if (isMe) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: Text('SAYA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                              ]),
                            );
                          }),
                          const SizedBox(height: 16),
                        ]);
                      },
                    ),
            ]),
          ),
        ]),
      ),
    );
  }
}

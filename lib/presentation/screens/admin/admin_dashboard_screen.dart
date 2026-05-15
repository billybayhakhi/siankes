import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
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
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    final poliQueues = qp.getActiveQueuesByPoli(_selectedPoliId);
    final allToday = qp.allQueues.where((q) => q.poliId == _selectedPoliId).toList();
    final waiting = allToday.where((q) => q.isWaiting).length;
    final done = allToday.where((q) => q.isDone).length;
    final currentPoli = qp.polyclinics.isNotEmpty
        ? qp.polyclinics.firstWhere((p) => p.id == _selectedPoliId, orElse: () => qp.polyclinics.first)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(title: 'Panel Admin', actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          onPressed: () => Navigator.pushNamed(context, '/scan-qr'),
          tooltip: 'Scan QR',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onSelected: (v) {
            if (v == 'reset') {
              showDialog(context: context, builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text('Reset Antrian?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                content: Text('Semua antrian ${currentPoli?.name ?? ''} hari ini akan dihapus.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                  TextButton(
                    onPressed: () {
                      qp.resetPoli(_selectedPoliId);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Antrian berhasil direset'), backgroundColor: AppColors.success));
                    },
                    child: Text('Reset', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700)),
                  ),
                ],
              ));
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'reset', child: Row(children: [
              Icon(Icons.restart_alt_rounded, size: 20, color: AppColors.error),
              SizedBox(width: 8),
              Text('Reset Antrian'),
            ])),
          ],
        ),
      ]),
      body: Column(children: [
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
            // Get waiting queues before calling next
            final waitingQueues = qp.allQueues.where((q) => q.poliId == _selectedPoliId && q.isWaiting).toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

            await qp.callNext(_selectedPoliId);

            // Send notification to the called patient
            if (waitingQueues.isNotEmpty) {
              final calledQueue = waitingQueues.first;
              await _notifService.sendQueueCalledNotification(
                userId: calledQueue.userId,
                queueNumber: calledQueue.queueNumber,
                poliName: calledQueue.poliName,
              );
              // Notify the next patient in line
              if (waitingQueues.length > 1) {
                final nextQueue = waitingQueues[1];
                await _notifService.sendQueueAlmostCalledNotification(
                  userId: nextQueue.userId,
                  queueNumber: nextQueue.queueNumber,
                  remaining: 1,
                );
              }
            }

            messenger.showSnackBar(SnackBar(
              content: const Row(children: [
                Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Pasien berikutnya dipanggil'),
              ]),
              backgroundColor: AppColors.success,
            ));
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
        Expanded(
          child: Container(
            width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Daftar Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                  child: Text('${poliQueues.length} aktif', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 14),
              Expanded(
                child: poliQueues.isEmpty
                    ? const EmptyStateWidget(icon: Icons.checklist_rounded, title: 'Tidak Ada Antrian', subtitle: 'Belum ada pasien menunggu')
                    : ListView.builder(
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
                                if (q.isWaiting) IconButton(
                                  icon: const Icon(Icons.skip_next_rounded, color: AppColors.error),
                                  onPressed: () => qp.skipPatient(q.id),
                                  tooltip: 'Lewati',
                                ),
                                StatusBadge(status: q.status),
                              ]),
                            ),
                          );
                        },
                      ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

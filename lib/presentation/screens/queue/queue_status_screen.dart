import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/data/models/queue_model.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import '../../widgets/shared_widgets.dart';

class QueueStatusScreen extends StatelessWidget {
  final QueueModel queue;
  const QueueStatusScreen({super.key, required this.queue});

  @override
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    final liveQueue = qp.allQueues.firstWhere((q) => q.id == queue.id, orElse: () => queue);
    final poliQueues = qp.getActiveQueuesByPoli(liveQueue.poliId);
    final waitingBefore = poliQueues.where((q) => q.isWaiting && q.position < liveQueue.position).length;
    final totalActive = poliQueues.length;
    final progress = totalActive > 0 ? 1.0 - (waitingBefore / totalActive) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildHeader(context, liveQueue, progress),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            _buildInfoRow(waitingBefore, liveQueue),
            const SizedBox(height: 24),
            _buildDetailCard(liveQueue),
            const SizedBox(height: 20),
            if (liveQueue.qrData.isNotEmpty) _buildQrCard(liveQueue),
            if (liveQueue.qrData.isNotEmpty) const SizedBox(height: 20),
            _buildLiveQueue(poliQueues, liveQueue),
            const SizedBox(height: 20),
            if (liveQueue.isWaiting) _buildCancelButton(context, qp, liveQueue),
            const SizedBox(height: 30),
          ]),
        )),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, QueueModel q, double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: BoxDecoration(
        gradient: q.isCalled ? AppColors.successGradient : AppColors.headerGradient,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(bottom: false, child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Text('Status Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          // LIVE badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('LIVE', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ]),
          ),
        ]),
        const SizedBox(height: 20),
        FadeInDown(child: CircularPercentIndicator(
          radius: 72, lineWidth: 8, percent: progress.clamp(0.0, 1.0),
          center: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            Text(q.poliName, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70)),
          ]),
          progressColor: Colors.white, backgroundColor: Colors.white24,
          circularStrokeCap: CircularStrokeCap.round, animation: true, animationDuration: 1200,
        )),
        const SizedBox(height: 16),
        FadeInUp(delay: const Duration(milliseconds: 300), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(q.isCalled ? Icons.campaign_rounded : Icons.hourglass_top_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(q.isCalled ? 'GILIRAN ANDA! SILAKAN MASUK' : 'MOHON TUNGGU GILIRAN ANDA',
              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 0.5)),
          ]),
        )),
      ])),
    );
  }

  Widget _buildInfoRow(int waitingBefore, QueueModel q) {
    return FadeInUp(delay: const Duration(milliseconds: 400), child: Row(children: [
      Expanded(child: _infoTile('Antrian Tersisa', '$waitingBefore', Icons.people_outline_rounded, AppColors.warning)),
      const SizedBox(width: 12),
      Expanded(child: _infoTile('Estimasi Waktu', DateFormatter.estimateWait(waitingBefore), Icons.timer_outlined, AppColors.info)),
    ]));
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildDetailCard(QueueModel q) {
    return FadeInUp(delay: const Duration(milliseconds: 600), child: Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Detail Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const Divider(height: 24),
        _detailRow('Poli', q.poliName),
        _detailRow('Dokter', q.doctorName.isEmpty ? '-' : q.doctorName),
        _detailRow('Keluhan', q.complaint),
        _detailRow('Waktu Daftar', DateFormatter.formatDateTime(q.createdAt)),
        if (q.calledAt != null) _detailRow('Waktu Dipanggil', DateFormatter.formatDateTime(q.calledAt!)),
        if (q.completedAt != null) _detailRow('Waktu Selesai', DateFormatter.formatDateTime(q.completedAt!)),
      ]),
    ));
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 120, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary))),
      Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600))),
    ]));
  }

  Widget _buildQrCard(QueueModel q) {
    return FadeInUp(delay: const Duration(milliseconds: 700), child: Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        Text('QR Code Check-in', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Tunjukkan QR code ini saat check-in', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 2)),
          child: QrImageView(data: q.qrData, size: 180, version: QrVersions.auto),
        ),
      ]),
    ));
  }

  Widget _buildLiveQueue(List<QueueModel> poliQueues, QueueModel liveQueue) {
    return FadeInUp(delay: const Duration(milliseconds: 800), child: Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('Live • Antrian ${liveQueue.poliName}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...poliQueues.take(10).map((q) {
          final isMe = q.id == liveQueue.id;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? (q.isCalled ? AppColors.successLight : AppColors.primarySurface) : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: isMe ? Border.all(color: q.isCalled ? AppColors.success : AppColors.primary, width: 1.5) : null,
            ),
            child: Row(children: [
              Text(q.queueNumber, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14, color: q.isCalled ? AppColors.success : AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: Text(q.userName, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: isMe ? FontWeight.w700 : FontWeight.w500))),
              if (isMe) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                child: Text('ANDA', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: q.status),
            ]),
          );
        }),
      ]),
    ));
  }

  Widget _buildCancelButton(BuildContext context, QueueProvider qp, QueueModel q) {
    return FadeInUp(delay: const Duration(milliseconds: 900), child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showDialog(context: context, builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Batalkan Antrian?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          content: Text('Anda yakin ingin membatalkan antrian ${q.queueNumber}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
            TextButton(onPressed: () { qp.cancelQueue(q.id); Navigator.pop(ctx); Navigator.pop(context); },
              child: Text('Ya, Batalkan', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700))),
          ],
        )),
        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
        label: Text('Batalkan Antrian', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      ),
    ));
  }
}

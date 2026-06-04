import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/data/models/queue_model.dart';
import 'package:siankes/data/models/booking_model.dart';
import '../../widgets/shared_widgets.dart';

class HistoryDetailScreen extends StatelessWidget {
  final QueueModel? queueHistory;
  final BookingModel? bookingHistory;

  const HistoryDetailScreen({super.key, this.queueHistory, this.bookingHistory});

  @override
  Widget build(BuildContext context) {
    final isQueue = queueHistory != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildHeader(context, isQueue),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: isQueue ? _buildQueueDetail() : _buildBookingDetail(),
        )),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, bool isQueue) {
    final statusColor = isQueue ? _queueStatusColor(queueHistory!.status) : _bookingStatusColor(bookingHistory!.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [statusColor, statusColor.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(child: Column(children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
          Expanded(child: Text(isQueue ? 'Detail Antrian' : 'Detail Booking', textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(width: 48),
        ]),
        const SizedBox(height: 16),
        FadeInDown(child: Container(
          width: 72, height: 72,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
          child: Icon(isQueue ? Icons.confirmation_number_rounded : Icons.calendar_month_rounded, color: Colors.white, size: 36),
        )),
        const SizedBox(height: 12),
        FadeInDown(delay: const Duration(milliseconds: 200), child: Text(
          isQueue ? queueHistory!.queueNumber : bookingHistory!.doctorName,
          style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
        )),
        const SizedBox(height: 6),
        FadeInDown(delay: const Duration(milliseconds: 300), child: StatusBadge(
          status: isQueue ? queueHistory!.status : bookingHistory!.status,
        )),
      ])),
    );
  }

  Widget _buildQueueDetail() {
    final q = queueHistory!;
    return Column(children: [
      FadeInUp(delay: const Duration(milliseconds: 400), child: _card([
        _row('Nomor Antrian', q.queueNumber),
        _row('Poli', q.poliName),
        _row('Dokter', q.doctorName.isEmpty ? '-' : q.doctorName),
        _row('Keluhan', q.complaint),
        _row('Posisi', '#${q.position}'),
      ])),
      const SizedBox(height: 16),
      FadeInUp(delay: const Duration(milliseconds: 500), child: _card([
        _sectionTitle('Timeline'),
        _timelineItem('Daftar Antrian', DateFormatter.formatDateTime(q.createdAt), true),
        if (q.calledAt != null) _timelineItem('Dipanggil', DateFormatter.formatDateTime(q.calledAt!), true),
        if (q.completedAt != null) _timelineItem('Selesai', DateFormatter.formatDateTime(q.completedAt!), true),
      ])),
      if (q.qrData.isNotEmpty) ...[
        const SizedBox(height: 16),
        FadeInUp(delay: const Duration(milliseconds: 600), child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(children: [
            // Premium header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(children: [
                const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Digital ID Kunjungan', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                  Text('Scan untuk Farmasi / Kasir', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white70)),
                ]),
              ]),
            ),
            // QR Code
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: [BoxShadow(color: AppColors.primarySurface, blurRadius: 0, spreadRadius: 6)],
                  ),
                  child: QrImageView(data: q.qrData, size: 170, version: QrVersions.auto),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Tunjukkan barcode ini ke petugas Farmasi atau Kasir setelah keluar dari ruang dokter.', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.info, height: 1.4))),
                  ]),
                ),
              ]),
            ),
          ]),
        )),
      ],
      const SizedBox(height: 20),
    ]);
  }

  Widget _buildBookingDetail() {
    final b = bookingHistory!;
    return Column(children: [
      FadeInUp(delay: const Duration(milliseconds: 400), child: _card([
        _row('Dokter', b.doctorName),
        _row('Poli', b.poliName),
        _row('Tanggal', DateFormatter.formatDate(b.bookingDate)),
        _row('Jam', b.timeSlot),
        _row('Keluhan', b.complaint.isEmpty ? '-' : b.complaint),
      ])),
      const SizedBox(height: 16),
      FadeInUp(delay: const Duration(milliseconds: 500), child: _card([
        _sectionTitle('Timeline'),
        _timelineItem('Booking Dibuat', DateFormatter.formatDateTime(b.createdAt), true),
      ])),
      const SizedBox(height: 20),
    ]);
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  Widget _sectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(title,
      style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)));
  }

  Widget _timelineItem(String title, String time, bool completed) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(
        color: completed ? AppColors.success : AppColors.border, shape: BoxShape.circle,
        border: Border.all(color: completed ? AppColors.success : AppColors.border, width: 2),
      )),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
        Text(time, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
      ])),
    ]));
  }

  Color _queueStatusColor(String s) {
    switch (s) {
      case 'done': return AppColors.success;
      case 'called': return AppColors.success;
      case 'skipped': return AppColors.error;
      case 'cancelled': return AppColors.error;
      default: return AppColors.primary;
    }
  }

  Color _bookingStatusColor(String s) {
    switch (s) {
      case 'confirmed': return AppColors.success;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.info;
    }
  }
}

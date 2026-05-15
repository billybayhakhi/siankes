import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import '../../widgets/shared_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _poliId;
  String? _doctorId;
  DateTime? _date;
  String? _timeSlot;
  final _complaintCtrl = TextEditingController();

  final _slots = ['08:00','08:30','09:00','09:30','10:00','10:30','11:00','11:30','13:00','13:30','14:00'];

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (_poliId == null || _doctorId == null || _date == null || _timeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data'), backgroundColor: AppColors.error));
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bp = Provider.of<BookingProvider>(context, listen: false);
    final qp = Provider.of<QueueProvider>(context, listen: false);
    final poli = qp.polyclinics.firstWhere((p) => p.id == _poliId);
    final doc = bp.doctors.firstWhere((d) => d.id == _doctorId);

    try {
      await bp.createBooking(
        userId: auth.user!.uid, userName: auth.user!.name,
        doctorId: doc.id, doctorName: doc.name,
        poliId: poli.id, poliName: poli.name,
        bookingDate: _date!, timeSlot: _timeSlot!,
        complaint: _complaintCtrl.text.trim(),
      );
      if (!mounted) return;
      _showSuccess(doc.name, _date!, _timeSlot!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal booking: $e'), backgroundColor: AppColors.error));
    }
  }

  void _showSuccess(String doctor, DateTime date, String time) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40)),
        const SizedBox(height: 16),
        Text('Booking Berhasil!', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(doctor, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text('${DateFormat('dd MMMM yyyy').format(date)} • $time', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
          ]),
        ),
        const SizedBox(height: 20),
        PrimaryButton(label: 'Selesai', onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }),
      ])),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    final bp = Provider.of<BookingProvider>(context);
    final doctors = _poliId != null ? bp.getDoctorsByPoli(_poliId!) : <dynamic>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Booking Jadwal'),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pilih Poli', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: qp.polyclinics.map((p) {
          final sel = _poliId == p.id;
          return GestureDetector(
            onTap: () => setState(() { _poliId = p.id; _doctorId = null; }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(p.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(p.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textPrimary)),
              ]),
            ),
          );
        }).toList()),

        if (doctors.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Pilih Dokter', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...doctors.map((d) {
            final sel = _doctorId == d.id;
            return GestureDetector(
              onTap: () => setState(() => _doctorId = d.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: sel ? AppColors.primarySurface : Colors.white, borderRadius: BorderRadius.circular(16), border: sel ? Border.all(color: AppColors.primary, width: 2) : null, boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)]),
                child: Row(children: [
                  CircleAvatar(radius: 22, backgroundColor: AppColors.primarySurface, child: const Icon(Icons.person, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                    Row(children: [const Icon(Icons.star_rounded, size: 14, color: Colors.amber), const SizedBox(width: 4), Text('${d.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)), Text(' • ${d.experience}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary))]),
                  ])),
                  if (sel) const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                ]),
              ),
            );
          }),
        ],

        const SizedBox(height: 24),
        Text('Pilih Tanggal', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 6)]),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Text(_date != null ? DateFormat('dd MMMM yyyy').format(_date!) : 'Pilih tanggal...', style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _date != null ? AppColors.textPrimary : AppColors.textTertiary)),
            ]),
          ),
        ),

        const SizedBox(height: 24),
        Text('Pilih Jam', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: _slots.map((s) {
          final sel = _timeSlot == s;
          return GestureDetector(
            onTap: () => setState(() => _timeSlot = s),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4)]),
              child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textPrimary)),
            ),
          );
        }).toList()),

        const SizedBox(height: 24),
        AppTextField(controller: _complaintCtrl, label: 'Keluhan (opsional)', hint: 'Jelaskan keluhan Anda...', prefixIcon: Icons.edit_note_rounded, maxLines: 2),
        const SizedBox(height: 32),
        PrimaryButton(label: 'KONFIRMASI BOOKING', onPressed: _submit, isLoading: bp.isLoading, icon: Icons.event_available_rounded),
        const SizedBox(height: 30),
      ])),
    );
  }
}

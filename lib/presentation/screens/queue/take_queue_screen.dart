import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/validators.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import '../../widgets/shared_widgets.dart';

class TakeQueueScreen extends StatefulWidget {
  const TakeQueueScreen({super.key});
  @override
  State<TakeQueueScreen> createState() => _TakeQueueScreenState();
}

class _TakeQueueScreenState extends State<TakeQueueScreen> {
  String? _selectedPoliId;
  String? _selectedDoctorId;
  final _complaintCtrl = TextEditingController();

  @override
  void dispose() { _complaintCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_selectedPoliId == null) { _snack('Pilih poli terlebih dahulu'); return; }
    if (_complaintCtrl.text.trim().length < 5) { _snack('Jelaskan keluhan Anda'); return; }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final queue = Provider.of<QueueProvider>(context, listen: false);
    final booking = Provider.of<BookingProvider>(context, listen: false);
    final poli = queue.polyclinics.firstWhere((p) => p.id == _selectedPoliId);
    final doctors = booking.getDoctorsByPoli(_selectedPoliId!);
    final doctor = _selectedDoctorId != null ? doctors.firstWhere((d) => d.id == _selectedDoctorId) : (doctors.isNotEmpty ? doctors.first : null);

    try {
      final result = await queue.takeQueue(
        poliId: poli.id, poliName: poli.name,
        doctorId: doctor?.id ?? '', doctorName: doctor?.name ?? '-',
        userId: auth.user!.uid, userName: auth.user!.name,
        complaint: _complaintCtrl.text.trim(),
      );
      if (!mounted) return;
      _showResult(result.queueNumber, poli.name, doctor?.name ?? '-', result.qrData, result);
    } catch (e) {
      if (!mounted) return;
      _snack('Gagal mengambil antrian: ${e.toString()}');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  void _showResult(String number, String poli, String doctor, String qrData, dynamic result) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 64, height: 64, decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40)),
          const SizedBox(height: 16),
          Text('Antrian Berhasil!', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text(number, style: GoogleFonts.plusJakartaSans(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary)),
              Text(poli, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600)),
              Text(doctor, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: QrImageView(data: qrData, size: 120, version: QrVersions.auto),
          ),
          const SizedBox(height: 8),
          Text('Tunjukkan QR saat check-in', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Pantau Status Antrian',
            icon: Icons.track_changes_rounded,
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pushNamed(context, '/queue-status', arguments: result);
            },
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text('Kembali ke Beranda', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 13)),
          ),
        ]),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final queue = Provider.of<QueueProvider>(context);
    final booking = Provider.of<BookingProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final doctors = _selectedPoliId != null ? booking.getDoctorsByPoli(_selectedPoliId!) : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Ambil Antrian'),
      body: SingleChildScrollView(
        child: Column(children: [
          // User Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(gradient: AppColors.headerGradient, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(auth.user?.name ?? '-', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('Pastikan data Anda sudah benar', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                ]),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Pilih Poli', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
                itemCount: queue.polyclinics.length,
                itemBuilder: (ctx, i) {
                  final poli = queue.polyclinics[i];
                  final sel = _selectedPoliId == poli.id;
                  return GestureDetector(
                    onTap: () => setState(() { _selectedPoliId = poli.id; _selectedDoctorId = null; }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: sel ? Color(poli.color) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: sel ? Color(poli.color).withOpacity(0.3) : AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(poli.icon, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 10),
                        Text(poli.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? Colors.white : AppColors.textPrimary)),
                        Text('Antrian: ${poli.totalQueue}', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: sel ? Colors.white70 : AppColors.textTertiary)),
                      ]),
                    ),
                  );
                },
              ),
              // Doctor Selection
              if (doctors.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Pilih Dokter', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...doctors.map((doc) {
                  final sel = _selectedDoctorId == doc.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDoctorId = doc.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primarySurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: sel ? Border.all(color: AppColors.primary, width: 2) : null,
                        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)],
                      ),
                      child: Row(children: [
                        CircleAvatar(radius: 22, backgroundColor: AppColors.primarySurface, child: Icon(Icons.person_rounded, color: AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(doc.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(doc.schedule, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                        ])),
                        if (sel) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                      ]),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
              AppTextField(controller: _complaintCtrl, label: 'Keluhan', hint: 'Jelaskan gejala yang Anda rasakan...', prefixIcon: Icons.edit_note_rounded, maxLines: 3, validator: Validators.complaint),
              const SizedBox(height: 32),
              PrimaryButton(label: 'AMBIL ANTRIAN', onPressed: _submit, isLoading: queue.isLoading, icon: Icons.confirmation_number_rounded),
              const SizedBox(height: 30),
            ]),
          ),
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/data/models/doctor_model.dart';
import '../../widgets/shared_widgets.dart';

class DoctorDetailScreen extends StatelessWidget {
  final DoctorModel doctor;
  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
          ),
          child: SafeArea(child: Column(children: [
            Row(children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
              Expanded(child: Text('Detail Dokter', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white))),
              const SizedBox(width: 48),
            ]),
            const SizedBox(height: 20),
            FadeInDown(child: DoctorAvatar(
              name: doctor.name,
              photoUrl: doctor.photoUrl,
              radius: 48,
            )),
            const SizedBox(height: 14),
            FadeInDown(delay: const Duration(milliseconds: 150), child: Text(doctor.name, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center)),
            const SizedBox(height: 4),
            FadeInDown(delay: const Duration(milliseconds: 200), child: Text(doctor.specialization, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70))),
            const SizedBox(height: 12),
            FadeInUp(delay: const Duration(milliseconds: 250), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _headerStat(Icons.star_rounded, '${doctor.rating}', Colors.amber, 'Rating'),
              const SizedBox(width: 16),
              Container(width: 1, height: 36, color: Colors.white24),
              const SizedBox(width: 16),
              _headerStat(Icons.work_history_rounded, doctor.experience, Colors.white, 'Pengalaman'),
              const SizedBox(width: 16),
              Container(width: 1, height: 36, color: Colors.white24),
              const SizedBox(width: 16),
              _headerStat(doctor.isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  doctor.isAvailable ? 'Tersedia' : 'Libur', doctor.isAvailable ? Colors.greenAccent : Colors.redAccent, 'Status'),
            ])),
          ])),
        ),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            // Schedule Card
            FadeInUp(delay: const Duration(milliseconds: 400), child: _card(
              icon: Icons.schedule_rounded,
              title: 'Jadwal Praktik',
              child: Text(doctor.schedule, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
            )),
            const SizedBox(height: 16),
            // Slots Card
            FadeInUp(delay: const Duration(milliseconds: 500), child: _card(
              icon: Icons.access_time_rounded,
              title: 'Slot Waktu Tersedia',
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: doctor.availableSlots.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
                  child: Text(s, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                )).toList(),
              ),
            )),
            const SizedBox(height: 16),
            // Info Card
            FadeInUp(delay: const Duration(milliseconds: 600), child: _card(
              icon: Icons.local_hospital_rounded,
              title: 'Informasi Dokter',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _infoRow('Spesialisasi', doctor.specialization),
                _infoRow('Pengalaman', doctor.experience),
                _infoRow('Status', doctor.isAvailable ? 'Tersedia' : 'Tidak Tersedia'),
                _infoRow('Poli', doctor.poliId.toUpperCase()),
              ]),
            )),
            const SizedBox(height: 24),
            // Action Buttons Row
            FadeInUp(delay: const Duration(milliseconds: 700), child: Column(children: [
              // Take Queue Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: doctor.isAvailable ? AppColors.cardGradient : null,
                    color: doctor.isAvailable ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: doctor.isAvailable ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))] : null,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: doctor.isAvailable ? () => Navigator.pushNamed(context, '/take-queue') : null,
                    icon: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 20),
                    label: Text('Ambil Antrian Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Booking Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: doctor.isAvailable ? AppColors.primaryGradient : null,
                    color: doctor.isAvailable ? null : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: doctor.isAvailable ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: doctor.isAvailable ? () => Navigator.pushNamed(context, '/booking') : null,
                    icon: const Icon(Icons.event_available_rounded, color: Colors.white, size: 20),
                    label: Text('Booking Jadwal', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
              ),
            ])),
            const SizedBox(height: 30),
          ]),
        )),
      ]),
    );
  }

  Widget _headerStat(IconData icon, String label, Color color, String subLabel) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
      Text(subLabel, style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 10)),
    ]);
  }

  Widget _card({required IconData icon, required String title, required Widget child}) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const Divider(height: 20),
        child,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 110, child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary))),
      Expanded(child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600))),
    ]));
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import '../../widgets/shared_widgets.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});
  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  String _searchQuery = '';
  String? _filterPoliId;

  @override
  Widget build(BuildContext context) {
    final bp = Provider.of<BookingProvider>(context);
    final qp = Provider.of<QueueProvider>(context);
    var doctors = bp.doctors;
    if (_filterPoliId != null) doctors = doctors.where((d) => d.poliId == _filterPoliId).toList();
    if (_searchQuery.isNotEmpty) doctors = doctors.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()) || d.specialization.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Daftar Dokter'),
      body: Column(children: [
        // Search + Filter header
        Container(
          color: AppColors.primary.withOpacity(0.03),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari dokter atau spesialisasi...',
                  hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textTertiary),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                ),
              ),
            ),
            // Poli Filter
            SizedBox(
              height: 46,
              child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), children: [
                _filterChip(null, 'Semua'),
                ...qp.polyclinics.map((p) => _filterChip(p.id, p.name)),
              ]),
            ),
            // Result count
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Text('${doctors.length} dokter ditemukan', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Tersedia sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600)),
              ]),
            ),
          ]),
        ),
        // List
        Expanded(
          child: doctors.isEmpty
              ? const EmptyStateWidget(icon: Icons.person_search_rounded, title: 'Dokter Tidak Ditemukan', subtitle: 'Coba kata kunci lain')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), itemCount: doctors.length,
                  itemBuilder: (ctx, i) {
                    final d = doctors[i];
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/doctor-detail', arguments: d),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(children: [
                          DoctorAvatar(name: d.name, photoUrl: d.photoUrl, radius: 30),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(d.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(d.specialization, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                              Text(' ${d.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              Text(' • ${d.experience}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                            ]),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.schedule_rounded, size: 13, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Expanded(child: Text(d.schedule, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textTertiary))),
                            ]),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: d.isAvailable ? AppColors.successLight : AppColors.errorLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(d.isAvailable ? 'Tersedia' : 'Penuh', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: d.isAvailable ? AppColors.success : AppColors.error)),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                          ]),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _filterChip(String? poliId, String label) {
    final sel = _filterPoliId == poliId;
    return GestureDetector(
      onTap: () => setState(() => _filterPoliId = poliId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: sel ? AppColors.primary.withOpacity(0.3) : AppColors.shadowLight, blurRadius: sel ? 8 : 4, offset: const Offset(0, 2))],
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

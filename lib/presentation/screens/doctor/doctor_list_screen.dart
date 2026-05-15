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
        // Search
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(hintText: 'Cari dokter...', prefixIcon: const Icon(Icons.search_rounded, size: 20), filled: true, fillColor: Colors.white),
        )),
        // Poli Filter
        SizedBox(
          height: 46,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            _filterChip(null, 'Semua'),
            ...qp.polyclinics.map((p) => _filterChip(p.id, p.name)),
          ]),
        ),
        // List
        Expanded(
          child: doctors.isEmpty
              ? const EmptyStateWidget(icon: Icons.person_search_rounded, title: 'Dokter Tidak Ditemukan', subtitle: 'Coba kata kunci lain')
              : ListView.builder(
                  padding: const EdgeInsets.all(20), itemCount: doctors.length,
                  itemBuilder: (ctx, i) {
                    final d = doctors[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8)]),
                      child: Row(children: [
                        CircleAvatar(radius: 28, backgroundColor: AppColors.primarySurface, child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text(d.specialization, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Row(children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                            Text(' ${d.rating}', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text(' • ${d.experience}', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.schedule_rounded, size: 13, color: AppColors.textTertiary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(d.schedule, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textTertiary))),
                          ]),
                        ])),
                        Column(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: d.isAvailable ? AppColors.successLight : AppColors.errorLight, borderRadius: BorderRadius.circular(8)),
                            child: Text(d.isAvailable ? 'Tersedia' : 'Tidak Tersedia', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: d.isAvailable ? AppColors.success : AppColors.error)),
                          ),
                        ]),
                      ]),
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
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: sel ? AppColors.primary : Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import '../../widgets/shared_widgets.dart';

class PolyclinicListScreen extends StatelessWidget {
  const PolyclinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final qp = Provider.of<QueueProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Daftar Poli'),
      body: qp.polyclinics.isEmpty
          ? const EmptyStateWidget(icon: Icons.local_hospital_outlined, title: 'Tidak Ada Poli', subtitle: 'Data poli belum tersedia')
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: qp.polyclinics.length,
              itemBuilder: (ctx, i) {
                final poli = qp.polyclinics[i];
                final waiting = qp.getWaitingCount(poli.id);
                return FadeInUp(
                  delay: Duration(milliseconds: i * 100),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Color(poli.color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Text(poli.icon, style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(poli.name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(poli.description, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Row(children: [
                          _chip('Antrian: ${poli.totalQueue}', AppColors.primary),
                          const SizedBox(width: 8),
                          _chip('Menunggu: $waiting', AppColors.warning),
                        ]),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('Melayani', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textTertiary)),
                        const SizedBox(height: 2),
                        Text('#${poli.currentServing}', style: GoogleFonts.plusJakartaSans(
                          fontSize: 22, fontWeight: FontWeight.w900, color: Color(poli.color),
                        )),
                      ]),
                    ]),
                  ),
                );
              },
            ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

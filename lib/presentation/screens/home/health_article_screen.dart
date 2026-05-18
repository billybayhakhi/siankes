import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';

class HealthArticleArgs {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  HealthArticleArgs({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class HealthArticleScreen extends StatelessWidget {
  final HealthArticleArgs args;

  const HealthArticleScreen({super.key, required this.args});

  String _getArticleContent(String title) {
    if (title.toLowerCase().contains('cuci tangan')) {
      return 'Mencuci tangan dengan sabun adalah salah satu tindakan sanitasi dengan membersihkan tangan dan jari jemari menggunakan air dan sabun oleh manusia untuk menjadi bersih dan memutuskan mata rantai kuman.\n\n'
             'Penyakit-penyakit yang dapat dicegah dengan mencuci tangan pakai sabun antara lain diare, infeksi saluran pernapasan akut, cacingan, hingga penyakit kulit. Biasakan mencuci tangan terutama sebelum makan, setelah dari toilet, dan setelah beraktivitas di luar rumah.';
    } else if (title.toLowerCase().contains('vaksinasi')) {
      return 'Vaksinasi adalah pemberian vaksin (antigen) yang dapat merangsang pembentukan imunitas (antibodi) sistem imun di dalam tubuh. Vaksinasi sebagai upaya pencegahan primer yang sangat andal mencegah penyakit yang dapat dicegah dengan imunisasi (PD3I).\n\n'
             'Klinik kami menyediakan berbagai jenis vaksinasi baik untuk anak-anak (seperti BCG, DPT, Polio, Campak) maupun dewasa (seperti Influenza, Hepatitis B, Tifoid). Pastikan Anda dan keluarga mendapatkan perlindungan optimal sesuai jadwal yang dianjurkan.';
    } else {
      return 'Pola hidup sehat adalah gaya hidup yang memerhatikan segala aspek kondisi kesehatan. Kesehatan adalah hal penting yang mendukung semua aktivitas Anda berjalan lancar.\n\n'
             'Beberapa langkah penting untuk menjaga pola hidup sehat antara lain:\n'
             '1. Mengonsumsi makanan bergizi seimbang.\n'
             '2. Rutin berolahraga minimal 30 menit sehari.\n'
             '3. Istirahat yang cukup (7-8 jam per malam).\n'
             '4. Mengelola stres dengan baik.\n'
             '5. Menghindari kebiasaan buruk seperti merokok dan konsumsi alkohol berlebihan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _getArticleContent(args.title);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: args.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [args.color, args.color.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: FadeInDown(
                    child: Icon(args.icon, size: 100, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    child: Text(
                      args.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: args.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: args.color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: args.color),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              args.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      content,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

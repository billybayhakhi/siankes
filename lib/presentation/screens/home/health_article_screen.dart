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
      return 'Menjaga kebersihan tangan adalah garis pertahanan pertama melawan berbagai penyakit infeksi. Organisasi Kesehatan Dunia (WHO) sangat menekankan pentingnya mencuci tangan pakai sabun (CTPS) karena terbukti efektif mencegah penularan penyakit.\n\n'
             'Pentingnya Mencuci Tangan:\n'
             'Tangan merupakan perantara utama perpindahan kuman, bakteri, dan virus. Sehari-hari, kita menyentuh banyak permukaan yang mungkin terkontaminasi, seperti gagang pintu, uang, hingga fasilitas umum. Tanpa disadari, kita sering menyentuh area wajah (mata, hidung, mulut) yang menjadi pintu masuk patogen ke dalam tubuh.\n\n'
             'Kapan Anda Harus Mencuci Tangan?\n'
             '• Sebelum, selama, dan setelah menyiapkan makanan\n'
             '• Sebelum makan atau menyuapi anak\n'
             '• Setelah menggunakan toilet\n'
             '• Setelah bersin, batuk, atau membuang ingus\n'
             '• Setelah menyentuh hewan atau membersihkan kotoran hewan\n'
             '• Setelah merawat orang sakit atau membalut luka\n\n'
             'Langkah Mencuci Tangan yang Benar (WHO):\n'
             '1. Basahi tangan dengan air bersih mengalir.\n'
             '2. Tuangkan sabun secukupnya.\n'
             '3. Gosok telapak tangan yang satu ke telapak tangan lainnya.\n'
             '4. Gosok punggung tangan dan sela jari bergantian.\n'
             '5. Gosok telapak tangan dan sela jari dengan posisi saling bertautan.\n'
             '6. Gosok punggung jari ke telapak tangan dengan posisi jari saling mengunci.\n'
             '7. Genggam dan basuh ibu jari dengan gerakan memutar bergantian.\n'
             '8. Gosok bagian ujung jari ke telapak tangan agar bagian kuku terkena sabun.\n'
             '9. Bilas dengan air mengalir dan keringkan dengan handuk bersih atau tisu.\n\n'
             'Hanya membutuhkan waktu sekitar 20-30 detik untuk mencuci tangan, tetapi manfaatnya bisa menyelamatkan nyawa dan menjaga kesehatan Anda secara signifikan.';
    } else if (title.toLowerCase().contains('vaksinasi')) {
      return 'Vaksinasi adalah salah satu pencapaian medis terbesar dalam sejarah peradaban manusia. Melalui vaksinasi, kita tidak hanya melindungi diri sendiri, tetapi juga komunitas di sekitar kita (herd immunity).\n\n'
             'Bagaimana Vaksin Bekerja?\n'
             'Vaksin mengandung kuman (virus atau bakteri) yang sudah dilemahkan atau dimatikan, atau bagian dari kuman tersebut. Saat dimasukkan ke dalam tubuh, sistem imun akan mengenalinya sebagai ancaman dan memproduksi antibodi. Dengan begitu, tubuh memiliki "memori" untuk melawan penyakit tersebut jika suatu saat terpapar oleh kuman yang sesungguhnya.\n\n'
             'Layanan Vaksinasi di Klinik Kami:\n'
             'Kami menyediakan layanan imunisasi dasar lengkap untuk bayi dan anak, serta vaksinasi dewasa, antara lain:\n'
             '• Imunisasi Dasar Anak: BCG (TBC), DPT (Difteri, Pertusis, Tetanus), Polio, Hepatitis B, dan Campak/MR.\n'
             '• Vaksin Tambahan: PCV (Pneumonia), Rotavirus (Diare rotavirus), Varisela (Cacar air).\n'
             '• Vaksin Dewasa & Calon Pengantin: Vaksin Influenza (dianjurkan diulang setiap tahun), Hepatitis B, HPV (Pencegahan Kanker Serviks), dan Tetanus Toksoid (TT).\n\n'
             'Efek Samping dan Keamanan:\n'
             'Vaksin sangat aman. Efek samping yang muncul biasanya bersifat ringan dan sementara, seperti nyeri di area suntikan, demam ringan, atau rewel pada bayi. Ini adalah respons normal tubuh yang sedang membangun kekebalan.\n\n'
             'Jangan ragu untuk berkonsultasi dengan dokter kami mengenai jadwal imunisasi anak Anda atau vaksinasi tambahan yang Anda perlukan untuk proteksi maksimal.';
    } else if (title.toLowerCase().contains('kesehatan mental')) {
      return 'Kesehatan mental adalah kondisi kesejahteraan di mana seseorang dapat menyadari kemampuan dirinya sendiri, mampu mengatasi tekanan hidup yang normal, bekerja secara produktif, serta mampu memberikan kontribusi bagi komunitasnya.\n\n'
             'Mengapa Kesehatan Mental Penting?\n'
             'Kesehatan mental dan fisik saling berkaitan erat. Masalah kesehatan mental yang tidak ditangani dapat menyebabkan gangguan fisik seperti sakit kepala kronis, gangguan jantung, dan melemahkan sistem imun. Sebaliknya, penyakit fisik yang berat juga bisa memicu depresi dan kecemasan.\n\n'
             'Tanda-tanda Kesehatan Mental yang Perlu Diperhatikan:\n'
             '• Perasaan sedih atau kosong yang berkepanjangan (lebih dari 2 minggu)\n'
             '• Kehilangan minat pada hal-hal yang dulu disukai\n'
             '• Sulit berkonsentrasi atau mengambil keputusan\n'
             '• Perubahan pola tidur atau nafsu makan yang signifikan\n'
             '• Merasa lelah tanpa sebab yang jelas\n'
             '• Menarik diri dari lingkungan sosial\n\n'
             'Tips Menjaga Kesehatan Mental Sehari-hari:\n\n'
             '1. Terhubung dengan Orang Lain\n'
             'Hubungan sosial yang sehat adalah salah satu fondasi kesehatan mental. Luangkan waktu berkualitas bersama keluarga dan sahabat. Jangan ragu untuk berbagi perasaan Anda dengan orang yang Anda percaya.\n\n'
             '2. Tetap Aktif Secara Fisik\n'
             'Olahraga melepaskan endorfin, hormon alami yang mampu meningkatkan suasana hati. Bahkan berjalan kaki 30 menit setiap hari sudah terbukti mengurangi gejala depresi dan kecemasan.\n\n'
             '3. Istirahat yang Berkualitas\n'
             'Kurang tidur dapat memperburuk kondisi mental secara drastis. Ciptakan rutinitas tidur yang teratur. Batasi penggunaan gadget dan media sosial sebelum tidur.\n\n'
             '4. Praktikkan Mindfulness\n'
             'Luangkan 5-10 menit setiap hari untuk bernapas dalam, bermeditasi, atau sekadar duduk diam dan mensyukuri hal-hal kecil. Ini terbukti mengurangi hormon stres (kortisol) dalam tubuh.\n\n'
             '5. Jangan Takut Mencari Bantuan Profesional\n'
             'Mengunjungi psikolog atau psikiater bukan tanda kelemahan, melainkan bentuk keberanian dan kepedulian terhadap diri sendiri. Di SIANKES, Anda dapat berkonsultasi dengan dokter spesialis melalui fitur Booking Jadwal.';
    } else {
      return 'Pola hidup sehat bukan sekadar tentang diet sementara, melainkan komitmen jangka panjang untuk menjaga keseimbangan antara fisik, mental, dan emosional. Gaya hidup modern seringkali membuat kita mengabaikan hal-hal mendasar yang sangat dibutuhkan oleh tubuh.\n\n'
             'Pilar Utama Pola Hidup Sehat:\n\n'
             '1. Gizi Seimbang dan Hidrasi\n'
             'Pastikan piring Anda berwarna-warni dengan sayuran dan buah-buahan. Kurangi konsumsi gula, garam berlebih, dan makanan ultra-proses. Jangan lupa minum air putih minimal 8 gelas atau 2 liter per hari untuk menjaga fungsi sel, organ, dan sirkulasi darah yang optimal.\n\n'
             '2. Aktivitas Fisik Rutin\n'
             'Kementerian Kesehatan menganjurkan aktivitas fisik minimal 30 menit setiap hari, atau 150 menit per minggu. Aktivitas tidak harus di gym; berjalan kaki cepat, bersepeda, berenang, atau bahkan membersihkan rumah secara aktif sudah memberikan dampak positif bagi kesehatan kardiovaskular.\n\n'
             '3. Kualitas Tidur yang Cukup\n'
             'Saat tidur, tubuh melakukan perbaikan sel-sel yang rusak dan menyeimbangkan hormon. Orang dewasa membutuhkan 7-8 jam tidur berkualitas setiap malam. Hindari paparan layar gadget minimal 1 jam sebelum tidur agar produksi melatonin tidak terganggu.\n\n'
             '4. Manajemen Stres\n'
             'Stres kronis dapat memicu berbagai penyakit fisik seperti hipertensi hingga gangguan pencernaan. Luangkan waktu untuk hobi, relaksasi, meditasi, atau sekadar berbincang dengan orang terdekat. Kesehatan mental sama pentingnya dengan kesehatan fisik.\n\n'
             '5. Menghindari Kebiasaan Buruk\n'
             'Berhenti merokok dan batasi konsumsi alkohol. Rokok mengandung ribuan zat kimia berbahaya yang merusak pembuluh darah dan paru-paru.\n\n'
             'Perubahan kecil yang dilakukan secara konsisten setiap hari akan memberikan hasil yang menakjubkan bagi kesehatan Anda di masa depan.';
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

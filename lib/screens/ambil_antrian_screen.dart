import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/database_service.dart';
import '../models/queue_model.dart';

class AmbilAntrianScreen extends StatefulWidget {
  final String userName;
  const AmbilAntrianScreen({super.key, required this.userName});

  @override
  State<AmbilAntrianScreen> createState() => _AmbilAntrianScreenState();
}

class _AmbilAntrianScreenState extends State<AmbilAntrianScreen> {
  String? _selectedPoliId;
  final _keluhanController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _keluhanController.dispose();
    super.dispose();
  }

  Future<void> _ambilAntrian() async {
    if (_selectedPoliId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih poli terlebih dahulu!')),
      );
      return;
    }
    if (_keluhanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi keluhan terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final db = Provider.of<DatabaseService>(context, listen: false);
    final poli = db.daftarPoli.firstWhere((p) => p['id'] == _selectedPoliId);

    final antrian = await db.addQueue(
      poliId: _selectedPoliId!,
      poliNama: poli['nama'] as String,
      namaUser: widget.userName,
      keluhan: _keluhanController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    _showHasilAntrian(antrian, poli);
  }

  void _showHasilAntrian(QueueEntry antrian, Map<String, dynamic> poli) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.accentBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.primary, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'Antrian Berhasil Diambil!',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      antrian.nomor,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(antrian.poliNama,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(poli['dokter'] ?? '-',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keluhan: ${antrian.keluhan}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Ambil Antrian',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info pasien
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.accentBlue,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Text('Pasien SIANKES',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pilih Poli
            const Text(
              'Pilih Poli',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            ...db.daftarPoli.map((poli) {
              final isSelected = _selectedPoliId == poli['id'];
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedPoliId = poli['id']),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentBlue
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(poli['icon'],
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              poli['nama'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black,
                              ),
                            ),
                            Text(poli['dokter'],
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle,
                            color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Keluhan
            const Text(
              'Keluhan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _keluhanController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ceritakan keluhan Anda...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Ambil Antrian
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _ambilAntrian,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Ambil Nomor Antrian',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
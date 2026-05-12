import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/database_service.dart';
import '../models/queue_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedPoliId = 'umum';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final _polis = db.daftarPoli;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Admin Antrian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Antrian?'),
                  content: const Text('Semua antrian di poli ini akan dihapus.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    TextButton(
                      onPressed: () {
                        db.resetQueue(_selectedPoliId);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Poli Selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _polis.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final poli = _polis[index];
                final isSelected = _selectedPoliId == poli['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedPoliId = poli['id']!),
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(poli['icon']!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          poli['nama']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Counters
          StreamBuilder<Map<String, ClinicStatus>>(
            stream: db.statusStream,
            builder: (context, snapshot) {
              final status = snapshot.data?[_selectedPoliId];
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _counterCard(
                      'Sedang Dilayani',
                      status?.currentServing.toString() ?? '0',
                      AppColors.primary,
                    ),
                    const SizedBox(width: 16),
                    _counterCard(
                      'Total Antrian',
                      status?.totalQueue.toString() ?? '0',
                      Colors.orange,
                    ),
                  ],
                ),
              );
            },
          ),

          // Call Next Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () => db.callNext(_selectedPoliId),
                icon: const Icon(Icons.campaign, size: 30),
                label: const Text(
                  'PANGGIL ANTRIAN BERIKUTNYA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List of Patients
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Daftar Pasien Menunggu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<QueueEntry>>(
              stream: db.queueStream,
              builder: (context, snapshot) {
                final allQueues = snapshot.data ?? [];
                final queues = allQueues.where((q) => q.poliId == _selectedPoliId).toList();
                
                if (queues.isEmpty) {
                  return const Center(child: Text('Tidak ada antrian di poli ini'));
                }

                // Sort: Waiting first, then Calling, then Finished
                queues.sort((a, b) {
                  if (a.status == b.status) return a.waktu.compareTo(b.waktu);
                  if (a.status == QueueStatus.calling) return -1;
                  if (b.status == QueueStatus.calling) return 1;
                  if (a.status == QueueStatus.waiting) return -1;
                  if (b.status == QueueStatus.waiting) return 1;
                  return 0;
                });

                return ListView.builder(
                  itemCount: queues.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final queue = queues[index];
                    final isCalling = queue.status == QueueStatus.calling;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: isCalling ? 4 : 1,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCalling ? Colors.green : AppColors.accentBlue,
                          child: Text(
                            queue.nomor,
                            style: TextStyle(
                              color: isCalling ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(queue.namaUser, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(queue.keluhan, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: queue.status == QueueStatus.waiting
                            ? ElevatedButton(
                                onPressed: () => db.approveQueue(queue.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                child: const Text('SETUJUI'),
                              )
                            : _statusBadge(queue.status),
                      ),
                    );
                  },
                );

              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(QueueStatus status) {
    Color color;
    String label;

    switch (status) {
      case QueueStatus.waiting:
        color = Colors.orange;
        label = 'Menunggu';
        break;
      case QueueStatus.approved:
        color = Colors.blue;
        label = 'Disetujui';
        break;
      case QueueStatus.calling:
        color = Colors.green;
        label = 'Dipanggil';
        break;
      case QueueStatus.finished:
        color = Colors.blueGrey;
        label = 'Selesai';
        break;
      case QueueStatus.skipped:
        color = Colors.red;
        label = 'Terlewat';
        break;
    }


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}


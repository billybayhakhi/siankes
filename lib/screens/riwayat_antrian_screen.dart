import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/database_service.dart';
import '../models/queue_model.dart';

class RiwayatAntrianScreen extends StatelessWidget {
  final String userName;
  const RiwayatAntrianScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Riwayat Antrian',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<QueueEntry>>(
        stream: db.queueStream,
        builder: (context, snapshot) {
          final allQueues = snapshot.data ?? [];
          final riwayat = allQueues.where((q) => q.namaUser == userName).toList();
          
          if (riwayat.isEmpty) {

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada riwayat antrian',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // Urutkan dari yang terbaru
          final sortedRiwayat = List<QueueEntry>.from(riwayat)..sort((a, b) => b.waktu.compareTo(a.waktu));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedRiwayat.length,
            itemBuilder: (context, index) {
              final item = sortedRiwayat[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          item.nomor,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.poliNama,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keluhan: ${item.keluhan}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _formatDate(item.waktu),
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(item.status),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(QueueStatus status) {
    Color color;
    String label;
    switch (status) {
      case QueueStatus.waiting:
        color = Colors.orange;
        label = 'Waiting';
        break;
      case QueueStatus.approved:
        color = Colors.blue;
        label = 'Approved';
        break;
      case QueueStatus.calling:
        color = Colors.green;
        label = 'Calling';
        break;
      case QueueStatus.finished:
        color = Colors.grey;
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
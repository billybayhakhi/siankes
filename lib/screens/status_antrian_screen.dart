import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/database_service.dart';
import '../models/queue_model.dart';

class StatusAntrianScreen extends StatelessWidget {
  final String userName;
  const StatusAntrianScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Daftar Antrian',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<QueueEntry>>(
        stream: db.queueStream,
        builder: (context, snapshot) {
          final allQueues = snapshot.data ?? [];
          
          // Filter antrian milik saya yang masih aktif
          final myActiveQueues = allQueues.where((q) => 
            q.namaUser.toLowerCase().trim() == userName.toLowerCase().trim() && 
            q.status != QueueStatus.finished && 
            q.status != QueueStatus.skipped
          ).toList();

          // Filter semua antrian yang sedang menunggu/dipanggil
          final globalQueues = allQueues.where((q) => 
            q.status == QueueStatus.waiting || 
            q.status == QueueStatus.approved || 
            q.status == QueueStatus.calling
          ).toList();

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: AppColors.primary,
                  child: const TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'ANTRIAN SAYA'),
                      Tab(text: 'SEMUA ANTRIAN'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildMyQueues(context, myActiveQueues),
                      _buildGlobalQueues(context, globalQueues, db.daftarPoli),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyQueues(BuildContext context, List<QueueEntry> myQueues) {
    if (myQueues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Anda belum memiliki antrian aktif', style: TextStyle(color: Colors.grey)),
            const Text('Ambil nomor antrian di Beranda', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: myQueues.length,
      itemBuilder: (context, index) {
        final q = myQueues[index];
        final isCalling = q.status == QueueStatus.calling;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCalling 
                  ? [Colors.green, const Color(0xFF2E7D32)] 
                  : [AppColors.primary, const Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(q.poliNama, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  _statusBadge(q.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(q.nomor, style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                isCalling ? 'SILAKAN MASUK SEKARANG' : 'Mohon tunggu giliran Anda',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              ),
              if (isCalling)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Icon(Icons.campaign, color: Colors.white, size: 30),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlobalQueues(BuildContext context, List<QueueEntry> queues, List<Map<String, dynamic>> polis) {
    if (queues.isEmpty) {
      return const Center(child: Text('Tidak ada antrian aktif di klinik saat ini', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: polis.length,
      itemBuilder: (context, index) {
        final poli = polis[index];
        final poliQueues = queues.where((q) => q.poliId == poli['id']).toList();
        
        if (poliQueues.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Text(poli['icon'], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(poli['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ),
            ...poliQueues.map((q) {
              final isMe = q.namaUser.toLowerCase().trim() == userName.toLowerCase().trim();
              final isCalling = q.status == QueueStatus.calling;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isCalling ? 4 : 1,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCalling ? Colors.green : AppColors.accentBlue,
                    child: Text(q.nomor, style: TextStyle(color: isCalling ? Colors.white : AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(q.namaUser, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(isCalling ? 'Sedang Dipanggil...' : 'Menunggu', style: TextStyle(color: isCalling ? Colors.green : Colors.grey, fontSize: 12)),
                  trailing: isMe 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                        child: const Text('SAYA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      )
                    : (isCalling ? const Icon(Icons.volume_up, color: Colors.green, size: 18) : null),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _statusBadge(QueueStatus status) {
    String label = '';
    switch (status) {
      case QueueStatus.waiting: label = 'PENDING'; break;
      case QueueStatus.approved: label = 'TERDAFTAR'; break;
      case QueueStatus.calling: label = 'PANGGIL'; break;
      default: label = 'AKTIF';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}
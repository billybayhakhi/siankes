import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/queue_provider.dart';
import 'package:siankes/presentation/providers/booking_provider.dart';
import 'package:siankes/presentation/providers/notification_provider.dart';
import 'dashboard_tab.dart';
import 'queue_tab.dart';
import 'history_tab.dart';
import 'profile_tab.dart';
import 'package:siankes/core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        Provider.of<QueueProvider>(context, listen: false).initStreams(auth.user!.uid);
        Provider.of<BookingProvider>(context, listen: false).initStreams(auth.user!.uid);
        Provider.of<NotificationProvider>(context, listen: false).initStreams(auth.user!.uid);
        Provider.of<QueueProvider>(context, listen: false).seedData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const DashboardTab(),
      const QueueTab(),
      const HistoryTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
                _buildNavItem(1, Icons.confirmation_number_rounded, Icons.confirmation_number_outlined, 'Antrian'),
                _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'Riwayat'),
                _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primary : AppColors.textTertiary, size: 22),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(label, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}

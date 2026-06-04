import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/date_formatter.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import 'package:siankes/presentation/providers/notification_provider.dart';
import '../../widgets/shared_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notifProv = Provider.of<NotificationProvider>(context);
    final notifications = notifProv.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GradientAppBar(
        title: 'Notifikasi',
        actions: [
          if (notifProv.hasUnread)
            IconButton(
              icon: const Icon(Icons.done_all_rounded),
              tooltip: 'Tandai semua dibaca',
              onPressed: () => notifProv.markAllAsRead(auth.user!.uid),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (v) {
              if (v == 'clear') {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text('Hapus Semua?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
                  content: const Text('Semua notifikasi akan dihapus.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                    TextButton(
                      onPressed: () { notifProv.clearAll(auth.user!.uid); Navigator.pop(ctx); },
                      child: Text('Hapus', style: GoogleFonts.plusJakartaSans(color: AppColors.error, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear', child: Row(children: [
                Icon(Icons.delete_outline_rounded, size: 20),
                SizedBox(width: 8),
                Text('Hapus Semua'),
              ])),
            ],
          ),
        ],
      ),
      body: auth.user == null
          ? const EmptyStateWidget(icon: Icons.notifications_off_outlined, title: 'Belum Login', subtitle: 'Login untuk melihat notifikasi')
          : notifications.isEmpty
              ? const EmptyStateWidget(icon: Icons.notifications_none_rounded, title: 'Belum Ada Notifikasi', subtitle: 'Notifikasi akan muncul di sini')
              : Column(children: [
                  // Summary bar
                  if (notifProv.hasUnread)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.mark_chat_unread_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(
                          'Anda memiliki ${notifProv.unreadCount} notifikasi belum dibaca',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        )),
                        GestureDetector(
                          onTap: () => notifProv.markAllAsRead(auth.user!.uid),
                          child: Text('Baca Semua', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, decorationColor: Colors.white54)),
                        ),
                      ]),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {},
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(20, notifProv.hasUnread ? 12 : 20, 20, 20),
                        itemCount: notifications.length,
                        itemBuilder: (ctx, i) {
                          final notif = notifications[i];
                          return FadeInUp(
                            delay: Duration(milliseconds: i * 50),
                            child: Dismissible(
                              key: Key(notif.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.delete_rounded, color: Colors.white),
                              ),
                              onDismissed: (_) => notifProv.deleteNotification(notif.id),
                              child: GestureDetector(
                                onTap: () {
                                  if (!notif.isRead) notifProv.markAsRead(notif.id);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: notif.isRead ? Colors.white : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 3))],
                                    border: notif.isRead ? Border.all(color: AppColors.border, width: 0.5) : Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5),
                                  ),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: _iconBg(notif.type, notif.isRead),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_icon(notif.type), color: _iconColor(notif.type, notif.isRead), size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Expanded(child: Text(notif.title, style: GoogleFonts.plusJakartaSans(
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 14,
                                        ))),
                                        if (!notif.isRead) Container(
                                          width: 8, height: 8,
                                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                        ),
                                      ]),
                                      const SizedBox(height: 4),
                                      Text(notif.body, style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13, color: AppColors.textSecondary, height: 1.4,
                                      )),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        Icon(Icons.access_time_rounded, size: 12, color: AppColors.textTertiary),
                                        const SizedBox(width: 4),
                                        Text(DateFormatter.timeAgo(notif.createdAt), style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11, color: AppColors.textTertiary,
                                        )),
                                      ]),
                                    ])),
                                  ]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]),
    );
  }

  IconData _icon(String type) {
    switch (type) {
      case 'queue': return Icons.confirmation_number_rounded;
      case 'booking': return Icons.calendar_month_rounded;
      case 'reminder': return Icons.alarm_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String type, bool isRead) {
    if (isRead) return AppColors.textTertiary;
    switch (type) {
      case 'queue': return AppColors.primary;
      case 'booking': return AppColors.success;
      case 'reminder': return AppColors.warning;
      default: return AppColors.info;
    }
  }

  Color _iconBg(String type, bool isRead) {
    if (isRead) return AppColors.surfaceVariant;
    switch (type) {
      case 'queue': return AppColors.primarySurface;
      case 'booking': return AppColors.successLight;
      case 'reminder': return AppColors.warningLight;
      default: return AppColors.infoLight;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siankes/core/theme/app_colors.dart';

// ═══════════════════════════════════════════
// GRADIENT APP BAR
// ═══════════════════════════════════════════
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GradientAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.headerGradient)),
      title: Text(title),
      leading: showBack ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ) : null,
      automaticallyImplyLeading: showBack,
      actions: actions,
      elevation: 0,
    );
  }
}

// ═══════════════════════════════════════════
// PRIMARY GRADIENT BUTTON
// ═══════════════════════════════════════════
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key, required this.label, this.onPressed,
    this.isLoading = false, this.icon, this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null && !isLoading ? AppColors.primaryGradient : null,
          color: onPressed == null || isLoading ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: onPressed != null && !isLoading ? [
            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ] : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: isLoading
              ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                    Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// CUSTOM TEXT FIELD
// ═══════════════════════════════════════════
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key, required this.controller, required this.label,
    this.hint, this.prefixIcon, this.suffix, this.obscure = false,
    this.keyboardType, this.validator, this.maxLines = 1, this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, obscureText: obscure,
          keyboardType: keyboardType, validator: validator,
          maxLines: maxLines, enabled: enabled,
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? label,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.textTertiary) : null,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// STATUS BADGE
// ═══════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'waiting': bg = AppColors.warningLight; fg = AppColors.warning; label = 'Menunggu'; break;
      case 'called': bg = AppColors.successLight; fg = AppColors.success; label = 'Dipanggil'; break;
      case 'done': bg = AppColors.surfaceVariant; fg = AppColors.textSecondary; label = 'Selesai'; break;
      case 'skipped': bg = AppColors.errorLight; fg = AppColors.error; label = 'Terlewat'; break;
      case 'cancelled': bg = AppColors.errorLight; fg = AppColors.error; label = 'Dibatalkan'; break;
      case 'pending': bg = AppColors.warningLight; fg = AppColors.warning; label = 'Pending'; break;
      case 'confirmed': bg = AppColors.infoLight; fg = AppColors.info; label = 'Dikonfirmasi'; break;
      case 'completed': bg = AppColors.successLight; fg = AppColors.success; label = 'Selesai'; break;
      default: bg = AppColors.surfaceVariant; fg = AppColors.textSecondary; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ═══════════════════════════════════════════
// SHIMMER LOADING
// ═══════════════════════════════════════════
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerLoading({super.key, this.width = double.infinity, this.height = 80, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(
        width: width, height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerLoading(height: 80),
      )),
    );
  }
}

// ═══════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key, required this.icon, required this.title,
    required this.subtitle, this.buttonLabel, this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(label: buttonLabel!, onPressed: onButtonPressed, width: 200),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        if (actionText != null)
          TextButton(onPressed: onAction, child: Text(actionText!, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════
class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

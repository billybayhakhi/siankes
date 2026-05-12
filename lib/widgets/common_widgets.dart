import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────
// Custom AppBar untuk SIANKES
// ─────────────────────────────────────────────
class SiankesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SiankesAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Row(
        children: [
          // Hamburger menu icon
          Icon(Icons.menu, color: AppColors.white, size: 24),
          const SizedBox(width: 12),
          // Medical cross icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.local_hospital,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SIANKES',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Custom Text Field
// ─────────────────────────────────────────────
class SiankesTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;

  const SiankesTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText ?? label,
            hintStyle: const TextStyle(color: AppColors.borderGrey, fontSize: 14),
            suffixIcon: suffixIcon,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Primary Button
// ─────────────────────────────────────────────
class SiankesPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SiankesPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ilustrasi Dokter (SVG-style widget)
// ─────────────────────────────────────────────
class DoctorIllustration extends StatelessWidget {
  final double size;

  const DoctorIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Positioned(
            bottom: 0,
            child: Container(
              width: size,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
          ),
          // Doctor icon
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services_rounded,
                size: size * 0.35,
                color: AppColors.primary,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: size * 0.25, color: AppColors.lightBlue),
                  const SizedBox(width: 8),
                  Icon(Icons.person_2, size: size * 0.22, color: const Color(0xFF42A5F5)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/validators.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import '../../widgets/shared_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;
  bool _loading = false;

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.resetPassword(_emailCtrl.text.trim());
    setState(() { _loading = false; _sent = ok; });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim email reset'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Align(alignment: Alignment.topLeft, child: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Navigator.pop(context))),
              const SizedBox(height: 20),
              const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 60),
              const SizedBox(height: 16),
              Text('Reset Password', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Masukkan email untuk menerima link reset', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
                child: _sent
                    ? Column(children: [
                        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 48)),
                        const SizedBox(height: 20),
                        Text('Email Terkirim!', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text('Silakan cek inbox email Anda untuk mereset password', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        PrimaryButton(label: 'Kembali ke Login', onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
                      ])
                    : Form(
                        key: _formKey,
                        child: Column(children: [
                          AppTextField(controller: _emailCtrl, label: 'Email', hint: 'nama@email.com', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email),
                          const SizedBox(height: 24),
                          PrimaryButton(label: 'Kirim Link Reset', onPressed: _reset, isLoading: _loading, icon: Icons.send_rounded),
                        ]),
                      ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

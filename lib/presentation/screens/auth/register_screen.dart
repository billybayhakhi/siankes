import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/validators.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import '../../widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.register(name: _nameCtrl.text, email: _emailCtrl.text, phone: _phoneCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil! Silakan login.'), backgroundColor: AppColors.success));
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(children: [
                const SizedBox(height: 30),
                FadeInDown(child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 52)),
                const SizedBox(height: 12),
                FadeInDown(delay: const Duration(milliseconds: 200), child: Text('Buat Akun Baru', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))),
                const SizedBox(height: 6),
                FadeInDown(delay: const Duration(milliseconds: 300), child: Text('Daftar untuk mengakses layanan kesehatan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70))),
                const SizedBox(height: 30),
                FadeInUp(delay: const Duration(milliseconds: 400), child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))]),
                  child: Form(
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AppTextField(controller: _nameCtrl, label: 'Nama Lengkap', hint: 'Masukkan nama lengkap', prefixIcon: Icons.person_outline, validator: Validators.name),
                      const SizedBox(height: 16),
                      AppTextField(controller: _emailCtrl, label: 'Email', hint: 'nama@email.com', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email),
                      const SizedBox(height: 16),
                      AppTextField(controller: _phoneCtrl, label: 'Nomor HP', hint: '08xxxxxxxxxx', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passCtrl, label: 'Password', hint: 'Minimal 6 karakter', prefixIcon: Icons.lock_outline_rounded, obscure: _obscure, validator: Validators.password,
                        suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textTertiary), onPressed: () => setState(() => _obscure = !_obscure)),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(label: 'DAFTAR SEKARANG', onPressed: _register, isLoading: auth.isLoading, icon: Icons.how_to_reg_rounded),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Sudah punya akun? ', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                        GestureDetector(onTap: () => Navigator.pushReplacementNamed(context, '/login'), child: Text('Masuk', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary))),
                      ]),
                    ]),
                  ),
                )),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

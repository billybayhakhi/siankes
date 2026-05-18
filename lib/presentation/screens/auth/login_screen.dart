import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/validators.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import '../../widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.loginWithGoogle();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (auth.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage), backgroundColor: AppColors.error),
      );
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
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Logo
                  FadeInDown(child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
                    ]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset('assets/images/logo.png', width: 80, height: 80, fit: BoxFit.cover),
                    ),
                  )),
                  const SizedBox(height: 16),
                  FadeInDown(delay: const Duration(milliseconds: 200), child: Text('SIANKES', style: GoogleFonts.plusJakartaSans(fontSize: 30, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2))),
                  const SizedBox(height: 6),
                  FadeInDown(delay: const Duration(milliseconds: 300), child: Text('Sistem Informasi Antrian Klinik Kesehatan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white70))),
                  const SizedBox(height: 40),
                  // Form Card
                  FadeInUp(delay: const Duration(milliseconds: 400), child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat Datang', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          Text('Masuk ke akun Anda untuk melanjutkan', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 28),
                          AppTextField(controller: _emailCtrl, label: 'Email', hint: 'nama@email.com', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email),
                          const SizedBox(height: 18),
                          AppTextField(
                            controller: _passCtrl, label: 'Password', hint: '••••••••', prefixIcon: Icons.lock_outline_rounded, obscure: _obscure,
                            validator: Validators.password,
                            suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.textTertiary), onPressed: () => setState(() => _obscure = !_obscure)),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot-password'), child: Text('Lupa Password?', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(label: 'MASUK', onPressed: _login, isLoading: auth.isLoading, icon: Icons.login_rounded),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: auth.isLoading ? null : _loginWithGoogle,
                              icon: SvgPicture.asset('assets/icons/google.svg', width: 24, height: 24),
                              label: Text('Masuk dengan Google', style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Belum punya akun? ', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                                child: Text('Daftar Sekarang', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

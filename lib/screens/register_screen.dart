import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../utils/auth_service.dart';
import '../widgets/common_widgets.dart';
import '../widgets/dialogs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _nohpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _nohpController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthService>(context, listen: false);
    final error = await auth.register(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      noHp: _nohpController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error != null) {
      showLoginGagalDialog(context, message: error);
    } else {
      showRegistrasiSuksesDialog(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SiankesAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.only(bottom: 20),
              child: const Center(
                child: Text(
                  'Registrasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Center(
                child: _buildDoctorIllustration(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Registrasi',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      controller: _namaController,
                      label: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        if (val.length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'Masukkan email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(val)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _nohpController,
                      label: 'Nomor HP',
                      hintText: 'Masukkan nomor HP',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Nomor HP wajib diisi';
                        }
                        if (val.length < 10) {
                          return 'Nomor HP minimal 10 digit';
                        }
                        if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(val)) {
                          return 'Format nomor HP tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: _passwordController,
                      label: 'Buat Password',
                      obscure: _obscurePassword,
                      onToggle: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (val.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildPasswordField(
                      controller: _konfirmasiController,
                      label: 'Konfirmasi Password',
                      obscure: _obscureKonfirmasi,
                      onToggle: () => setState(
                          () => _obscureKonfirmasi = !_obscureKonfirmasi),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }
                        if (val != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    SiankesPrimaryButton(
                      label: 'Daftar',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorIllustration() {
    return Container(
      width: 180,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.accentBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFBBDEFB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFCC80),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.face, size: 36, color: Color(0xFF795548)),
              ),
              const SizedBox(height: 4),
              Container(
                width: 60,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medical_information,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFCC80),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.face_2, size: 28,
                      color: Color(0xFF795548)),
                ),
                Container(
                  width: 44,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF333333))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF333333))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: const Icon(Icons.lock_outline,
                color: AppColors.grey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
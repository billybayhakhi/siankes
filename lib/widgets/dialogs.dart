import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ─────────────────────────────────────────────
// Dialog Registrasi Berhasil
// ─────────────────────────────────────────────
void showRegistrasiSuksesDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Registrasi Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Akun Anda telah berhasil dibuat.\nSilakan login untuk menggunakan aplikasi.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Dialog Login Berhasil (SUDAH FIX NAVIGASI)
// ─────────────────────────────────────────────
void showLoginSuksesDialog(
  BuildContext context, {
  String? userName,
  String? userPhotoUrl,
  String role = 'user',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              role == 'admin' ? 'Login Admin Berhasil!' : 'Login Berhasil!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName != null
                  ? 'Selamat datang, $userName!'
                  : 'Selamat datang!',
              textAlign: TextAlign.center,
            ),

            if (userPhotoUrl != null) ...[
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(userPhotoUrl),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // tutup dialog
                  if (role == 'admin') {
                    Navigator.of(context).pushReplacementNamed('/admin_dashboard');
                  } else {
                    Navigator.of(context).pushReplacementNamed(
                      '/dashboard',
                      arguments: userName ?? 'Pengguna',
                    );
                  }
                },
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


// ─────────────────────────────────────────────
// Dialog Login Gagal
// ─────────────────────────────────────────────
void showLoginGagalDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login Gagal!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message ?? 'Email/nomor HP atau password salah.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// Dialog Lupa Password
// ─────────────────────────────────────────────
void showLupaPasswordDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSent = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Lupa Password'),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email atau Nomor HP',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Harap isi' : null,
                ),

                if (isSent)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'Link reset telah dikirim!',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            setState(() => isSent = true);

                            Future.delayed(const Duration(seconds: 2), () {
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            });
                          }
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
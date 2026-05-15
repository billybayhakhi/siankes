import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/utils/validators.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';
import '../../widgets/shared_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _dobCtrl;
  String _gender = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _addressCtrl = TextEditingController(text: user?.address ?? '');
    _dobCtrl = TextEditingController(text: user?.dateOfBirth ?? '');
    _gender = user?.gender ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final updated = auth.user!.copyWith(
      name: _nameCtrl.text.trim(), phone: _phoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(), dateOfBirth: _dobCtrl.text.trim(),
      gender: _gender,
    );
    await auth.updateProfile(updated);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppColors.success));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GradientAppBar(title: 'Edit Profil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(children: [
          // Avatar
          Center(child: Stack(children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: AppColors.primarySurface, shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 3)),
              child: const Icon(Icons.person_rounded, size: 44, color: AppColors.primary),
            ),
            Positioned(bottom: 0, right: 0, child: Container(
              padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
            )),
          ])),
          const SizedBox(height: 28),
          AppTextField(controller: _nameCtrl, label: 'Nama Lengkap', prefixIcon: Icons.person_outline, validator: Validators.name),
          const SizedBox(height: 16),
          AppTextField(controller: _phoneCtrl, label: 'Nomor HP', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
          const SizedBox(height: 16),
          AppTextField(controller: _addressCtrl, label: 'Alamat', prefixIcon: Icons.location_on_outlined, maxLines: 2),
          const SizedBox(height: 16),
          AppTextField(controller: _dobCtrl, label: 'Tanggal Lahir', hint: 'DD/MM/YYYY', prefixIcon: Icons.cake_outlined),
          const SizedBox(height: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Jenis Kelamin', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              _genderChip('Laki-laki', Icons.male_rounded),
              const SizedBox(width: 12),
              _genderChip('Perempuan', Icons.female_rounded),
            ]),
          ]),
          const SizedBox(height: 32),
          PrimaryButton(label: 'SIMPAN PERUBAHAN', onPressed: _save, isLoading: _saving, icon: Icons.save_rounded),
        ])),
      ),
    );
  }

  Widget _genderChip(String label, IconData icon) {
    final sel = _gender == label;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _gender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: sel ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: sel ? Border.all(color: AppColors.primary, width: 2) : Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 20, color: sel ? AppColors.primary : AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppColors.primary : AppColors.textSecondary)),
        ]),
      ),
    ));
  }
}

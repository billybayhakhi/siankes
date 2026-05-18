import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/constants/app_constants.dart';
import 'package:siankes/presentation/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final hasOnboarded = prefs.getBool(AppConstants.prefKeyOnboarded) ?? false;
    // ignore: use_build_context_synchronously
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = auth.isAuthenticated;

    if (!mounted) return;

    String route;
    if (!hasOnboarded) {
      route = '/onboarding';
    } else if (isAuthenticated) {
      route = '/home';
    } else {
      route = '/login';
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/images/logo.png', width: 100, height: 100, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(delay: const Duration(milliseconds: 600), child: Text('SIANKES', style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3))),
              const SizedBox(height: 8),
              FadeInUp(delay: const Duration(milliseconds: 800), child: Text(AppConstants.appFullName, style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70, letterSpacing: 0.5))),
              const SizedBox(height: 60),
              FadeIn(delay: const Duration(milliseconds: 1200), child: const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white54))),
            ],
          ),
        ),
      ),
    );
  }
}

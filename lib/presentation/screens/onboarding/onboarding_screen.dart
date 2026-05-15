import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siankes/core/theme/app_colors.dart';
import 'package:siankes/core/constants/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final _icons = [Icons.confirmation_number_rounded, Icons.track_changes_rounded, Icons.calendar_month_rounded];

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefKeyOnboarded, true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(onPressed: _finish, child: Text('Lewati', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontWeight: FontWeight.w600))),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: 3,
                  itemBuilder: (ctx, i) {
                    final page = AppConstants.onboardingPages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 140, height: 140,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                            child: Icon(_icons[i], size: 70, color: Colors.white),
                          ),
                          const SizedBox(height: 48),
                          Text(page['title']!, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 16),
                          Text(page['subtitle']!, textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.white70, height: 1.6)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Indicators + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8, height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? Colors.white : Colors.white30,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: Text(_currentPage == 2 ? 'Mulai Sekarang' : 'Lanjutkan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

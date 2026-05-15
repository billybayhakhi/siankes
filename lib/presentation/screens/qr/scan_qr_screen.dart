import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:siankes/core/theme/app_colors.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});
  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController? _controller;
  bool _scanned = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    final raw = barcode!.rawValue!;
    if (!raw.startsWith('SIANKES|')) return;

    setState(() => _scanned = true);
    _controller?.stop();

    final parts = raw.split('|');
    // SIANKES|id|queueNumber|poliId|timestamp
    if (parts.length >= 4) {
      _showResult(parts[2], parts[3], parts[0] == 'SIANKES');
    } else {
      _showInvalid();
    }
  }

  void _showResult(String queueNumber, String poliId, bool valid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: valid ? AppColors.successLight : AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              valid ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: valid ? AppColors.success : AppColors.error, size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(valid ? 'QR Valid!' : 'QR Tidak Valid',
            style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800)),
          if (valid) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text('Nomor Antrian', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary)),
                Text(queueNumber, style: GoogleFonts.plusJakartaSans(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
                Text('Poli: $poliId', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 8),
            Text('Pasien dapat dilayani', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _scanned = false);
              _controller?.start();
            },
            child: Text('Scan Lagi', style: GoogleFonts.plusJakartaSans(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
            child: Text('Selesai', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showInvalid() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('QR Tidak Dikenali', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
        content: Text('QR code bukan milik SIANKES. Pastikan menggunakan QR dari aplikasi ini.'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); setState(() => _scanned = false); _controller?.start(); },
            child: Text('Coba Lagi', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Scan QR Code', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
            onPressed: () { _controller?.toggleTorch(); setState(() => _flashOn = !_flashOn); },
          ),
        ],
      ),
      body: Stack(children: [
        // Camera view
        MobileScanner(
          controller: _controller!,
          onDetect: _onDetect,
        ),
        // Scan overlay
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // QR frame
              Container(
                width: 260, height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(children: [
                  // Corner decorations
                  _corner(top: 0, left: 0),
                  _corner(top: 0, right: 0, flipX: true),
                  _corner(bottom: 0, left: 0, flipY: true),
                  _corner(bottom: 0, right: 0, flipX: true, flipY: true),
                  // Scan line animation
                  if (!_scanned) const _ScanLine(),
                ]),
              ),
              const SizedBox(height: 30),
              Text('Arahkan kamera ke QR Code antrian', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('QR Code tersedia di detail antrian Anda', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right, bool flipX = false, bool flipY = false}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(flipX ? -1 : 1, flipY ? -1 : 1, 1),
        child: Container(
          width: 28, height: 28,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white, width: 4), left: BorderSide(color: Colors.white, width: 4)),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(6)),
          ),
        ),
      ),
    );
  }
}

// Animated scan line
class _ScanLine extends StatefulWidget {
  const _ScanLine();
  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: _anim.value * 240,
        left: 0, right: 0,
        child: Container(height: 2, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, AppColors.primary, Colors.transparent]),
        )),
      ),
    );
  }
}

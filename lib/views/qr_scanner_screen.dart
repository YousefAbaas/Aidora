import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/request_model.dart';
import '../services/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  final RequestModel request;
  const QRScannerScreen({super.key, required this.request});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late final MobileScannerController _camCtrl;
  bool _scanned   = false;
  bool _loading   = false;
  String? _resultRef;
  String? _resultStatus;
  String? _resultReceivedAt;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _camCtrl = MobileScannerController();
  }

  @override
  void dispose() {
    _camCtrl.dispose();
    super.dispose();
  }

  // ── Called when camera detects a QR code ──────────────────────────────────
  void _onDetect(BarcodeCapture capture) {
    if (_scanned || _loading) return;
    if (capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue ?? '';
    if (rawValue.isEmpty) return;

    _sendToApi(rawValue);
  }

  // ── POST /api/requests/<pk>/scan-qr/ ────────────────────────────────────
  Future<void> _sendToApi(String qrValue) async {
    setState(() { _loading = true; _errorMsg = null; });

    final endpoint = '/api/requests/${widget.request.id}/scan-qr/';
    final r = await ApiService.instance.post(
      endpoint,
      body: {'qr_code': qrValue},
      requiresAuth: true,
    );

    if (!mounted) return;

    if (r.isSuccess) {
      final data = r.data as Map<String, dynamic>? ?? {};
      setState(() {
        _scanned        = true;
        _loading        = false;
        _resultRef      = data['ref']?.toString();
        _resultStatus   = data['status']?.toString();
        _resultReceivedAt = data['received_at']?.toString();
      });
      Get.snackbar(
        '✓ Request Completed',
        data['message']?.toString() ?? 'Request completed successfully',
        backgroundColor: const Color(0xFF27AE60),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        borderRadius: 12,
        margin: const EdgeInsets.all(12),
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    } else {
      setState(() { _loading = false; _errorMsg = r.errorMessage ?? 'QR scan failed'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1E3A2F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                    onPressed: () => Get.back(result: _scanned),
                  ),
                ),
                const SizedBox(width: 14),
                const Text('Scan QR Code',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ]),
            ),

            // ── Scanner / Result area ────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera frame or success check
                      Container(
                        width: 260, height: 260,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _scanned
                                ? const Color(0xFF27AE60)
                                : _errorMsg != null
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF27AE60), strokeWidth: 3))
                            : _scanned
                                ? const Center(
                                    child: Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF27AE60), size: 90))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(22),
                                    child: MobileScanner(
                                      controller: _camCtrl,
                                      onDetect: _onDetect,
                                    ),
                                  ),
                      ),

                      const SizedBox(height: 24),

                      // Status text / error
                      if (_errorMsg != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(_errorMsg!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.center),
                        )
                      else
                        Text(
                          _scanned
                              ? 'Request completed successfully!'
                              : _loading
                                  ? 'Verifying QR code…'
                                  : 'Point your camera at the QR code\nto verify your request',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 14, height: 1.5),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 16),

                      // Ref number chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.tag_rounded, color: Colors.white60, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '#${_resultRef ?? widget.request.ref}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18,
                                fontWeight: FontWeight.w800, letterSpacing: 1),
                          ),
                        ]),
                      ),

                      // Result info after scan
                      if (_scanned && _resultStatus != null) ...[
                        const SizedBox(height: 12),
                        _ResultChip(
                            icon: Icons.flag_rounded,
                            label: 'Status: ${_resultStatus!.toUpperCase()}',
                            color: const Color(0xFF27AE60)),
                        if (_resultReceivedAt != null) ...[
                          const SizedBox(height: 8),
                          _ResultChip(
                              icon: Icons.access_time_rounded,
                              label: _resultReceivedAt!,
                              color: Colors.white54),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // ── Done button ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : _scanned
                          ? () => Get.back(result: true)
                          : null,
                  icon: Icon(
                    _scanned
                        ? Icons.check_circle_rounded
                        : Icons.qr_code_scanner_rounded,
                    size: 20),
                  label: Text(_scanned ? 'Done — Request Completed' : 'Waiting for scan…'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _scanned
                        ? const Color(0xFF27AE60)
                        : Colors.white.withOpacity(0.15),
                    disabledBackgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white38,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                    elevation: _scanned ? 6 : 0,
                    shadowColor: const Color(0xFF27AE60).withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small result chip ─────────────────────────────────────────────────────────
class _ResultChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  const _ResultChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12,
            fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

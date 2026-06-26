import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/profile_api_service.dart';
import 'main_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// CompleteProfileScreen
/// Shown when /api/auth/me → profile_completed = false
/// POST /api/auth/refugees/complete-profile/
///
/// Fields:
///   gender          → dropdown
///   family_members  → family category picker (type + count)
///   date_of_birth   → string "YYYY-MM-DD"
///   location        → string
///   sector_name     → stored in location for now (matches UI)
///   consent_given   → checkbox
/// ─────────────────────────────────────────────────────────────────────────────
class CompleteProfileScreen extends StatefulWidget {
  /// If true, just close on Done (user came from request flow).
  /// If false, navigate to MainScreen after done.
  final bool returnOnComplete;

  const CompleteProfileScreen({super.key, this.returnOnComplete = false});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  static const Color _green = Color(0xFF2C5F4F);
  static const Color _bg    = Color(0xFFF5F3ED);

  final _locCtrl    = TextEditingController();
  final _sectorCtrl = TextEditingController();

  // ── Date field ─────────────────────────────────────────────────────────────
  DateTime? _selectedBirthDate;

  String? _gender;
  bool    _consent    = false;
  bool    _isLoading  = false;

  // ── Family members: {type, count} ─────────────────────────────────────────
  static const _familyTypes = [
    'Children', 'Elderly', 'With disabilities', 'Women',
  ];
  final Map<String, int> _familyCounts = {
    'Children': 0, 'Elderly': 0, 'With disabilities': 0, 'Women': 0,
  };

  // Selected family "category" shown in dropdown
  String? _selectedFamilyCategory;

  @override
  void dispose() {
    _locCtrl.dispose(); _sectorCtrl.dispose();
    super.dispose();
  }




  // ── Build date string from selected date ───────────────────────────────────
  String _buildDate() {
    if (_selectedBirthDate == null) return '';
    final y = _selectedBirthDate!.year.toString().padLeft(4, '0');
    final m = _selectedBirthDate!.month.toString().padLeft(2, '0');
    final d = _selectedBirthDate!.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ── Open date picker ────────────────────────────────────────────────────────
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2C5F4F),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A2E28),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) setState(() => _selectedBirthDate = picked);
  }

  // ── Validate ───────────────────────────────────────────────────────────────
  bool _validate() {
    if (_gender == null) { _err('Please select your gender.'); return false; }
    if (_buildDate().isEmpty) { _err('Please enter your birthday.'); return false; }
    if (_locCtrl.text.trim().isEmpty) { _err('Please enter your location.'); return false; }
    if (!_consent) { _err('Please accept the data consent to continue.'); return false; }
    return true;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    setState(() => _isLoading = true);

    final familyList = _familyTypes
        .map((t) => {'type': t, 'count': _familyCounts[t]!})
        .toList();

    final location = [
      _locCtrl.text.trim(),
      if (_sectorCtrl.text.trim().isNotEmpty) _sectorCtrl.text.trim(),
    ].join(', ');

    final result = await ProfileApiService.instance.completeProfile(
      gender:        _gender!,
      dateOfBirth:   _buildDate(),
      location:      location,
      consentGiven:  _consent,
      familyMembers: familyList,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (widget.returnOnComplete) {
        Get.back(result: true); // return true → request can proceed
      } else {
        Get.offAll(() => const MainScreen(), transition: Transition.fadeIn);
      }
    } else {
      _err(result.errorMessage ?? 'Failed to save profile. Try again.');
    }
  }

  void _err(String msg) => Get.snackbar(
    'Error', msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red[50],
    colorText: Colors.red[800],
    margin: const EdgeInsets.all(12), borderRadius: 12,
    maxWidth: 400,
    messageText: Text(msg,
        maxLines: 3, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 13, color: Colors.red[800])),
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(children: [
            // ── App bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(children: [
                if (widget.returnOnComplete)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: _green, size: 22),
                    onPressed: () => Get.back(),
                  )
                else
                  const SizedBox(width: 48),
                // Logo centre
                Expanded(
                  child: Center(
                    child: Image.asset('img/logo.jpg', height: 36,
                        errorBuilder: (_, __, ___) => const Text('aidora',
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold,
                                color: _green))),
                  ),
                ),
                const SizedBox(width: 48),
              ]),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Please complete your\npersonal information',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2E28), height: 1.25)),
                    const SizedBox(height: 28),

                    // ── Gender ──────────────────────────────────────────
                    _label('Gender'),
                    _dropdown(
                      value: _gender,
                      hint: 'Select gender',
                      items: const ['Male', 'Female', 'Other'],
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                    const SizedBox(height: 18),

                    // ── Family categories ───────────────────────────────
                    _label('Family categories'),
                    _familyCategoryPicker(),
                    const SizedBox(height: 18),

                    // ── Birthday ────────────────────────────────────────
                    _label('Birthday'),
                    _birthdayRow(),
                    const SizedBox(height: 18),

                    // ── Location ────────────────────────────────────────
                    _label('Location'),
                    _field(
                      controller: _locCtrl,
                      hint: 'City or Region',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 18),

                    // ── Sector ──────────────────────────────────────────
                    _label('Sector name'),
                    _field(
                      controller: _sectorCtrl,
                      hint: 'e.g. Sector B',
                      icon: Icons.domain_outlined,
                    ),
                    const SizedBox(height: 28),

                    // ── Consent ─────────────────────────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _consent = !_consent),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _consent ? _green : Colors.transparent,
                              border: Border.all(
                                color: _consent ? _green : Colors.grey[400]!,
                                width: 1.5,
                              ),
                            ),
                            child: _consent
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Consent to use personal data for humanitarian assistance purposes',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF5A5A5A),
                                  height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Done button ─────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          disabledBackgroundColor: _green.withOpacity(0.55),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : Text('done'.tr,
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Family category picker ─────────────────────────────────────────────────
  Widget _familyCategoryPicker() {
    // Show as a dropdown that opens a bottom sheet with counters
    final summary = _familyCounts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value}')
        .join('  ');

    return GestureDetector(
      onTap: _showFamilySheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              summary.isEmpty ? 'Select category' : summary,
              style: TextStyle(
                  fontSize: 15,
                  color: summary.isEmpty ? Colors.grey[400] : Colors.black87),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
        ]),
      ),
    );
  }

  void _showFamilySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Family Members',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ..._familyTypes.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(children: [
                Expanded(child: Text(type,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500))),
                _counter(
                  count: _familyCounts[type]!,
                  onDec: () {
                    if (_familyCounts[type]! > 0) {
                      setS(() => _familyCounts[type] = _familyCounts[type]! - 1);
                      setState(() {});
                    }
                  },
                  onInc: () {
                    setS(() => _familyCounts[type] = _familyCounts[type]! + 1);
                    setState(() {});
                  },
                ),
              ]),
            )),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirm'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _counter({
    required int count,
    required VoidCallback onDec,
    required VoidCallback onInc,
  }) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _counterBtn(Icons.remove, onDec),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('$count',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      _counterBtn(Icons.add, onInc),
    ]);
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
          color: _green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: _green),
    ),
  );

  // ── Birthday row ───────────────────────────────────────────────────────────
  Widget _birthdayRow() {
    final label = _selectedBirthDate == null
        ? 'Select date of birth'
        : '${_selectedBirthDate!.day.toString().padLeft(2,'0')} / '
          '${_selectedBirthDate!.month.toString().padLeft(2,'0')} / '
          '${_selectedBirthDate!.year}';

    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.calendar_today_rounded,
              color: _selectedBirthDate == null
                  ? Colors.grey[400] : const Color(0xFF2C5F4F),
              size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 15,
                    color: _selectedBirthDate == null
                        ? Colors.grey[400] : const Color(0xFF1A2E28))),
          ),
          Icon(Icons.arrow_drop_down_rounded,
              color: Colors.grey[400], size: 24),
        ]),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3A))),
  );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
        items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) => Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );
}

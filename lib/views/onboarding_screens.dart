import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'selection_screen.dart';

const Color _kBg = Color(0xFFF5F3ED);
const Color _kGreen = Color(0xFF2C5F4F);

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});
  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slide;

  static const List<Map<String, String>> _data = [
    {
      'image': 'img/onboarding1.png',
      'title': 'Connect with Aid\nOrganizations',
      'desc': 'Find humanitarian organizations ready to help you and your family, wherever you are.',
    },
    {
      'image': 'img/onboarding2.png',
      'title': 'Request the\nAssistance You Need',
      'desc': 'Submit requests for food, shelter, medical aid and more — quickly and easily.',
    },
    {
      'image': 'img/onboarding3_new.png',
      'title': 'Help Reaches You\nWherever You Are',
      'desc': 'Get the support you need, when you need it — no matter where you are.',
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _playAnim();
    _scheduleNext();
  }

  void _playAnim() {
    _fadeCtrl..reset()..forward();
    _slideCtrl..reset()..forward();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_page < _data.length - 1) {
        _pageCtrl.nextPage(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic);
      }
    });
  }

  void _onPageChanged(int p) {
    setState(() => _page = p);
    _playAnim();
    if (p < _data.length - 1) _scheduleNext();
  }

  void _finish() => Get.off(() => const SelectionScreen(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 400));

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final isLast = _page == _data.length - 1;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Skip ────────────────────────────────────────────────
          SizedBox(
            height: topPad + 52,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 8),
                child: GestureDetector(
                  onTap: _finish,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: _kGreen.withOpacity(0.09),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Skip',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kGreen)),
                  ),
                ),
              ),
            ),
          ),

          // ── Illustration PageView ────────────────────────────────
          // Images are 392×517 / 392×559 — same beige background as app.
          // BoxFit.contain shows the full illustration without clipping.
          Expanded(
            flex: 58,
            child: PageView.builder(
              controller: _pageCtrl,
              onPageChanged: _onPageChanged,
              itemCount: _data.length,
              itemBuilder: (_, i) => Container(
                color: _kBg,
                child: Image.asset(
                  _data[i]['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 80, color: Color(0xFFCCCCCC)),
                  ),
                ),
              ),
            ),
          ),

          // ── Text panel ───────────────────────────────────────────
          Expanded(
            flex: 42,
            child: Container(
              color: _kBg,
              padding:
                  EdgeInsets.fromLTRB(28, 0, 28, botPad + 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accent line
                  Container(
                    width: 40,
                    height: 3,
                    decoration: BoxDecoration(
                        color: _kGreen,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 16),

                  // Animated title + description
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _data[_page]['title']!,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A2E28),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _data[_page]['desc']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7876),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Dots + action button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(_data.length, (i) {
                          final active = i == _page;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.only(right: 7),
                            width: active ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? _kGreen
                                  : _kGreen.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),

                      // Last page → "Get Started"
                      if (isLast)
                        FadeTransition(
                          opacity: _fade,
                          child: ElevatedButton(
                            onPressed: _finish,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kGreen,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30)),
                              elevation: 4,
                              shadowColor: _kGreen.withOpacity(0.35),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Get Started',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),

                      // Other pages → circular arrow
                      if (!isLast)
                        GestureDetector(
                          onTap: () => _pageCtrl.nextPage(
                              duration:
                                  const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _kGreen.withOpacity(0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 24),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen1 extends OnboardingScreens {
  const OnboardingScreen1({super.key});
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'views/splash_screen.dart';
import 'views/selection_screen.dart';
import 'views/login_screen.dart';
import 'utils/app_theme.dart';
import 'utils/app_translations.dart';
import 'controllers/requests_controller.dart';
import 'controllers/bottom_nav_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/org_controller.dart';
import 'controllers/vol_controller.dart';
import 'controllers/settings_controller.dart';
import 'services/notification_service.dart';
import 'services/auth_storage.dart';

import 'views/reset_password_screen.dart';
import 'controllers/form_controller.dart';

/// Global RouteObserver for detecting screen resume events.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStorage.init();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Image cache: 150 images / 100MB for smooth scrolling
  PaintingBinding.instance.imageCache.maximumSize      = 150;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 << 20;
  runApp(const AidoraApp());
}

class AidoraApp extends StatefulWidget {
  const AidoraApp({super.key});

  @override
  State<AidoraApp> createState() => _AidoraAppState();
}

class _AidoraAppState extends State<AidoraApp> {
  static const _channel = MethodChannel('com.aidora.app/deep_links');

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Handle deep links while app is running (foreground/background)
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final uriStr = call.arguments as String?;
        if (uriStr != null) _handleDeepLink(Uri.parse(uriStr));
      }
    });

    // Handle deep link that launched the app from cold start
    _channel.invokeMethod<String>('getInitialLink').then((uriStr) {
      if (uriStr != null && uriStr.isNotEmpty) {
        _handleDeepLink(Uri.parse(uriStr));
      }
    }).catchError((Object err) {
      debugPrint('⚠️ getInitialLink error: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    // Expected: aidora://reset-password/{uid}/{token}/
    if (uri.scheme == 'aidora' && uri.host == 'reset-password') {
      final segments = uri.pathSegments
          .where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2) {
        final uid   = segments[0];
        final token = segments[1];
        Get.to(() => ResetPasswordScreen(uid: uid, token: token),
            transition: Transition.fadeIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // SettingsController is put first in initialBinding so it is available here
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (sc) => GetMaterialApp(
        title:                    'Aidora',
        debugShowCheckedModeBanner: false,
        defaultTransition:        Transition.cupertino,
        transitionDuration:       const Duration(milliseconds: 300),

        // ── i18n ───────────────────────────────────────────────────────────
        translations:  AppTranslations(),
        locale:        sc.locale,          // reactive
        fallbackLocale: const Locale('en'),

        // ── Theme ──────────────────────────────────────────────────────────
        theme:     AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: sc.themeMode,           // reactive — rebuilds app on toggle

        initialBinding: BindingsBuilder(() {
          Get.put(SettingsController(), permanent: true);
          final ns = Get.put(NotificationService(), permanent: true);
          ns.init();
          Get.put(ProfileController(),   permanent: true);
          Get.put(OrgController(),       permanent: true);
          Get.put(VolController(),       permanent: true);
          Get.put(FormController(),      permanent: true);
          Get.put(RequestsController(),  permanent: true);
          Get.put(BottomNavController(), permanent: true);
        }),

        getPages: [
          GetPage(name: '/login',  page: () => const LoginScreen()),
          GetPage(name: '/selection', page: () => const SelectionScreen()),
          GetPage(name: '/splash', page: () => const SplashScreen()),
        ],
        home: const SplashScreen(),
      ),
    );
  }
}

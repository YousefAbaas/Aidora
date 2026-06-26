// platform_helper_io.dart
// Used on Flutter NATIVE (Android, iOS, Desktop).
// dart:io is available here — safe to import Platform.
import 'dart:io';

// ─────────────────────────────────────────────────────────────────────────
// NGROK SUPPORT — للاتصال بسيرفر Django المحلي من أي مكان
// ─────────────────────────────────────────────────────────────────────────
// الخطوات:
// 1. شغّل Django:   python manage.py runserver 0.0.0.0:8000
// 2. شغّل ngrok:    ngrok http 8000
// 3. انسخ الرابط الظاهر مثل: https://abc123.ngrok-free.app
// 4. ضعه في المتغير أدناه بدون / في النهاية
// 5. أعد بناء الـ APK
// ─────────────────────────────────────────────────────────────────────────
const String _ngrokUrl = 'https://defrost-jogging-capital.ngrok-free.dev';

// ─────────────────────────────────────────────────────────────────────────
// LAN IP — إذا كان الموبايل واللابتوب على نفس الـ WiFi
// ─────────────────────────────────────────────────────────────────────────
const String _realDeviceLanIp = ''; // e.g. '192.168.1.50'

String getPlatformBaseUrl() {
  // أعلى أولوية: ngrok (يعمل من أي مكان عبر الإنترنت)
  if (_ngrokUrl.isNotEmpty) return _ngrokUrl;

  // ثانياً: override عبر --dart-define (بدون إعادة بناء)
  const fromDefine = String.fromEnvironment('API_HOST');
  if (fromDefine.isNotEmpty) return 'http://$fromDefine:8000';

  // ثالثاً: IP محلي يدوي (نفس الشبكة فقط)
  if (_realDeviceLanIp.isNotEmpty) return 'http://$_realDeviceLanIp:8000';

  // المحاكي: 10.0.2.2 يشير لجهاز الكمبيوتر المضيف
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';

  return 'http://127.0.0.1:8000';
}

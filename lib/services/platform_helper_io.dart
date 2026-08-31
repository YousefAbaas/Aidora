import 'dart:io';
import 'package:flutter/foundation.dart';

const String _productionApiUrl = 'https://aidora-z01k.onrender.com';
const String _ngrokUrl = 'https://defrost-jogging-capital.ngrok-free.dev';
const String _realDeviceLanIp = '';

String getPlatformBaseUrl() {
  // Release builds always use the production API.
  if (kReleaseMode) {
    return _productionApiUrl;
  }

  // Debug/development override through --dart-define.
  const fromDefine = String.fromEnvironment('API_BASE_URL');
  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }

  // Development-only ngrok tunnel.
  if (_ngrokUrl.isNotEmpty) {
    return _ngrokUrl;
  }

  // Development-only LAN IP.
  if (_realDeviceLanIp.isNotEmpty) {
    return 'http://$_realDeviceLanIp:8000';
  }

  // Android emulator → host machine.
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000';
  }

  return 'http://127.0.0.1:8000';
}
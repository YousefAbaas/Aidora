import 'package:flutter/foundation.dart';

const String _productionApiUrl = 'https://workserveys.pythonanywhere.com';

String getPlatformBaseUrl() {
  if (kReleaseMode) {
    return _productionApiUrl;
  }

  const fromDefine = String.fromEnvironment('API_BASE_URL');

  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }

  return _productionApiUrl;
}

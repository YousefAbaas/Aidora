import 'dart:async';
import 'dart:convert';

import 'package:aidora/services/auth_storage.dart';
import 'package:aidora/services/token_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_token_store.dart';

String _jwtWithExpiry(DateTime expiry) {
  final payload = base64Url
      .encode(utf8.encode(jsonEncode({
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      })))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthTokenStore tokenStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenStore = FakeAuthTokenStore();
    AuthStorage.setTokenStoreForTesting(tokenStore);
    await AuthStorage.init();
    await AuthStorage.saveTokens(
      accessToken: _jwtWithExpiry(
        DateTime.now().add(const Duration(minutes: 30)),
      ),
      refreshToken: 'old-refresh-token',
      role: 'refugee',
    );
  });

  tearDown(() {
    AuthStorage.resetForTesting();
  });

  test('refuses and clears an access-only session', () async {
    await tokenStore.delete('auth_refresh_token');

    // Reinitialize the token manager's source of truth as if the app started
    // with an incomplete secure session.
    AuthStorage.resetForTesting();
    AuthStorage.setTokenStoreForTesting(tokenStore);
    await AuthStorage.init();

    final client = MockClient((request) async {
      throw StateError(
        'An access-only session must not trigger an HTTP refresh.',
      );
    });
    addTearDown(client.close);

    final manager = TokenManager.forTesting(client);
    expect(await manager.getValidAccessToken(), isNull);
    expect(AuthStorage.getAccessToken(), isNull);
    expect(AuthStorage.getRefreshToken(), isNull);
    expect(AuthStorage.isLoggedIn, isFalse);
  });

  test('stores both new tokens when Django rotates the refresh token', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({
          'access': 'new-access-token',
          'refresh': 'new-refresh-token',
        }),
        200,
      );
    });
    addTearDown(client.close);

    final manager = TokenManager.forTesting(client);

    expect(await manager.forceRefresh(), isTrue);
    expect(
      jsonDecode(capturedRequest.body),
      {'refresh': 'old-refresh-token'},
    );
    expect(tokenStore.values['auth_access_token'], 'new-access-token');
    expect(tokenStore.values['auth_refresh_token'], 'new-refresh-token');
    expect(AuthStorage.getAccessToken(), 'new-access-token');
    expect(AuthStorage.getRefreshToken(), 'new-refresh-token');
    expect(AuthStorage.isLoggedIn, isTrue);
  });

  test('uses proactive refresh when the access token is close to expiry', () async {
    await AuthStorage.saveTokens(
      accessToken: _jwtWithExpiry(
        DateTime.now().add(const Duration(seconds: 30)),
      ),
      refreshToken: 'old-refresh-token',
      role: 'refugee',
    );

    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'access': 'proactive-access-token',
          'refresh': 'proactive-refresh-token',
        }),
        200,
      );
    });
    addTearDown(client.close);

    final manager = TokenManager.forTesting(client);
    expect(await manager.getValidAccessToken(), 'proactive-access-token');
    expect(tokenStore.values['auth_refresh_token'], 'proactive-refresh-token');
  });

  test('fails closed if rotation response omits the replacement refresh token', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'access': 'new-access-token'}),
        200,
      );
    });
    addTearDown(client.close);

    final manager = TokenManager.forTesting(client);
    expect(await manager.forceRefresh(), isFalse);
    expect(AuthStorage.getAccessToken(), isNull);
    expect(AuthStorage.getRefreshToken(), isNull);
    expect(AuthStorage.isLoggedIn, isFalse);
  });

  test('deduplicates concurrent refresh calls', () async {
    final completer = Completer<http.Response>();
    var requestCount = 0;
    final client = MockClient((request) {
      requestCount++;
      return completer.future;
    });
    addTearDown(client.close);

    final manager = TokenManager.forTesting(client);
    final first = manager.forceRefresh();
    final second = manager.forceRefresh();

    await Future<void>.delayed(Duration.zero);
    expect(requestCount, 1);
    completer.complete(
      http.Response(
        jsonEncode({
          'access': 'shared-access-token',
          'refresh': 'shared-refresh-token',
        }),
        200,
      ),
    );

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(requestCount, 1);
    expect(tokenStore.values['auth_refresh_token'], 'shared-refresh-token');
  });
}

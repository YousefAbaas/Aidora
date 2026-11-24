import 'package:aidora/services/auth_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_auth_token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAuthTokenStore tokenStore;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tokenStore = FakeAuthTokenStore();
    AuthStorage.setTokenStoreForTesting(tokenStore);
  });

  tearDown(() {
    AuthStorage.resetForTesting();
  });

  test('migrates legacy tokens only after secure read-back verification', () async {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'legacy-access',
      'auth_refresh_token': 'legacy-refresh',
      'auth_role': 'refugee',
      'auth_email': 'person@example.test',
      'auth_display_name': 'Person',
    });

    await AuthStorage.init();

    final prefs = await SharedPreferences.getInstance();
    expect(tokenStore.values['auth_access_token'], 'legacy-access');
    expect(tokenStore.values['auth_refresh_token'], 'legacy-refresh');
    expect(prefs.getString('auth_access_token'), isNull);
    expect(prefs.getString('auth_refresh_token'), isNull);
    expect(prefs.getString('auth_role'), 'refugee');
    expect(AuthStorage.getAccessToken(), 'legacy-access');
    expect(AuthStorage.getRefreshToken(), 'legacy-refresh');
    expect(AuthStorage.isLoggedIn, isTrue);
  });

  test('does not expose legacy plaintext tokens when secure reads fail', () async {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'legacy-access',
      'auth_refresh_token': 'legacy-refresh',
    });
    tokenStore.failReads = true;

    await AuthStorage.init();

    final prefs = await SharedPreferences.getInstance();
    expect(AuthStorage.getAccessToken(), isNull);
    expect(AuthStorage.getRefreshToken(), isNull);
    expect(AuthStorage.isLoggedIn, isFalse);
    // Keep old values so a later successful secure-store initialization can
    // retry the migration; never use them as an authentication fallback.
    expect(prefs.getString('auth_access_token'), 'legacy-access');
    expect(prefs.getString('auth_refresh_token'), 'legacy-refresh');
  });

  test('retains legacy tokens when secure migration writes fail', () async {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'legacy-access',
      'auth_refresh_token': 'legacy-refresh',
    });
    tokenStore.failWrites = true;

    await AuthStorage.init();

    final prefs = await SharedPreferences.getInstance();
    expect(AuthStorage.getAccessToken(), isNull);
    expect(prefs.getString('auth_access_token'), 'legacy-access');
    expect(prefs.getString('auth_refresh_token'), 'legacy-refresh');
  });

  test('saveTokens writes secrets securely and metadata to SharedPreferences', () async {
    await AuthStorage.saveTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
      role: 'volunteer',
      email: 'volunteer@example.test',
      displayName: 'Volunteer',
    );

    final prefs = await SharedPreferences.getInstance();
    expect(tokenStore.values['auth_access_token'], 'new-access');
    expect(tokenStore.values['auth_refresh_token'], 'new-refresh');
    expect(prefs.getString('auth_access_token'), isNull);
    expect(prefs.getString('auth_refresh_token'), isNull);
    expect(prefs.getString('auth_role'), 'volunteer');
    expect(prefs.getString('auth_email'), 'volunteer@example.test');
    expect(prefs.getString('auth_display_name'), 'Volunteer');
    expect(AuthStorage.getAccessToken(), 'new-access');
    expect(AuthStorage.isLoggedIn, isTrue);
  });

  test('updateAccessToken updates secure storage and the memory cache', () async {
    await AuthStorage.saveTokens(
      accessToken: 'old-access',
      refreshToken: 'refresh',
      role: 'refugee',
    );

    await AuthStorage.updateAccessToken('rotated-access');

    expect(tokenStore.values['auth_access_token'], 'rotated-access');
    expect(AuthStorage.getAccessToken(), 'rotated-access');
  });

  test('clear removes secure tokens and local session metadata', () async {
    await AuthStorage.saveTokens(
      accessToken: 'access',
      refreshToken: 'refresh',
      role: 'refugee',
      email: 'person@example.test',
      displayName: 'Person',
    );

    await AuthStorage.clear();

    final prefs = await SharedPreferences.getInstance();
    expect(tokenStore.values, isEmpty);
    expect(AuthStorage.getAccessToken(), isNull);
    expect(AuthStorage.getRefreshToken(), isNull);
    expect(AuthStorage.isLoggedIn, isFalse);
    expect(prefs.getString('auth_role'), isNull);
    expect(prefs.getString('auth_email'), isNull);
    expect(prefs.getString('auth_display_name'), isNull);
  });
}

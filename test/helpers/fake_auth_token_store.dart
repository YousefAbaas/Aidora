import 'package:aidora/services/auth_storage.dart';

/// In-memory test double for the secure token-storage boundary.
class FakeAuthTokenStore implements AuthTokenStore {
  final Map<String, String> values = <String, String>{};

  bool failReads = false;
  bool failWrites = false;
  bool failDeletes = false;

  @override
  Future<String?> read(String key) async {
    if (failReads) {
      throw StateError('Synthetic secure-store read failure.');
    }
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrites) {
      throw StateError('Synthetic secure-store write failure.');
    }
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    if (failDeletes) {
      throw StateError('Synthetic secure-store delete failure.');
    }
    values.remove(key);
  }
}

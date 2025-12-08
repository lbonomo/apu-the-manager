import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GeminiKeyStorage {
  GeminiKeyStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _storageKey = 'gemini_api_key';

  Future<String?> read() => _storage.read(key: _storageKey);

  Future<void> write(String value) =>
      _storage.write(key: _storageKey, value: value);

  Future<void> clear() => _storage.delete(key: _storageKey);

  Future<String?> ensureKeyLoaded({String? fallback}) async {
    final stored = await read();
    if (stored != null && stored.isNotEmpty) return stored;

    // If fallback is provided, store it and return
    if (fallback != null && fallback.isNotEmpty) {
      await write(fallback);
      return fallback;
    }
    return null;
  }
}

final geminiKeyStorageProvider = Provider<GeminiKeyStorage>(
  (ref) => GeminiKeyStorage(),
);

final geminiApiKeyProvider = FutureProvider<String?>(
  (ref) async => ref.watch(geminiKeyStorageProvider).ensureKeyLoaded(),
);

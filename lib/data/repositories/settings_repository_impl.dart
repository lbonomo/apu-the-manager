import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String _loggingEnabledKey = 'logging_enabled';
  static const String _geminiApiKeyKey = 'gemini_api_key';

  @override
  Future<bool> getLoggingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggingEnabledKey) ?? true; // Default to true
  }

  @override
  Future<void> setLoggingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggingEnabledKey, enabled);
  }

  @override
  Future<String?> getGeminiApiKey() async {
    return await _secureStorage.read(key: _geminiApiKeyKey);
  }

  @override
  Future<void> setGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _geminiApiKeyKey, value: apiKey);
  }
}

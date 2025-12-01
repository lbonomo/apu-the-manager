import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  @override
  Future<void> setGeminiApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, apiKey);
  }
}

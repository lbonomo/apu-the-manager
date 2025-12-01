abstract class SettingsRepository {
  Future<bool> getLoggingEnabled();
  Future<void> setLoggingEnabled(bool enabled);
  Future<String?> getGeminiApiKey();
  Future<void> setGeminiApiKey(String apiKey);
}

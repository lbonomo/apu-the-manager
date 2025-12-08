import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Migration utility to move API key from SharedPreferences to FlutterSecureStorage
/// This should be run once when the app starts, and can be removed after all users
/// have migrated.
class ConfigMigrationService {
  static const String _oldApiKeyKey = 'gemini_api_key';
  static const String _migrationCompleteKey = 'config_migration_complete';

  /// Migrates API key from SharedPreferences to FlutterSecureStorage if needed
  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if migration has already been completed
    final migrationComplete = prefs.getBool(_migrationCompleteKey) ?? false;
    if (migrationComplete) {
      return; // Migration already done
    }

    // Try to get old API key from SharedPreferences
    final oldApiKey = prefs.getString(_oldApiKeyKey);
    
    if (oldApiKey != null && oldApiKey.isNotEmpty) {
      // Migrate to secure storage
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: _oldApiKeyKey, value: oldApiKey);
      
      // Remove from SharedPreferences
      await prefs.remove(_oldApiKeyKey);
    }

    // Mark migration as complete
    await prefs.setBool(_migrationCompleteKey, true);
  }
}

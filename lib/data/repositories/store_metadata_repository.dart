import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/store_metadata_config.dart';

class StoreMetadataRepository {
  static const _prefix = 'store_metadata_config_';

  Future<StoreMetadataConfig> getConfig(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_prefix$storeId');
    
    if (jsonString == null) {
      return StoreMetadataConfig(storeId: storeId, fields: []);
    }
    
    try {
      final jsonMap = json.decode(jsonString);
      return StoreMetadataConfig.fromJson(jsonMap);
    } catch (e) {
      return StoreMetadataConfig(storeId: storeId, fields: []);
    }
  }

  Future<void> saveConfig(StoreMetadataConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(config.toJson());
    await prefs.setString('$_prefix${config.storeId}', jsonString);
  }
}

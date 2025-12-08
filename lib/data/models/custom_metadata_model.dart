import '../../domain/entities/custom_metadata.dart';

class CustomMetadataModel extends CustomMetadata {
  const CustomMetadataModel({
    required super.key,
    super.stringValue,
    super.numericValue,
    super.stringListValue,
  });

  factory CustomMetadataModel.fromJson(Map<String, dynamic> json) {
    // Parse stringListValue if present
    List<String>? stringList;
    if (json.containsKey('stringListValue')) {
      final stringListJson = json['stringListValue'];
      if (stringListJson is Map<String, dynamic> && 
          stringListJson.containsKey('values')) {
        final values = stringListJson['values'];
        if (values is List) {
          stringList = values.map((e) => e.toString()).toList();
        }
      }
    }

    return CustomMetadataModel(
      key: json['key']?.toString() ?? 'unknown_key',
      stringValue: json['stringValue'] as String?,
      numericValue: json['numericValue'] != null
          ? (json['numericValue'] as num).toDouble()
          : null,
      stringListValue: stringList,
    );
  }
}


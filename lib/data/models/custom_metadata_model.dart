import '../../domain/entities/custom_metadata.dart';

class CustomMetadataModel extends CustomMetadata {
  const CustomMetadataModel({
    required super.key,
    super.stringValue,
    super.numericValue,
  });

  factory CustomMetadataModel.fromJson(Map<String, dynamic> json) {
    return CustomMetadataModel(
      key: json['key'] as String,
      stringValue: json['stringValue'] as String?,
      numericValue: json['numericValue'] != null
          ? (json['numericValue'] as num).toDouble()
          : null,
    );
  }
}

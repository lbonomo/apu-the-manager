import '../../domain/entities/document.dart';
import '../../core/utils/json_converters.dart';
import 'custom_metadata_model.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.name,
    super.displayName,
    super.createTime,
    super.updateTime,
    super.state,
    super.sizeBytes,
    super.mimeType,
    super.customMetadata,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    final customMetadataJson = json['customMetadata'] as List<dynamic>?;
    final customMetadata = customMetadataJson
        ?.map((item) => CustomMetadataModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return DocumentModel(
      // Usar toString() y valor por defecto para evitar crash por null
      name: json['name']?.toString() ?? '',
      displayName: json['displayName'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      state: stringToDocumentState(json['state'] as String?),
      sizeBytes: stringToInt(json['sizeBytes']),
      mimeType: json['mimeType'] as String?,
      customMetadata: customMetadata,
    );
  }
}

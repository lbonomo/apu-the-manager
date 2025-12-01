import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/document.dart';
import '../../core/utils/json_converters.dart';

part 'document_model.g.dart';

@JsonSerializable(createFactory: false)
class DocumentModel extends Document {
  const DocumentModel({
    required super.name,
    super.displayName,
    super.createTime,
    super.updateTime,
    super.state,
    super.sizeBytes,
    super.mimeType,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      name: json['name'] as String,
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
    );
  }

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}

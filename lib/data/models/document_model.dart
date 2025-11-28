import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/document.dart';
import '../../core/utils/json_converters.dart';

part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel extends Document {
  const DocumentModel({
    required super.name,
    super.displayName,
    super.createTime,
    super.updateTime,
    @JsonKey(fromJson: stringToDocumentState) super.state,
    @JsonKey(fromJson: stringToInt) super.sizeBytes,
    super.mimeType,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/store.dart';
import '../../core/utils/json_converters.dart';

part 'store_model.g.dart';

@JsonSerializable(createFactory: false)
class StoreModel extends Store {
  const StoreModel({
    required super.name,
    super.displayName,
    super.createTime,
    super.updateTime,
    super.activeDocumentsCount,
    super.pendingDocumentsCount,
    super.failedDocumentsCount,
    super.sizeBytes,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      activeDocumentsCount: stringToInt(json['activeDocumentsCount']),
      pendingDocumentsCount: stringToInt(json['pendingDocumentsCount']),
      failedDocumentsCount: stringToInt(json['failedDocumentsCount']),
      sizeBytes: stringToInt(json['sizeBytes']),
    );
  }

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);
}

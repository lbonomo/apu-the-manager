import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/store.dart';
import '../../core/utils/json_converters.dart';

part 'store_model.g.dart';

@JsonSerializable()
class StoreModel extends Store {
  const StoreModel({
    required super.name,
    super.displayName,
    super.createTime,
    super.updateTime,
    @JsonKey(fromJson: stringToInt) super.activeDocumentsCount,
    @JsonKey(fromJson: stringToInt) super.pendingDocumentsCount,
    @JsonKey(fromJson: stringToInt) super.failedDocumentsCount,
    @JsonKey(fromJson: stringToInt) super.sizeBytes,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoreModelToJson(this);
}

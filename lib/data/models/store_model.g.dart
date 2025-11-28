// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreModel _$StoreModelFromJson(Map<String, dynamic> json) => StoreModel(
  name: json['name'] as String,
  displayName: json['displayName'] as String?,
  createTime: json['createTime'] == null
      ? null
      : DateTime.parse(json['createTime'] as String),
  updateTime: json['updateTime'] == null
      ? null
      : DateTime.parse(json['updateTime'] as String),
  activeDocumentsCount: (json['activeDocumentsCount'] as num?)?.toInt(),
  pendingDocumentsCount: (json['pendingDocumentsCount'] as num?)?.toInt(),
  failedDocumentsCount: (json['failedDocumentsCount'] as num?)?.toInt(),
  sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
);

Map<String, dynamic> _$StoreModelToJson(StoreModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'createTime': instance.createTime?.toIso8601String(),
      'updateTime': instance.updateTime?.toIso8601String(),
      'activeDocumentsCount': instance.activeDocumentsCount,
      'pendingDocumentsCount': instance.pendingDocumentsCount,
      'failedDocumentsCount': instance.failedDocumentsCount,
      'sizeBytes': instance.sizeBytes,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      createTime: json['createTime'] == null
          ? null
          : DateTime.parse(json['createTime'] as String),
      updateTime: json['updateTime'] == null
          ? null
          : DateTime.parse(json['updateTime'] as String),
      state:
          $enumDecodeNullable(_$DocumentStateEnumMap, json['state']) ??
          DocumentState.unspecified,
      sizeBytes: (json['sizeBytes'] as num?)?.toInt(),
      mimeType: json['mimeType'] as String?,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'createTime': instance.createTime?.toIso8601String(),
      'updateTime': instance.updateTime?.toIso8601String(),
      'state': _$DocumentStateEnumMap[instance.state]!,
      'sizeBytes': instance.sizeBytes,
      'mimeType': instance.mimeType,
    };

const _$DocumentStateEnumMap = {
  DocumentState.unspecified: 'unspecified',
  DocumentState.pending: 'pending',
  DocumentState.active: 'active',
  DocumentState.failed: 'failed',
};

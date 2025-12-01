// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'stringify': instance.stringify,
      'hashCode': instance.hashCode,
      'name': instance.name,
      'displayName': instance.displayName,
      'createTime': instance.createTime?.toIso8601String(),
      'updateTime': instance.updateTime?.toIso8601String(),
      'state': _$DocumentStateEnumMap[instance.state]!,
      'sizeBytes': instance.sizeBytes,
      'mimeType': instance.mimeType,
      'props': instance.props,
    };

const _$DocumentStateEnumMap = {
  DocumentState.unspecified: 'unspecified',
  DocumentState.pending: 'pending',
  DocumentState.active: 'active',
  DocumentState.failed: 'failed',
};

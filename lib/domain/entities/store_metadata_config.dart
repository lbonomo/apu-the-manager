import 'package:equatable/equatable.dart';

class StoreMetadataConfig extends Equatable {
  final String storeId;
  final List<MetadataFieldConfig> fields;

  const StoreMetadataConfig({
    required this.storeId,
    required this.fields,
  });

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }

  factory StoreMetadataConfig.fromJson(Map<String, dynamic> json) {
    return StoreMetadataConfig(
      storeId: json['storeId'] as String,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => MetadataFieldConfig.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  StoreMetadataConfig copyWith({
    String? storeId,
    List<MetadataFieldConfig>? fields,
  }) {
    return StoreMetadataConfig(
      storeId: storeId ?? this.storeId,
      fields: fields ?? this.fields,
    );
  }

  @override
  List<Object?> get props => [storeId, fields];
}

class MetadataFieldConfig extends Equatable {
  final String key;
  final List<String> possibleValues;

  const MetadataFieldConfig({
    required this.key,
    this.possibleValues = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'possibleValues': possibleValues,
    };
  }

  factory MetadataFieldConfig.fromJson(Map<String, dynamic> json) {
    return MetadataFieldConfig(
      key: json['key'] as String,
      possibleValues: (json['possibleValues'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [key, possibleValues];
}

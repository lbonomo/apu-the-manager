import 'package:equatable/equatable.dart';
import 'custom_metadata.dart';

enum DocumentState { unspecified, pending, active, failed }

class Document extends Equatable {
  final String name;
  final String? displayName;
  final DateTime? createTime;
  final DateTime? updateTime;
  final DocumentState state;
  final int? sizeBytes;
  final String? mimeType;
  final List<CustomMetadata>? customMetadata;

  const Document({
    required this.name,
    this.displayName,
    this.createTime,
    this.updateTime,
    this.state = DocumentState.unspecified,
    this.sizeBytes,
    this.mimeType,
    this.customMetadata,
  });

  @override
  List<Object?> get props => [
    name,
    displayName,
    createTime,
    updateTime,
    state,
    sizeBytes,
    mimeType,
    customMetadata,
  ];
}

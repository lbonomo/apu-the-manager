import 'package:equatable/equatable.dart';

class DocumentContent extends Equatable {
  final String textPreview;
  final int byteLength;
  final bool isBinary;
  final bool isTruncated;
  final String? mimeType;
  final String? encoding;
  final String? downloadUri;

  const DocumentContent({
    required this.textPreview,
    required this.byteLength,
    this.isBinary = false,
    this.isTruncated = false,
    this.mimeType,
    this.encoding,
    this.downloadUri,
  });

  @override
  List<Object?> get props => [
    textPreview,
    byteLength,
    isBinary,
    isTruncated,
    mimeType,
    encoding,
    downloadUri,
  ];
}

import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String name;
  final String? displayName;
  final DateTime? createTime;
  final DateTime? updateTime;
  final int? activeDocumentsCount;
  final int? pendingDocumentsCount;
  final int? failedDocumentsCount;
  final int? sizeBytes;

  const Store({
    required this.name,
    this.displayName,
    this.createTime,
    this.updateTime,
    this.activeDocumentsCount,
    this.pendingDocumentsCount,
    this.failedDocumentsCount,
    this.sizeBytes,
  });

  @override
  List<Object?> get props => [
    name,
    displayName,
    createTime,
    updateTime,
    activeDocumentsCount,
    pendingDocumentsCount,
    failedDocumentsCount,
    sizeBytes,
  ];
}

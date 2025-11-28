import '../../domain/entities/document.dart';

int? stringToInt(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is String) return int.tryParse(val);
  return null;
}

DocumentState stringToDocumentState(String? val) {
  switch (val) {
    case 'STATE_ACTIVE':
      return DocumentState.active;
    case 'STATE_PENDING':
      return DocumentState.pending;
    case 'STATE_FAILED':
      return DocumentState.failed;
    default:
      return DocumentState.unspecified;
  }
}

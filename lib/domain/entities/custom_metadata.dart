import 'package:equatable/equatable.dart';

/// Representa un valor de metadata personalizado de un documento
class CustomMetadata extends Equatable {
  final String key;
  final String? stringValue;
  final double? numericValue;

  const CustomMetadata({
    required this.key,
    this.stringValue,
    this.numericValue,
  });

  /// Retorna el valor como String, independientemente de si es string o numérico
  String get displayValue {
    if (stringValue != null) return stringValue!;
    if (numericValue != null) return numericValue.toString();
    return 'N/A';
  }

  @override
  List<Object?> get props => [key, stringValue, numericValue];
}

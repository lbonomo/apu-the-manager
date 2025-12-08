import 'package:equatable/equatable.dart';

/// Representa un valor de metadata personalizado de un documento
class CustomMetadata extends Equatable {
  final String key;
  final String? stringValue;
  final double? numericValue;
  final List<String>? stringListValue;

  const CustomMetadata({
    required this.key,
    this.stringValue,
    this.numericValue,
    this.stringListValue,
  });

  /// Retorna el valor como String, independientemente de si es string, numérico o lista
  String get displayValue {
    if (stringValue != null) return stringValue!;
    if (numericValue != null) return numericValue.toString();
    if (stringListValue != null && stringListValue!.isNotEmpty) {
      return stringListValue!.join(', ');
    }
    return 'N/A';
  }

  @override
  List<Object?> get props => [key, stringValue, numericValue, stringListValue];
}

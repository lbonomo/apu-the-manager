import 'package:flutter_riverpod/flutter_riverpod.dart';

// Maneja el estado de los filtros seleccionados por storeId.
// Map<String, Set<String>>: Clave del metadato -> Conjunto de valores seleccionados.
final metadataFiltersProvider = StateProvider.family<Map<String, Set<String>>, String>((ref, storeId) {
  return {};
});

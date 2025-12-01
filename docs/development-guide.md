# Guía de Desarrollo - Apu the Manager

## Configuración Inicial

### Requisitos Previos

- Flutter SDK 3.10.0 o superior
- Dart SDK 3.0.0 o superior
- IDE: VS Code o Android Studio
- Git

### Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone <repository-url>
   cd apu-the-manager
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Generar código:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

## Configuración de la API Key

1. Ejecutar la aplicación
2. Ir a Settings (ícono de engranaje)
3. Ingresar tu Gemini API Key
4. La key se guarda localmente con `shared_preferences`

**Obtener API Key:**
- Visita: https://aistudio.google.com/apikey

## Estructura de Archivos

### Archivos Principales

```
lib/
├── main.dart                          # Entry point
├── core/
│   ├── constants/
│   │   └── env_config.dart           # Configuración (deprecado)
│   ├── errors/
│   │   └── failures.dart             # Clases de error
│   ├── services/
│   │   └── logger_service.dart       # Servicio de logging
│   └── utils/
│       └── json_converters.dart      # Conversores JSON
│
├── data/
│   ├── datasources/
│   │   └── file_search_remote_data_source.dart  # Cliente API
│   ├── models/
│   │   ├── store_model.dart          # Modelo de Store
│   │   ├── store_model.g.dart        # Generado
│   │   ├── document_model.dart       # Modelo de Document
│   │   └── document_model.g.dart     # Generado
│   └── repositories/
│       ├── file_search_repository_impl.dart     # Implementación
│       └── settings_repository_impl.dart        # Implementación
│
├── domain/
│   ├── entities/
│   │   ├── store.dart                # Entidad Store
│   │   ├── document.dart             # Entidad Document
│   │   └── paginated_result.dart     # Resultado paginado
│   └── repositories/
│       ├── file_search_repository.dart          # Interface
│       └── settings_repository.dart             # Interface
│
└── presentation/
    ├── providers/
    │   ├── core_providers.dart       # Providers core
    │   ├── store_providers.dart      # Providers de stores
    │   ├── document_providers.dart   # Providers de documents
    │   ├── settings_provider.dart    # Provider de settings
    │   └── settings_state.dart       # Estado de settings
    ├── screens/
    │   ├── stores_screen.dart        # Pantalla principal
    │   ├── store_details_screen.dart # Detalle de store
    │   ├── upload_document_screen.dart # Subida de archivos
    │   └── settings_screen.dart      # Configuración
```

## Comandos Comunes

### Code Generation

```bash
# Generar código (providers, JSON, mocks)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (regenera automáticamente)
dart run build_runner watch --delete-conflicting-outputs

# Limpiar archivos generados
dart run build_runner clean
```

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar un test específico
flutter test test/data/datasources/file_search_remote_data_source_test.dart

# Con coverage
flutter test --coverage
```

### Análisis de Código

```bash
# Analizar código
flutter analyze

# Formatear código
dart format .

# Fix automático
dart fix --apply
```

## Agregar Nuevas Funcionalidades

### 1. Agregar una Nueva Entidad

**Ejemplo: Agregar `Chunk`**

1. **Crear entidad en domain:**
   ```dart
   // lib/domain/entities/chunk.dart
   import 'package:equatable/equatable.dart';
   
   class Chunk extends Equatable {
     final String name;
     final String content;
     
     const Chunk({
       required this.name,
       required this.content,
     });
     
     @override
     List<Object?> get props => [name, content];
   }
   ```

2. **Crear modelo en data:**
   ```dart
   // lib/data/models/chunk_model.dart
   import 'package:json_annotation/json_annotation.dart';
   import '../../domain/entities/chunk.dart';
   
   part 'chunk_model.g.dart';
   
   @JsonSerializable()
   class ChunkModel extends Chunk {
     const ChunkModel({
       required String name,
       required String content,
     }) : super(name: name, content: content);
     
     factory ChunkModel.fromJson(Map<String, dynamic> json) =>
         _$ChunkModelFromJson(json);
     
     Map<String, dynamic> toJson() => _$ChunkModelToJson(this);
   }
   ```

3. **Generar código:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### 2. Agregar un Nuevo Provider

**Ejemplo: Provider para Chunks**

```dart
// lib/presentation/providers/chunk_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/chunk.dart';
import 'core_providers.dart';

part 'chunk_providers.g.dart';

@riverpod
class ChunksList extends _$ChunksList {
  @override
  Future<List<Chunk>> build(String documentId) async {
    final logger = ref.watch(loggerServiceProvider);
    logger.i('Listando chunks para documento: $documentId');
    
    final repository = ref.watch(fileSearchRepositoryProvider);
    final result = await repository.listChunks(documentId);
    
    return result.fold(
      (failure) {
        logger.e('Error: ${failure.message}');
        throw Exception(failure.message);
      },
      (chunks) {
        logger.i('${chunks.length} chunks obtenidos');
        return chunks;
      },
    );
  }
}
```

### 3. Agregar una Nueva Pantalla

**Ejemplo: Pantalla de Chunks**

```dart
// lib/presentation/screens/chunks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chunk_providers.dart';

class ChunksScreen extends ConsumerWidget {
  final String documentId;
  
  const ChunksScreen({super.key, required this.documentId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chunksAsync = ref.watch(chunksListProvider(documentId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Chunks')),
      body: chunksAsync.when(
        data: (chunks) => ListView.builder(
          itemCount: chunks.length,
          itemBuilder: (context, index) {
            final chunk = chunks[index];
            return ListTile(
              title: Text(chunk.name),
              subtitle: Text(chunk.content),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

## Debugging

### Habilitar Logging

1. Ir a Settings
2. Activar "Enable Logging"
3. Los logs aparecerán en la consola

### Logs Útiles

```dart
// En cualquier provider
final logger = ref.watch(loggerServiceProvider);

logger.d('Debug message');      // Debug
logger.i('Info message');        // Info
logger.w('Warning message');     // Warning
logger.e('Error message');       // Error
```

### DevTools

```bash
# Abrir Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## Solución de Problemas Comunes

### Error: "Build runner conflicts"

```bash
# Limpiar y regenerar
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Error: "API Key not set"

1. Verificar que la API key esté configurada en Settings
2. Revisar logs para ver si se está recuperando correctamente
3. Verificar que `shared_preferences` esté funcionando

### Error: "Type mismatch" en JSON

- Verificar que los conversores en `json_converters.dart` estén correctos
- Revisar la implementación manual de `fromJson` en los modelos
- Asegurarse de que los tipos coincidan con la API

### Error: "Provider not found"

- Verificar que el provider esté generado (`.g.dart`)
- Ejecutar `build_runner` si falta el archivo generado
- Verificar imports correctos

## Best Practices

### 1. Naming Conventions

- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`
- **Constants:** `SCREAMING_SNAKE_CASE`
- **Private:** `_prefixWithUnderscore`

### 2. Providers

```dart
// ✅ Correcto
@riverpod
class StoresList extends _$StoresList {
  @override
  Future<List<Store>> build() async { ... }
}

// ❌ Incorrecto - no usar StateNotifier directamente
class StoresListNotifier extends StateNotifier<AsyncValue<List<Store>>> {
  // ...
}
```

### 3. Error Handling

```dart
// ✅ Correcto - usar Either
final result = await repository.listStores();
return result.fold(
  (failure) => throw Exception(failure.message),
  (stores) => stores,
);

// ❌ Incorrecto - throw directo sin contexto
final stores = await repository.listStores();
return stores; // Puede lanzar error sin manejo
```

### 4. Logging

```dart
// ✅ Correcto - contexto claro
logger.i('Iniciando listado de stores...');
logger.e('Error al listar stores: ${failure.message}');

// ❌ Incorrecto - sin contexto
logger.i('Starting...');
logger.e('Error');
```

### 5. State Management

```dart
// ✅ Correcto - usar AsyncValue
final storesAsync = ref.watch(storesListProvider);
return storesAsync.when(
  data: (stores) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, _) => Text('Error: $error'),
);

// ❌ Incorrecto - no manejar estados
final stores = ref.watch(storesListProvider).value!; // Puede ser null
```

## Recursos Adicionales

### Documentación

- [Flutter](https://flutter.dev/docs)
- [Riverpod](https://riverpod.dev)
- [Gemini API](https://ai.google.dev/gemini-api/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Packages Clave

- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [riverpod_annotation](https://pub.dev/packages/riverpod_annotation)
- [dio](https://pub.dev/packages/dio)
- [fpdart](https://pub.dev/packages/fpdart)
- [freezed](https://pub.dev/packages/freezed)
- [logger](https://pub.dev/packages/logger)

## Contribuir

### Workflow

1. Crear branch desde `main`
2. Hacer cambios
3. Ejecutar tests: `flutter test`
4. Ejecutar análisis: `flutter analyze`
5. Formatear código: `dart format .`
6. Commit con mensaje descriptivo
7. Push y crear Pull Request

### Commit Messages

```
feat: agregar paginación a lista de documentos
fix: corregir error de tipo en StoreModel
docs: actualizar README con instrucciones
refactor: mejorar manejo de errores en providers
test: agregar tests para DocumentsList
```

## Changelog

Ver [CHANGELOG.md](../CHANGELOG.md) para historial de cambios.

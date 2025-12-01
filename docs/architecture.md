# Arquitectura de la Aplicación

## Visión General

**Apu the Manager** es una aplicación Flutter para gestionar FileSearchStores y Documents de la API de Gemini. Implementa Clean Architecture con separación clara de responsabilidades.

## Estructura del Proyecto

```
lib/
├── core/                       # Funcionalidades compartidas
│   ├── constants/             # Constantes y configuración
│   ├── errors/                # Manejo de errores y failures
│   ├── services/              # Servicios core (logging)
│   └── utils/                 # Utilidades (conversores JSON)
│
├── data/                      # Capa de datos
│   ├── datasources/          # Fuentes de datos remotas
│   ├── models/               # Modelos de datos (DTOs)
│   └── repositories/         # Implementaciones de repositorios
│
├── domain/                    # Capa de dominio
│   ├── entities/             # Entidades de negocio
│   └── repositories/         # Interfaces de repositorios
│
└── presentation/              # Capa de presentación
    ├── providers/            # Providers de Riverpod
    └── screens/              # Pantallas de la UI

test/
├── data/                     # Tests de la capa de datos
├── domain/                   # Tests de la capa de dominio
└── helpers/                  # Helpers para testing (mocks)
```

## Capas de la Arquitectura

### 1. Domain Layer (Dominio)

**Responsabilidad:** Define las reglas de negocio y entidades core.

**Componentes:**
- **Entities:** Objetos de negocio puros sin dependencias externas
  - `Store`: Representa un FileSearchStore
  - `Document`: Representa un documento
  - `PaginatedResult<T>`: Resultado paginado genérico

- **Repository Interfaces:** Contratos para acceso a datos
  - `FileSearchRepository`: Operaciones CRUD para stores y documents
  - `SettingsRepository`: Gestión de configuración

**Principios:**
- Sin dependencias de frameworks externos
- Entidades inmutables usando `Equatable`
- Interfaces puras (contratos)

### 2. Data Layer (Datos)

**Responsabilidad:** Implementa el acceso a datos y mapeo de modelos.

**Componentes:**
- **DataSources:** Comunicación con APIs externas
  - `FileSearchRemoteDataSource`: Cliente HTTP para Gemini API
  - Usa `Dio` para peticiones HTTP
  - Maneja autenticación con API key

- **Models:** DTOs que extienden entidades
  - `StoreModel extends Store`: Serialización JSON
  - `DocumentModel extends Document`: Serialización JSON
  - Conversión manual de tipos (String → int)

- **Repository Implementations:** Implementan interfaces del dominio
  - `FileSearchRepositoryImpl`: Mapea entre modelos y entidades
  - `SettingsRepositoryImpl`: Usa `shared_preferences`
  - Retorna `Either<Failure, T>` usando `fpdart`

**Patrones:**
- Repository Pattern
- DTO Pattern
- Either para manejo de errores

### 3. Presentation Layer (Presentación)

**Responsabilidad:** UI y gestión de estado.

**Componentes:**
- **Providers (Riverpod):**
  - `StoresList`: Estado de la lista de stores
  - `DocumentsList`: Estado paginado de documentos
  - `SettingsProvider`: Configuración de la app
  - Providers core: Dio, repositories, logger

- **Screens:**
  - `StoresScreen`: Lista de FileSearchStores
  - `StoreDetailsScreen`: Documentos de un store (con paginación)
  - `UploadDocumentScreen`: Subida de archivos
  - `SettingsScreen`: Configuración (API key, logging)

**Estado:**
- `AsyncValue<T>` para operaciones asíncronas
- `PaginatedResult<T>` para listas paginadas
- Notifiers para mutaciones de estado

### 4. Core Layer

**Responsabilidad:** Funcionalidades compartidas entre capas.

**Componentes:**
- **Services:**
  - `LoggerService`: Logging configurable con `logger` package
  - Inyectado vía Riverpod

- **Errors:**
  - `Failure`: Clase base para errores
  - `ServerFailure`: Errores de red/API

- **Utils:**
  - `stringToInt()`: Conversión segura String → int
  - `stringToDocumentState()`: Conversión de enums

## Gestión de Estado

### Riverpod + Code Generation

**Providers principales:**

```dart
// Core providers
@Riverpod(keepAlive: true)
Dio dio(Ref ref) => Dio();

@Riverpod(keepAlive: true)
LoggerService loggerService(Ref ref) => LoggerServiceImpl();

// Feature providers
@riverpod
class StoresList extends _$StoresList {
  Future<List<Store>> build() async { ... }
  Future<void> refresh() async { ... }
  Future<void> createStore(String name) async { ... }
  Future<void> deleteStore(String id) async { ... }
}

@riverpod
class DocumentsList extends _$DocumentsList {
  Future<PaginatedResult<Document>> build(String storeId) async { ... }
  Future<void> refresh() async { ... }
  Future<void> loadMore() async { ... }
  Future<void> uploadDocument(File file) async { ... }
  Future<void> deleteDocument(String id) async { ... }
}
```

**Ventajas:**
- Type-safe
- Auto-dispose
- Caching automático
- Invalidación reactiva

## Paginación

### Implementación

1. **Entity:** `PaginatedResult<T>`
   ```dart
   class PaginatedResult<T> {
     final List<T> items;
     final String? nextPageToken;
   }
   ```

2. **DataSource:** Parámetros `pageSize` y `pageToken`
   ```dart
   Future<PaginatedResult<DocumentModel>> listDocuments(
     String storeId, {
     int pageSize = 20,
     String? pageToken,
   });
   ```

3. **Provider:** Método `loadMore()`
   ```dart
   Future<void> loadMore() async {
     final current = state.value;
     if (current?.nextPageToken == null) return;
     
     final newBatch = await repository.listDocuments(
       storeId,
       pageToken: current.nextPageToken,
     );
     
     state = AsyncValue.data(PaginatedResult(
       items: [...current.items, ...newBatch.items],
       nextPageToken: newBatch.nextPageToken,
     ));
   }
   ```

4. **UI:** Botón "Load More"
   ```dart
   if (index == documents.length) {
     return ElevatedButton(
       onPressed: () => ref.read(provider.notifier).loadMore(),
       child: Text('Load More'),
     );
   }
   ```

## Logging

### Sistema Configurable

**Implementación:**
- `LoggerService` con implementación `LoggerServiceImpl`
- Usa package `logger` con configuración personalizada
- Estado persistido en `shared_preferences`

**Uso:**
```dart
final logger = ref.watch(loggerServiceProvider);
logger.i('Iniciando operación...');
logger.e('Error: $message');
```

**Configuración:**
- Toggle en `SettingsScreen`
- Logs en consola durante desarrollo
- Desactivable en producción

## Manejo de Errores

### Either Pattern

```dart
// Repository retorna Either
Future<Either<Failure, List<Store>>> listStores();

// Provider maneja ambos casos
final result = await repository.listStores();
return result.fold(
  (failure) => throw Exception(failure.message),
  (stores) => stores,
);
```

### Tipos de Errores

- `ServerFailure`: Errores de API/red
- `CacheFailure`: Errores de almacenamiento local
- Excepciones específicas según contexto

## Configuración

### Settings Management

**Almacenamiento:**
- `shared_preferences` para persistencia
- `SettingsState` con `freezed` para inmutabilidad

**Configuraciones:**
- `loggingEnabled`: Toggle de logging
- `geminiApiKey`: API key de Gemini

**Acceso:**
```dart
final settings = ref.watch(settingsProvider);
if (settings.loggingEnabled) {
  logger.i('Log message');
}
```

## Testing

### Estrategia

1. **Unit Tests:**
   - Repositories
   - DataSources
   - Conversores

2. **Mocks:**
   - Generados con `mockito`
   - `@GenerateMocks` en `test_helper.dart`

3. **Fixtures:**
   - JSON de ejemplo para tests
   - Datos de prueba consistentes

**Ejemplo:**
```dart
test('listStores returns stores on success', () async {
  when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
    .thenAnswer((_) async => Response(data: mockData));
  
  final result = await dataSource.listStores();
  
  expect(result, isA<List<StoreModel>>());
});
```

## Dependencias Clave

### Producción
- `flutter_riverpod`: State management
- `riverpod_annotation`: Code generation
- `dio`: HTTP client
- `fpdart`: Functional programming (Either)
- `equatable`: Value equality
- `logger`: Logging
- `shared_preferences`: Local storage
- `freezed`: Immutable models

### Desarrollo
- `riverpod_generator`: Provider code gen
- `build_runner`: Code generation
- `mockito`: Mocking
- `json_serializable`: JSON serialization

## Flujo de Datos

```
UI (Screen)
    ↓ watch/read
Provider (Riverpod)
    ↓ calls
Repository Interface (Domain)
    ↓ implements
Repository Impl (Data)
    ↓ uses
DataSource
    ↓ HTTP
Gemini API
```

## Mejores Prácticas

1. **Separación de Responsabilidades:**
   - Cada capa tiene un propósito claro
   - Sin dependencias circulares
   - Domain independiente de frameworks

2. **Inmutabilidad:**
   - Entities con `Equatable`
   - State con `freezed`
   - Providers con `AsyncValue`

3. **Type Safety:**
   - Generics para reutilización
   - Either para errores
   - Null safety habilitado

4. **Code Generation:**
   - Riverpod providers
   - JSON serialization
   - Freezed models
   - Mocks para testing

5. **Logging:**
   - Logs en operaciones críticas
   - Contexto claro en mensajes
   - Configurable por usuario

## Próximos Pasos

### Mejoras Pendientes

1. **CustomMetadata:**
   - Agregar soporte en `DocumentModel`
   - UI para visualizar/editar metadatos

2. **Error Handling:**
   - Mensajes de error más específicos
   - Retry logic para operaciones fallidas

3. **Offline Support:**
   - Cache local de stores/documents
   - Sincronización en background

4. **Testing:**
   - Widget tests
   - Integration tests
   - Coverage > 80%

5. **UI/UX:**
   - Loading states más granulares
   - Pull-to-refresh
   - Infinite scroll automático
   - Búsqueda y filtros

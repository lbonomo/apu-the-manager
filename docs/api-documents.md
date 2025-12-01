# API de Documents - Gemini API

## Recurso: Document

Un `Document` es una colección de elementos `Chunk` dentro de un FileSearchStore.

### Representación JSON

```json
{
  "name": string,
  "displayName": string,
  "customMetadata": [
    {
      "key": string,
      "stringValue": string,
      "stringListValue": {
        "values": [string]
      },
      "numericValue": number
    }
  ],
  "updateTime": string,
  "createTime": string,
  "state": enum (State),
  "sizeBytes": string,
  "mimeType": string
}
```

### Campos

- **name** (string): Inmutable. Identificador del recurso. Formato: `fileSearchStores/{file_search_store_id}/documents/{document_id}`
  - El ID puede contener hasta 40 caracteres alfanuméricos en minúscula o guiones (-)
  - No puede comenzar ni terminar con un guion
  - Si está vacío en la creación, se genera automáticamente desde displayName con un sufijo aleatorio de 12 caracteres

- **displayName** (string, opcional): Nombre visible y legible por humanos (máximo 512 caracteres)

- **customMetadata** (array, opcional): Metadatos personalizados como pares clave-valor para consultas
  - Máximo 20 CustomMetadata por Document
  - Cada elemento puede tener:
    - `key` (string): Clave del metadato
    - `stringValue` (string): Valor de cadena
    - `stringListValue` (object): Lista de valores de cadena
    - `numericValue` (number): Valor numérico

- **createTime** (string, Timestamp): Solo salida. Marca de tiempo de creación (formato RFC 3339)

- **updateTime** (string, Timestamp): Solo salida. Marca de tiempo de última actualización (formato RFC 3339)

- **state** (enum State): Solo salida. Estado actual del documento
  - `STATE_UNSPECIFIED`: Estado no especificado
  - `STATE_PENDING`: Los Chunks están siendo procesados
  - `STATE_ACTIVE`: Los Chunks están listos para consultas
  - `STATE_FAILED`: El procesamiento de Chunks falló

- **sizeBytes** (string, int64): Solo salida. Tamaño en bytes del documento

- **mimeType** (string): Solo salida. Tipo MIME del documento

## Métodos

### list

Lista todos los documentos de un FileSearchStore.

**Endpoint:**
```
GET https://generativelanguage.googleapis.com/v1beta/{parent=fileSearchStores/*}/documents
```

**Parámetros de ruta:**
- `parent` (string, obligatorio): Nombre del FileSearchStore. Formato: `fileSearchStores/{filesearchstore}`

**Parámetros de consulta:**
- `pageSize` (integer, opcional): Cantidad máxima de documentos a devolver por página
  - Por defecto: 10
  - Máximo: 20

- `pageToken` (string, opcional): Token de página recibido de una llamada anterior
  - Proporciona el `nextPageToken` de la respuesta anterior para recuperar la siguiente página
  - Todos los demás parámetros deben coincidir con la llamada que proporcionó el token

**Respuesta:**
```json
{
  "documents": [
    {
      "name": string,
      "displayName": string,
      ...
    }
  ],
  "nextPageToken": string
}
```

Los documentos se ordenan por `createTime` en orden ascendente.

### get

Obtiene un documento específico.

**Endpoint:**
```
GET https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*/documents/*}
```

**Parámetros de ruta:**
- `name` (string, obligatorio): Nombre del documento. Formato: `fileSearchStores/{filesearchstore}/documents/{document}`

**Respuesta:**
Retorna el objeto Document.

### delete

Elimina un documento.

**Endpoint:**
```
DELETE https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*/documents/*}
```

**Parámetros de ruta:**
- `name` (string, obligatorio): Nombre del documento a eliminar

**Parámetros de consulta:**
- `force` (boolean, opcional): Por defecto `false`. Cuando es `true`, elimina de forma cascada todos los chunks del documento antes de borrarlo. Si se omite o es `false`, la operación falla con `FAILED_PRECONDITION` si aún existen chunks activos.

### uploadToFileSearchStore

Sube un archivo y crea un documento en el FileSearchStore.

**Endpoint:**
```
POST https://generativelanguage.googleapis.com/upload/v1beta/{fileSearchStoreName=fileSearchStores/*}:uploadToFileSearchStore
```

**Headers:**
- `X-Goog-Upload-Protocol: multipart`

**Cuerpo de la solicitud:**
Multipart/form-data con:
- `metadata`: JSON con `displayName` y opcionalmente `customMetadata`
- `file`: Archivo binario

**Respuesta:**
Retorna una Operation. Si `done` es true, el campo `response` contiene el Document creado.

## Estados del Documento

| Estado | Descripción |
|--------|-------------|
| `STATE_UNSPECIFIED` | Estado no especificado |
| `STATE_PENDING` | Los Chunks del documento están siendo procesados |
| `STATE_ACTIVE` | Los Chunks están listos y el documento puede ser consultado |
| `STATE_FAILED` | El procesamiento de Chunks falló |

## Notas de Implementación

### Paginación
- El tamaño de página por defecto es 10 documentos
- El máximo permitido es 20 documentos por página
- Usar `nextPageToken` para navegar entre páginas
- Mantener los mismos parámetros de consulta al paginar

### Subida de Archivos
- La subida puede retornar una Operation de larga duración
- Verificar el campo `done` en la respuesta
- Si `done` es false, hacer polling del endpoint de la operación
- El documento estará en estado `STATE_PENDING` durante el procesamiento

## Recurso: Chunk

Los `Chunk` representan las unidades indexables derivadas de un documento.

### Representación JSON

```json
{
  "name": string,
  "displayName": string,
  "state": enum (State),
  "createTime": string,
  "updateTime": string,
  "sizeBytes": string,
  "chunkMetadata": [
    {
      "key": string,
      "stringValue": string,
      "stringListValue": {
        "values": [string]
      },
      "numericValue": number
    }
  ]
}
```

### Campos

- **name** (string): Solo salida. Identificador completo del chunk. Formato: `fileSearchStores/{store}/documents/{document}/chunks/{chunk}`
- **displayName** (string, opcional): Alias legible del fragmento, útil para depuración o UI
- **state** (enum State): Estado del procesamiento del chunk (`STATE_PENDING`, `STATE_ACTIVE`, `STATE_FAILED`)
- **createTime** y **updateTime** (string, Timestamp): Marcas de tiempo de creación y última actualización en formato RFC 3339
- **sizeBytes** (string, int64): Tamaño del fragmento. Solo salida
- **chunkMetadata** (array, opcional): Metadatos personalizados asociados al fragmento

## Métodos de Chunk

### listChunks

Lista los chunks de un documento.

**Endpoint:**
```
GET https://generativelanguage.googleapis.com/v1beta/{parent=fileSearchStores/*/documents/*}/chunks
```

**Parámetros de ruta:**
- `parent` (string, obligatorio): Documento que contiene los chunks

**Parámetros de consulta:**
- `pageSize` (integer, opcional): Tamaño de página. Por defecto 10, máximo 20
- `pageToken` (string, opcional): Token para paginación

**Respuesta:**
```json
{
  "chunks": [ Chunk ],
  "nextPageToken": string
}
```

### getChunk

Obtiene un chunk específico de un documento.

**Endpoint:**
```
GET https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*/documents/*/chunks/*}
```

**Parámetros de ruta:**
- `name` (string, obligatorio): Identificador completo del chunk

### deleteChunk

Elimina un chunk.

**Endpoint:**
```
DELETE https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*/documents/*/chunks/*}
```

**Parámetros de ruta:**
- `name` (string, obligatorio): Chunk a eliminar

**Parámetros de consulta:**
- `force` (boolean, opcional): Permite forzar la eliminación mientras el chunk está en procesamiento. Por defecto `false`

## Configuración de chunking

Al subir documentos puedes suministrar un `ChunkingConfig` para personalizar cómo se generan los chunks.

### ChunkingConfig

```json
{
  "whiteSpaceConfig": {
    "maxTokensPerChunk": integer,
    "maxOverlapTokens": integer
  }
}
```

- **whiteSpaceConfig**: Usa un algoritmo delimitado por espacios en blanco.
  - `maxTokensPerChunk` (int32): Máximo de palabras por chunk. El servicio impone un tope conservador de 512 palabras (~2560 tokens) para evitar sobrepasar la ventana de contexto.
  - `maxOverlapTokens` (int32): Cantidad máxima de tokens que se comparten entre chunks consecutivos.

Si no proporcionas una configuración explícita, el servicio utiliza valores predeterminados que equilibran cobertura y costos de indexación.

## Referencias

- [Documentación oficial de Documents](https://ai.google.dev/api/file-search/documents?hl=es-419)
- [Guía de File Search](https://ai.google.dev/gemini-api/docs/file-search?hl=es-419)

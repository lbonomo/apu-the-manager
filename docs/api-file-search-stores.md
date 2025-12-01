# API de File Search Stores - Gemini API

## Recurso: FileSearchStore

Un `FileSearchStore` es un contenedor de documentos que se pueden usar para búsqueda semántica.

### Representación JSON

```json
{
  "name": string,
  "displayName": string,
  "createTime": string,
  "updateTime": string,
  "activeDocumentsCount": string,
  "pendingDocumentsCount": string,
  "failedDocumentsCount": string,
  "sizeBytes": string
}
```

### Campos

- **name** (string): Inmutable. Identificador del recurso. Formato: `fileSearchStores/{filesearchstore}`
- **displayName** (string): Opcional. Nombre visible y legible por humanos del FileSearchStore (máximo 512 caracteres)
- **createTime** (string, Timestamp): Solo salida. Marca de tiempo de creación
- **updateTime** (string, Timestamp): Solo salida. Marca de tiempo de última actualización
- **activeDocumentsCount** (string, int64): Solo salida. Cantidad de documentos activos
- **pendingDocumentsCount** (string, int64): Solo salida. Cantidad de documentos pendientes
- **failedDocumentsCount** (string, int64): Solo salida. Cantidad de documentos fallidos
- **sizeBytes** (string, int64): Solo salida. Tamaño total en bytes

## Métodos

### list

Lista todos los FileSearchStores.

**Endpoint:**
```
GET https://generativelanguage.googleapis.com/v1beta/fileSearchStores
```

**Parámetros de consulta:**
- `pageSize` (integer, opcional): Cantidad máxima de stores a devolver (máximo 20, por defecto 10)
- `pageToken` (string, opcional): Token de página para recuperar la siguiente página

**Respuesta:**
```json
{
  "fileSearchStores": [
    {
      "name": string,
      "displayName": string,
      ...
    }
  ],
  "nextPageToken": string
}
```

### create

Crea un nuevo FileSearchStore.

**Endpoint:**
```
POST https://generativelanguage.googleapis.com/v1beta/fileSearchStores
```

**Cuerpo de la solicitud:**
```json
{
  "displayName": string
}
```

**Respuesta:**
Retorna el objeto FileSearchStore creado.

### delete

Elimina un FileSearchStore.

**Endpoint:**
```
DELETE https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*}
```

**Parámetros de ruta:**
- `name` (string, obligatorio): Nombre del recurso a eliminar

**Parámetros de consulta:**
- `force` (boolean, opcional): Controla la eliminación en cascada. Por defecto es `false`.
  - Si `false`, la solicitud falla con `FAILED_PRECONDITION` cuando el FileSearchStore aún contiene documentos o chunks pendientes.
  - Si `true`, elimina de forma sincrónica todos los documentos y chunks asociados antes de borrar el store.

### Consideraciones de eliminación

- La eliminación no es reversible y libera de inmediato cualquier contenido indexado.
- La operación es síncrona: cuando la solicitud responde con éxito, no quedan documentos ni chunks asociados al store.
- Usa `force` únicamente cuando quieras evitar el paso manual de vaciar el store; de lo contrario, elimina los documentos de manera explícita para tener control fino sobre los contenidos.

## Referencias

- [Documentación oficial de File Search Stores](https://ai.google.dev/api/file-search/stores?hl=es-419)
- [Guía de inicio rápido](https://ai.google.dev/gemini-api/docs?hl=es-419)

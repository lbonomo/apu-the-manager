import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/errors/failures.dart';
import '../models/store_model.dart';
import '../models/document_model.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/entities/paginated_result.dart';
import '../../domain/entities/document_content.dart';
import '../../core/services/logger_service.dart';

abstract class FileSearchRemoteDataSource {
  Future<List<StoreModel>> listStores();
  Future<StoreModel> createStore(String displayName);
  Future<void> deleteStore(String storeId);
  Future<PaginatedResult<DocumentModel>> listDocuments(
    String storeId, {
    int pageSize = 20,
    String? pageToken,
  });
  Future<DocumentModel> uploadDocument(
    String storeId,
    File file, {
    String? displayName,
  });
  Future<void> deleteDocument(String storeId, String documentId);
  Future<DocumentContent> getDocumentContent(
    String documentName, {
    String? mimeType,
  });
}

class FileSearchRemoteDataSourceImpl implements FileSearchRemoteDataSource {
  final Dio dio;
  final SettingsRepository settingsRepository;
  final LoggerService logger;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  FileSearchRemoteDataSourceImpl({
    required this.dio,
    required this.settingsRepository,
    required this.logger,
  });

  Future<String> get _apiKey async {
    final key = await settingsRepository.getGeminiApiKey();
    if (key == null || key.isEmpty) {
      throw Exception(
        'Gemini API Key not set. Please configure it in Settings.',
      );
    }
    return key;
  }

  @override
  Future<List<StoreModel>> listStores() async {
    try {
      final key = await _apiKey;
      logger.i('Listing stores...');
      final response = await dio.get(
        '$_baseUrl/fileSearchStores',
        queryParameters: {'key': key},
      );

      if (response.statusCode == 200) {
        final List<dynamic> storesJson =
            response.data['fileSearchStores'] ?? [];
        return storesJson.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw ServerFailure('Failed to list stores: ${response.statusCode}');
      }
    } on DioException catch (e) {
      logger.e('DioException in listStores', e);
      logger.d('Response data: ${e.response?.data}');
      // Extract detailed error message if available
      String errorMessage = e.message ?? 'Unknown Dio error';
      if (e.response?.data is Map &&
          (e.response?.data as Map).containsKey('error')) {
        final errorMap = e.response?.data['error'];
        if (errorMap is Map) {
          errorMessage =
              '${errorMap['message']} (Status: ${errorMap['status']})';
        } else {
          errorMessage = errorMap.toString();
        }
      }

      throw ServerFailure(
        'Failed to list stores: ${e.response?.statusCode} - $errorMessage',
      );
    } catch (e) {
      logger.e('Error in listStores', e);
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<StoreModel> createStore(String displayName) async {
    try {
      final key = await _apiKey;
      final response = await dio.post(
        '$_baseUrl/fileSearchStores',
        queryParameters: {'key': key},
        data: {'displayName': displayName},
      );

      if (response.statusCode == 200) {
        return StoreModel.fromJson(response.data);
      } else {
        throw ServerFailure('Failed to create store: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteStore(String storeId) async {
    try {
      // storeId should be the full resource name e.g. fileSearchStores/xyz
      // If the user passes just the ID, we might need to handle it, but let's assume full name or handle it in repo.
      // The API expects the resource name in the URL.
      // If storeId is just the ID, we need to prepend 'fileSearchStores/'.
      // But the Store model returns the full name in 'name' field.

      final key = await _apiKey;
      final response = await dio.delete(
        '$_baseUrl/$storeId',
        queryParameters: {'key': key},
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to delete store: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<PaginatedResult<DocumentModel>> listDocuments(
    String storeId, {
    int pageSize = 20,
    String? pageToken,
  }) async {
    try {
      final key = await _apiKey;
      final queryParams = {'key': key, 'pageSize': pageSize};
      if (pageToken != null) {
        queryParams['pageToken'] = pageToken;
      }

      final response = await dio.get(
        '$_baseUrl/$storeId/documents',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List<dynamic> docsJson = response.data['documents'] ?? [];
        final documents = docsJson
            .map((json) => DocumentModel.fromJson(json))
            .toList();
        final nextPageToken = response.data['nextPageToken'] as String?;
        return PaginatedResult(items: documents, nextPageToken: nextPageToken);
      } else {
        throw ServerFailure('Failed to list documents: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<DocumentModel> uploadDocument(
    String storeId,
    File file, {
    String? displayName,
  }) async {
    try {
      // Uploading a file involves two steps usually with Google APIs:
      // 1. Upload the file bytes to get a File resource (media upload).
      // 2. Or use the specific uploadToFileSearchStore method.
      // The docs say: POST https://generativelanguage.googleapis.com/upload/v1beta/{fileSearchStoreName=fileSearchStores/*}:uploadToFileSearchStore

      final uploadUrl =
          'https://generativelanguage.googleapis.com/upload/v1beta/$storeId:uploadToFileSearchStore';

      // We need to send the file content.
      // The documentation mentions "media.uploadToFileSearchStore".
      // Usually this requires a multipart request or a raw body with headers.
      // Let's try multipart/related or simple upload if supported.
      // The docs say "The request body contains data with the following structure: displayName, customMetadata...".
      // But it also says "Upload URI for media upload requests".

      // For simplicity with Dio, we can try sending the file as bytes.
      // However, the Google AI API often uses a specific protocol for uploads.
      // Let's look at the "uploadToFileSearchStore" documentation again.
      // It says "POST .../upload/v1beta/...:uploadToFileSearchStore".
      // And "The request body contains data...".
      // This usually implies a multipart request where one part is the metadata and another is the file.
      // OR it's a resumable upload protocol.

      // Let's assume a simple multipart upload for now, or check if there's a simpler "importFile" method.
      // There is `fileSearchStores.importFile` which imports a `File` from File Service.
      // So maybe we first upload to File Service (media.upload) and then import?
      // But `uploadToFileSearchStore` seems to do it directly.

      // Let's try to implement `uploadToFileSearchStore` using Dio.
      // We need to set the X-Goog-Upload-Protocol header if we use the resumable upload, but maybe simple upload works.
      // Actually, for `uploadToFileSearchStore`, it seems we might need to send metadata + file.

      // Let's try a standard multipart upload.

      String fileName = displayName ?? basename(file.path);

      // We need to construct the metadata JSON.

      FormData formData = FormData.fromMap({
        'metadata': MultipartFile.fromString(
          '{"displayName": "$fileName"}',
          contentType: MediaType.parse('application/json'),
        ),
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Note: The Google AI API upload might be tricky.
      // Often it requires:
      // 1. Initial request to get an upload URL.
      // 2. Upload bytes.
      // OR a multipart/related request.

      // Let's try the standard `upload` endpoint pattern for Google APIs.
      // POST /upload/v1beta/...
      // Headers: X-Goog-Upload-Protocol: multipart

      final key = await _apiKey;
      final response = await dio.post(
        uploadUrl,
        queryParameters: {'key': key},
        data: formData,
        options: Options(headers: {'X-Goog-Upload-Protocol': 'multipart'}),
      );

      if (response.statusCode == 200) {
        // The response contains a "response" field which is the Document?
        // Or it returns an Operation?
        // The docs say it returns an Operation.
        // We might need to poll the operation.
        // But for small files, maybe it's done?

        // Let's check the response structure from docs:
        // { "name": ..., "done": ..., "response": { "@type": ..., ... } }

        final data = response.data;
        if (data['done'] == true) {
          if (data.containsKey('response')) {
            // The response field contains the Document, but it might be wrapped or typed.
            // Actually, the `response` field in Operation is an Any type.
            // We might need to parse it.
            // Let's assume for now we return a DocumentModel from the response data if possible.
            // Or we might need to fetch the document again.

            // If it returns an Operation, we should probably return the Operation or poll it.
            // For this MVP, let's assume we just return the Document if available, or throw if it's a long running op that we don't handle yet.
            // But wait, the user wants "Upload a document".

            // If it returns an Operation, we can't immediately return a DocumentModel unless we poll.
            // Let's implement a simple polling mechanism here or just return the operation result if it's done.

            // If `done` is true, `response` holds the result.
            // The result should be the Document.
            return DocumentModel.fromJson(data['response']);
          } else if (data.containsKey('error')) {
            throw ServerFailure('Upload failed: ${data['error']}');
          }
        }

        // If not done, we should poll.
        // For simplicity, let's throw saying it's processing.
        // Or better, implement polling.
        String operationName = data['name'];
        return await _pollOperation(operationName);
      } else {
        throw ServerFailure(
          'Failed to upload document: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  Future<DocumentModel> _pollOperation(String operationName) async {
    int attempts = 0;
    while (attempts < 10) {
      await Future.delayed(Duration(seconds: 2));
      final key = await _apiKey;
      final response = await dio.get(
        '$_baseUrl/$operationName',
        queryParameters: {'key': key},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['done'] == true) {
          if (data.containsKey('error')) {
            throw ServerFailure('Upload failed: ${data['error']}');
          }
          return DocumentModel.fromJson(data['response']);
        }
      }
      attempts++;
    }
    throw ServerFailure('Upload timed out');
  }

  @override
  Future<void> deleteDocument(String storeId, String documentId) async {
    try {
      // According to the API docs, the endpoint is:
      // DELETE https://generativelanguage.googleapis.com/v1beta/{name=fileSearchStores/*/documents/*}
      // where {name} is the full resource name

      String resourceName;

      // If documentId already contains the full path, use it as is
      if (documentId.contains('/documents/')) {
        resourceName = documentId;
      }
      // If it's just the document ID, construct the full path
      else {
        resourceName = '$storeId/documents/$documentId';
      }

      logger.i('Deleting document with resource name: $resourceName');

      final key = await _apiKey;

      Future<void> performDelete() async {
        // The resource name should be used directly in the URL path
        final url = '$_baseUrl/$resourceName';
        logger.d('DELETE URL: $url');

        final response = await dio.delete(
          url,
          queryParameters: {
            'key': key,
            'force':
                true, // See https://ai.google.dev/api/file-search/documents#method:-filesearchstores.documents.delete
          },
        );

        logger.d('Delete response status: ${response.statusCode}');

        if (response.statusCode != 200 && response.statusCode != 204) {
          throw ServerFailure(
            'Failed to delete document: ${response.statusCode}',
          );
        }
      }

      try {
        await performDelete();
        return;
      } on DioException catch (e) {
        logger.w('DioException details:', e);
        logger.d('  Status code: ${e.response?.statusCode}');
        logger.d('  Response data: ${e.response?.data}');
        logger.d('  Request URL: ${e.requestOptions.uri}');

        if (_isNonEmptyDocumentError(e)) {
          logger.i(
            'Document has remaining chunks. Attempting to remove chunks before retrying delete.',
          );
          await _deleteDocumentChunks(resourceName, key);

          // Small delay to let the backend finalize chunk removals
          await Future.delayed(const Duration(milliseconds: 300));

          try {
            await performDelete();
            return;
          } on DioException catch (retryError) {
            logger.w('DioException on retry:', retryError);
            logger.d('  Status code: ${retryError.response?.statusCode}');
            logger.d('  Response data: ${retryError.response?.data}');
            logger.d('  Request URL: ${retryError.requestOptions.uri}');

            if (_isNonEmptyDocumentError(retryError)) {
              throw ServerFailure(
                'Cannot delete document even after removing all chunks. '
                'Please try again later as the Gemini API may still be processing the deletions.',
              );
            }

            throw ServerFailure(retryError.toString());
          }
        }

        throw ServerFailure(e.toString());
      }
    } on ServerFailure {
      rethrow;
    } catch (e) {
      logger.e('Delete error', e);
      throw ServerFailure(e.toString());
    }
  }

  Future<void> _deleteDocumentChunks(
    String documentResourceName,
    String apiKey,
  ) async {
    String? pageToken;

    do {
      final queryParams = <String, dynamic>{'key': apiKey};
      if (pageToken != null && pageToken.isNotEmpty) {
        queryParams['pageToken'] = pageToken;
      }

      Response<dynamic> response;
      try {
        response = await dio.get(
          '$_baseUrl/$documentResourceName/chunks',
          queryParameters: queryParams,
        );
      } on DioException catch (chunkListError) {
        if (chunkListError.response?.statusCode == 404) {
          logger.d(
            'Document has no recorded chunks or the chunks endpoint is unavailable (404). '
            'Assuming there are no remaining chunks.',
          );
          return;
        }

        throw ServerFailure(
          'Failed to list document chunks: '
          '${chunkListError.response?.statusCode ?? chunkListError.message}',
        );
      }

      if (response.statusCode != 200) {
        throw ServerFailure(
          'Failed to list document chunks: ${response.statusCode}',
        );
      }

      final data = response.data;
      final chunks = data is Map && data['chunks'] is List
          ? List<dynamic>.from(data['chunks'] as List)
          : const <dynamic>[];

      for (final dynamic chunk in chunks) {
        if (chunk is! Map<String, dynamic>) {
          continue;
        }

        final chunkName = chunk['name'] as String?;
        if (chunkName == null || chunkName.isEmpty) {
          continue;
        }

        logger.d('Deleting chunk: $chunkName');

        try {
          final chunkResponse = await dio.delete(
            '$_baseUrl/$chunkName',
            queryParameters: {'key': apiKey},
          );

          logger.d(
            'Delete chunk response status ($chunkName): ${chunkResponse.statusCode}',
          );
        } on DioException catch (chunkError) {
          if (chunkError.response?.statusCode == 404) {
            logger.d('Chunk already deleted (404): $chunkName');
            continue;
          }

          throw ServerFailure(
            'Failed to delete chunk $chunkName: '
            '${chunkError.response?.statusCode ?? chunkError.message}',
          );
        }
      }

      pageToken = data is Map ? data['nextPageToken'] as String? : null;
    } while (pageToken != null && pageToken.isNotEmpty);
  }

  bool _isNonEmptyDocumentError(DioException exception) {
    if (exception.response?.statusCode != 400) {
      return false;
    }

    final data = exception.response?.data;
    String? message;
    String? status;

    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        status = error['status'] as String?;
        message = error['message'] as String?;
      }
    }

    message ??= exception.message;

    final normalizedMessage = message?.toLowerCase() ?? '';

    if (status == 'FAILED_PRECONDITION') {
      return true;
    }

    return normalizedMessage.contains('cannot delete non-empty') ||
        normalizedMessage.contains('contains chunks');
  }

  @override
  Future<DocumentContent> getDocumentContent(
    String documentName, {
    String? mimeType,
  }) async {
    var effectiveMimeType = mimeType;
    final key = await _apiKey;
    Map<String, dynamic>? documentData;
    try {
      final response = await dio.get(
        '$_baseUrl/$documentName',
        queryParameters: {'key': key},
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        documentData = Map<String, dynamic>.from(response.data as Map);
        effectiveMimeType ??= documentData['mimeType'] as String?;
      }
    } catch (_) {
      // Ignore errors when fetching document metadata; fall back to file endpoint.
    }

    final downloadUri = _resolveDownloadUri(documentData);
    final effectiveDownloadUri = await _ensureDownloadUri(
      downloadUri,
      documentName,
      key,
    );

    if (effectiveDownloadUri == null) {
      final buffer = StringBuffer()
        ..writeln('No se pudo obtener un enlace de descarga para:')
        ..writeln(documentName)
        ..writeln()
        ..writeln(
          'Esto suele ocurrir cuando el documento se creó a partir de una carga directa '
          'y el servicio aún no ha materializado un recurso `File` descargable.',
        )
        ..writeln(
          'Intenta esperar unos segundos y vuelve a abrir el documento, o revisa en Google AI Studio '
          'que el archivo asociado siga disponible.',
        );

      return DocumentContent(
        textPreview: buffer.toString().trimRight(),
        byteLength: 0,
        mimeType: effectiveMimeType,
        isBinary: false,
        isTruncated: false,
      );
    }

    final uri = Uri.parse(effectiveDownloadUri);
    final uriWithKey = uri.queryParameters.containsKey('key')
        ? uri
        : uri.replace(queryParameters: {...uri.queryParameters, 'key': key});

    late final Response<dynamic> contentResponse;
    try {
      contentResponse = await dio.getUri(
        uriWithKey,
        options: Options(responseType: ResponseType.bytes),
      );
    } on DioException catch (e) {
      throw ServerFailure(
        'Failed to download document content: '
        '${e.response?.statusCode ?? e.message}',
      );
    }

    if (contentResponse.statusCode != 200) {
      throw ServerFailure(
        'Failed to download document content: ${contentResponse.statusCode}',
      );
    }

    final rawData = contentResponse.data;
    final bytes = _normalizeBytes(rawData);
    if (bytes == null) {
      final asString = rawData?.toString() ?? '';
      return DocumentContent(
        textPreview: asString,
        byteLength: asString.codeUnits.length,
        mimeType: mimeType,
        downloadUri: uriWithKey.toString(),
      );
    }

    effectiveMimeType ??= documentData?['mimeType'] as String?;
    final isTextual =
        _isTextMime(effectiveMimeType) && !_containsBinaryBytes(bytes);

    if (!isTextual) {
      final message = StringBuffer()
        ..writeln('El archivo no es texto legible y no se puede previsualizar.')
        ..writeln('Tamaño: ${bytes.length} bytes')
        ..writeln('Tipo MIME: ${mimeType ?? 'desconocido'}');

      return DocumentContent(
        textPreview: message.toString().trim(),
        byteLength: bytes.length,
        mimeType: effectiveMimeType,
        isBinary: true,
        downloadUri: uriWithKey.toString(),
      );
    }

    _lastDetectedEncoding = null;
    final decoded = _decodeBytes(bytes);
    final encodingUsed = _lastDetectedEncoding;

    if (encodingUsed == 'binary') {
      final truncatedBinary = decoded.length > _maxPreviewCharacters;
      final previewBinary = truncatedBinary
          ? decoded.substring(0, _maxPreviewCharacters)
          : decoded;

      final message = StringBuffer()
        ..writeln(
          'El contenido no pudo decodificarse como texto legible. '
          'Se muestra una representación base64 parcial.',
        )
        ..writeln()
        ..write(previewBinary);
      if (truncatedBinary) {
        message.write('\n... (truncado)');
      }

      return DocumentContent(
        textPreview: message.toString(),
        byteLength: bytes.length,
        mimeType: effectiveMimeType,
        encoding: encodingUsed,
        isBinary: true,
        isTruncated: truncatedBinary,
        downloadUri: uriWithKey.toString(),
      );
    }

    final truncated = decoded.length > _maxPreviewCharacters;
    final preview = truncated
        ? decoded.substring(0, _maxPreviewCharacters)
        : decoded;

    return DocumentContent(
      textPreview: preview,
      byteLength: bytes.length,
      mimeType: effectiveMimeType,
      encoding: encodingUsed,
      isTruncated: truncated,
      downloadUri: uriWithKey.toString(),
    );
  }

  static const int _maxPreviewCharacters = 20000;
  String? _lastDetectedEncoding;

  String? _resolveDownloadUri(Map<String, dynamic>? documentData) {
    if (documentData == null) return null;

    final directDownload = documentData['downloadUri'];
    if (directDownload is String && directDownload.isNotEmpty) {
      return directDownload;
    }

    final derivedFiles = documentData['derivedFiles'];
    if (derivedFiles is List) {
      for (final entry in derivedFiles) {
        if (entry is Map<String, dynamic>) {
          final uri = entry['downloadUri'];
          if (uri is String && uri.isNotEmpty) {
            return uri;
          }
        }
      }
    }

    final source = documentData['sourceFileUri'];
    if (source is String && source.isNotEmpty) {
      return source;
    }

    return null;
  }

  Future<String?> _ensureDownloadUri(
    String? existingUri,
    String documentName,
    String apiKey,
  ) async {
    if (existingUri != null) {
      return existingUri;
    }

    final segments = documentName.split('/');
    final documentId = segments.isNotEmpty ? segments.last : documentName;

    try {
      final response = await dio.get(
        '$_baseUrl/files/$documentId',
        queryParameters: {'key': apiKey},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final fileDownload = data['downloadUri'];
        if (fileDownload is String && fileDownload.isNotEmpty) {
          return fileDownload;
        }
        final uri = data['uri'];
        if (uri is String && uri.isNotEmpty) {
          return uri;
        }
      }
    } catch (_) {
      // Ignore and fall through to return null.
    }

    return null;
  }

  List<int>? _normalizeBytes(dynamic rawData) {
    if (rawData == null) {
      return null;
    }

    if (rawData is List<int>) {
      return rawData;
    }

    if (rawData is Uint8List) {
      return rawData;
    }

    return null;
  }

  bool _isTextMime(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) return true;
    if (mimeType.startsWith('text/')) return true;

    const additionalTextTypes = {
      'application/json',
      'application/xml',
      'application/javascript',
      'application/x-yaml',
      'application/xhtml+xml',
    };

    return additionalTextTypes.contains(mimeType);
  }

  bool _containsBinaryBytes(List<int> bytes) {
    for (final value in bytes) {
      if (value == 0) {
        return true;
      }
    }
    return false;
  }

  String _decodeBytes(List<int> bytes) {
    try {
      _lastDetectedEncoding = 'utf8';
      return utf8.decode(bytes, allowMalformed: true);
    } on FormatException {
      try {
        _lastDetectedEncoding = 'latin1';
        return latin1.decode(bytes);
      } catch (_) {
        _lastDetectedEncoding = 'binary';
        return base64Encode(bytes);
      }
    }
  }
}

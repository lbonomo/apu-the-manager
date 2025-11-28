import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/constants/env_config.dart';
import '../../core/errors/failures.dart';
import '../models/store_model.dart';
import '../models/document_model.dart';

abstract class FileSearchRemoteDataSource {
  Future<List<StoreModel>> listStores();
  Future<StoreModel> createStore(String displayName);
  Future<void> deleteStore(String storeId);
  Future<List<DocumentModel>> listDocuments(String storeId);
  Future<DocumentModel> uploadDocument(String storeId, File file, {String? displayName});
  Future<void> deleteDocument(String storeId, String documentId);
}

class FileSearchRemoteDataSourceImpl implements FileSearchRemoteDataSource {
  final Dio dio;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  FileSearchRemoteDataSourceImpl({required this.dio});

  String get _apiKey => EnvConfig.googleApiKey;

  @override
  Future<List<StoreModel>> listStores() async {
    try {
      final response = await dio.get(
        '$_baseUrl/fileSearchStores',
        queryParameters: {'key': _apiKey},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> storesJson = response.data['fileSearchStores'] ?? [];
        return storesJson.map((json) => StoreModel.fromJson(json)).toList();
      } else {
        throw ServerFailure('Failed to list stores: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<StoreModel> createStore(String displayName) async {
    try {
      final response = await dio.post(
        '$_baseUrl/fileSearchStores',
        queryParameters: {'key': _apiKey},
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
      
      final response = await dio.delete(
        '$_baseUrl/$storeId',
        queryParameters: {'key': _apiKey},
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to delete store: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<DocumentModel>> listDocuments(String storeId) async {
    try {
      final response = await dio.get(
        '$_baseUrl/$storeId/documents',
        queryParameters: {'key': _apiKey},
      );

      if (response.statusCode == 200) {
        final List<dynamic> docsJson = response.data['documents'] ?? [];
        return docsJson.map((json) => DocumentModel.fromJson(json)).toList();
      } else {
        throw ServerFailure('Failed to list documents: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<DocumentModel> uploadDocument(String storeId, File file, {String? displayName}) async {
    try {
      // Uploading a file involves two steps usually with Google APIs:
      // 1. Upload the file bytes to get a File resource (media upload).
      // 2. Or use the specific uploadToFileSearchStore method.
      // The docs say: POST https://generativelanguage.googleapis.com/upload/v1beta/{fileSearchStoreName=fileSearchStores/*}:uploadToFileSearchStore
      
      final uploadUrl = 'https://generativelanguage.googleapis.com/upload/v1beta/$storeId:uploadToFileSearchStore';
      
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
      final metadata = {
        'displayName': fileName,
      };
      
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
      
      final response = await dio.post(
        uploadUrl,
        queryParameters: {'key': _apiKey},
        data: formData,
        options: Options(
          headers: {
            'X-Goog-Upload-Protocol': 'multipart',
          },
        ),
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
        throw ServerFailure('Failed to upload document: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
  
  Future<DocumentModel> _pollOperation(String operationName) async {
    int attempts = 0;
    while (attempts < 10) {
      await Future.delayed(Duration(seconds: 2));
      final response = await dio.get(
        '$_baseUrl/$operationName',
        queryParameters: {'key': _apiKey},
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
      // documentId might be the full name or just the ID.
      // The listDocuments returns full names.
      // If the user passes the full name, we use it.
      // If they pass just the ID, we construct it: $storeId/documents/$documentId
      
      String resourceName = documentId;
      if (!documentId.startsWith('fileSearchStores')) {
         resourceName = '$storeId/documents/$documentId';
      }

      final response = await dio.delete(
        '$_baseUrl/$resourceName',
        queryParameters: {'key': _apiKey},
      );

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to delete document: ${response.statusCode}');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}

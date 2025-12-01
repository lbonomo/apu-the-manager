// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentContentHash() => r'6b3692d72d4a0fd2dea66dfcefcd869f361065d7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [documentContent].
@ProviderFor(documentContent)
const documentContentProvider = DocumentContentFamily();

/// See also [documentContent].
class DocumentContentFamily extends Family<AsyncValue<DocumentContent>> {
  /// See also [documentContent].
  const DocumentContentFamily();

  /// See also [documentContent].
  DocumentContentProvider call(Document document) {
    return DocumentContentProvider(document);
  }

  @override
  DocumentContentProvider getProviderOverride(
    covariant DocumentContentProvider provider,
  ) {
    return call(provider.document);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentContentProvider';
}

/// See also [documentContent].
class DocumentContentProvider
    extends AutoDisposeFutureProvider<DocumentContent> {
  /// See also [documentContent].
  DocumentContentProvider(Document document)
    : this._internal(
        (ref) => documentContent(ref as DocumentContentRef, document),
        from: documentContentProvider,
        name: r'documentContentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentContentHash,
        dependencies: DocumentContentFamily._dependencies,
        allTransitiveDependencies:
            DocumentContentFamily._allTransitiveDependencies,
        document: document,
      );

  DocumentContentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.document,
  }) : super.internal();

  final Document document;

  @override
  Override overrideWith(
    FutureOr<DocumentContent> Function(DocumentContentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentContentProvider._internal(
        (ref) => create(ref as DocumentContentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        document: document,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DocumentContent> createElement() {
    return _DocumentContentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentContentProvider && other.document == document;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, document.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentContentRef on AutoDisposeFutureProviderRef<DocumentContent> {
  /// The parameter `document` of this provider.
  Document get document;
}

class _DocumentContentProviderElement
    extends AutoDisposeFutureProviderElement<DocumentContent>
    with DocumentContentRef {
  _DocumentContentProviderElement(super.provider);

  @override
  Document get document => (origin as DocumentContentProvider).document;
}

String _$documentsListHash() => r'e945ef844e0abb5d902b96bd39450ca8fd2313c0';

abstract class _$DocumentsList
    extends BuildlessAutoDisposeAsyncNotifier<PaginatedResult<Document>> {
  late final String storeId;

  FutureOr<PaginatedResult<Document>> build(String storeId);
}

/// See also [DocumentsList].
@ProviderFor(DocumentsList)
const documentsListProvider = DocumentsListFamily();

/// See also [DocumentsList].
class DocumentsListFamily
    extends Family<AsyncValue<PaginatedResult<Document>>> {
  /// See also [DocumentsList].
  const DocumentsListFamily();

  /// See also [DocumentsList].
  DocumentsListProvider call(String storeId) {
    return DocumentsListProvider(storeId);
  }

  @override
  DocumentsListProvider getProviderOverride(
    covariant DocumentsListProvider provider,
  ) {
    return call(provider.storeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentsListProvider';
}

/// See also [DocumentsList].
class DocumentsListProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          DocumentsList,
          PaginatedResult<Document>
        > {
  /// See also [DocumentsList].
  DocumentsListProvider(String storeId)
    : this._internal(
        () => DocumentsList()..storeId = storeId,
        from: documentsListProvider,
        name: r'documentsListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$documentsListHash,
        dependencies: DocumentsListFamily._dependencies,
        allTransitiveDependencies:
            DocumentsListFamily._allTransitiveDependencies,
        storeId: storeId,
      );

  DocumentsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storeId,
  }) : super.internal();

  final String storeId;

  @override
  FutureOr<PaginatedResult<Document>> runNotifierBuild(
    covariant DocumentsList notifier,
  ) {
    return notifier.build(storeId);
  }

  @override
  Override overrideWith(DocumentsList Function() create) {
    return ProviderOverride(
      origin: this,
      override: DocumentsListProvider._internal(
        () => create()..storeId = storeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storeId: storeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    DocumentsList,
    PaginatedResult<Document>
  >
  createElement() {
    return _DocumentsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsListProvider && other.storeId == storeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DocumentsListRef
    on AutoDisposeAsyncNotifierProviderRef<PaginatedResult<Document>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _DocumentsListProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          DocumentsList,
          PaginatedResult<Document>
        >
    with DocumentsListRef {
  _DocumentsListProviderElement(super.provider);

  @override
  String get storeId => (origin as DocumentsListProvider).storeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

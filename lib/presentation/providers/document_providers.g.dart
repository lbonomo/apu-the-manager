// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsListHash() => r'fe65d53f6dfc317825ba7bc1494824c6dc3a2276';

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

abstract class _$DocumentsList
    extends BuildlessAutoDisposeAsyncNotifier<List<Document>> {
  late final String storeId;

  FutureOr<List<Document>> build(String storeId);
}

/// See also [DocumentsList].
@ProviderFor(DocumentsList)
const documentsListProvider = DocumentsListFamily();

/// See also [DocumentsList].
class DocumentsListFamily extends Family<AsyncValue<List<Document>>> {
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
        AutoDisposeAsyncNotifierProviderImpl<DocumentsList, List<Document>> {
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
  FutureOr<List<Document>> runNotifierBuild(covariant DocumentsList notifier) {
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
  AutoDisposeAsyncNotifierProviderElement<DocumentsList, List<Document>>
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
mixin DocumentsListRef on AutoDisposeAsyncNotifierProviderRef<List<Document>> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _DocumentsListProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<DocumentsList, List<Document>>
    with DocumentsListRef {
  _DocumentsListProviderElement(super.provider);

  @override
  String get storeId => (origin as DocumentsListProvider).storeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

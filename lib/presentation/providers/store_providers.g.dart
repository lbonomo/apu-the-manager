// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storeByIdHash() => r'7b9093ad99175dd6b66c268e3fdf0262365aec7e';

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

/// Provider para obtener un Store por su ID
///
/// Copied from [storeById].
@ProviderFor(storeById)
const storeByIdProvider = StoreByIdFamily();

/// Provider para obtener un Store por su ID
///
/// Copied from [storeById].
class StoreByIdFamily extends Family<AsyncValue<Store?>> {
  /// Provider para obtener un Store por su ID
  ///
  /// Copied from [storeById].
  const StoreByIdFamily();

  /// Provider para obtener un Store por su ID
  ///
  /// Copied from [storeById].
  StoreByIdProvider call(String storeId) {
    return StoreByIdProvider(storeId);
  }

  @override
  StoreByIdProvider getProviderOverride(covariant StoreByIdProvider provider) {
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
  String? get name => r'storeByIdProvider';
}

/// Provider para obtener un Store por su ID
///
/// Copied from [storeById].
class StoreByIdProvider extends AutoDisposeFutureProvider<Store?> {
  /// Provider para obtener un Store por su ID
  ///
  /// Copied from [storeById].
  StoreByIdProvider(String storeId)
    : this._internal(
        (ref) => storeById(ref as StoreByIdRef, storeId),
        from: storeByIdProvider,
        name: r'storeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$storeByIdHash,
        dependencies: StoreByIdFamily._dependencies,
        allTransitiveDependencies: StoreByIdFamily._allTransitiveDependencies,
        storeId: storeId,
      );

  StoreByIdProvider._internal(
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
  Override overrideWith(
    FutureOr<Store?> Function(StoreByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StoreByIdProvider._internal(
        (ref) => create(ref as StoreByIdRef),
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
  AutoDisposeFutureProviderElement<Store?> createElement() {
    return _StoreByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StoreByIdProvider && other.storeId == storeId;
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
mixin StoreByIdRef on AutoDisposeFutureProviderRef<Store?> {
  /// The parameter `storeId` of this provider.
  String get storeId;
}

class _StoreByIdProviderElement extends AutoDisposeFutureProviderElement<Store?>
    with StoreByIdRef {
  _StoreByIdProviderElement(super.provider);

  @override
  String get storeId => (origin as StoreByIdProvider).storeId;
}

String _$storesListHash() => r'c82be80b926f80213738b80975cc3ba8084e163d';

/// See also [StoresList].
@ProviderFor(StoresList)
final storesListProvider =
    AutoDisposeAsyncNotifierProvider<StoresList, List<Store>>.internal(
      StoresList.new,
      name: r'storesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StoresList = AutoDisposeAsyncNotifier<List<Store>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

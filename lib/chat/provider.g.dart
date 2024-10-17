// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentHash() => r'90292360eb3264273fc7a2b479f81a5809e607f8';

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

/// See also [attachment].
@ProviderFor(attachment)
const attachmentProvider = AttachmentFamily();

/// See also [attachment].
class AttachmentFamily extends Family<AsyncValue<Uint8List>> {
  /// See also [attachment].
  const AttachmentFamily();

  /// See also [attachment].
  AttachmentProvider call(
    String url,
  ) {
    return AttachmentProvider(
      url,
    );
  }

  @override
  AttachmentProvider getProviderOverride(
    covariant AttachmentProvider provider,
  ) {
    return call(
      provider.url,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'attachmentProvider';
}

/// See also [attachment].
class AttachmentProvider extends AutoDisposeFutureProvider<Uint8List> {
  /// See also [attachment].
  AttachmentProvider(
    String url,
  ) : this._internal(
          (ref) => attachment(
            ref as AttachmentRef,
            url,
          ),
          from: attachmentProvider,
          name: r'attachmentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$attachmentHash,
          dependencies: AttachmentFamily._dependencies,
          allTransitiveDependencies:
              AttachmentFamily._allTransitiveDependencies,
          url: url,
        );

  AttachmentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
  }) : super.internal();

  final String url;

  @override
  Override overrideWith(
    FutureOr<Uint8List> Function(AttachmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttachmentProvider._internal(
        (ref) => create(ref as AttachmentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Uint8List> createElement() {
    return _AttachmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttachmentProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AttachmentRef on AutoDisposeFutureProviderRef<Uint8List> {
  /// The parameter `url` of this provider.
  String get url;
}

class _AttachmentProviderElement
    extends AutoDisposeFutureProviderElement<Uint8List> with AttachmentRef {
  _AttachmentProviderElement(super.provider);

  @override
  String get url => (origin as AttachmentProvider).url;
}

String _$messagesRepositoryHash() =>
    r'c422c469476470bf591e91dfa749bc1b2aa98657';

/// See also [MessagesRepository].
@ProviderFor(MessagesRepository)
final messagesRepositoryProvider =
    AutoDisposeNotifierProvider<MessagesRepository, List<MessageData>>.internal(
  MessagesRepository.new,
  name: r'messagesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messagesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessagesRepository = AutoDisposeNotifier<List<MessageData>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

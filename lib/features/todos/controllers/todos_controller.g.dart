// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completedTodoCountHash() =>
    r'85a2f120a9e85cebf760706167c0069aaeaf76be';

/// See also [completedTodoCount].
@ProviderFor(completedTodoCount)
final completedTodoCountProvider = AutoDisposeProvider<int>.internal(
  completedTodoCount,
  name: r'completedTodoCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedTodoCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedTodoCountRef = AutoDisposeProviderRef<int>;
String _$todoByIdHash() => r'b52072c829c02a1c2cd4886d0b798a1865d6fade';

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

/// See also [todoById].
@ProviderFor(todoById)
const todoByIdProvider = TodoByIdFamily();

/// See also [todoById].
class TodoByIdFamily extends Family<Todo?> {
  /// See also [todoById].
  const TodoByIdFamily();

  /// See also [todoById].
  TodoByIdProvider call(
    String id,
  ) {
    return TodoByIdProvider(
      id,
    );
  }

  @override
  TodoByIdProvider getProviderOverride(
    covariant TodoByIdProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'todoByIdProvider';
}

/// See also [todoById].
class TodoByIdProvider extends AutoDisposeProvider<Todo?> {
  /// See also [todoById].
  TodoByIdProvider(
    String id,
  ) : this._internal(
          (ref) => todoById(
            ref as TodoByIdRef,
            id,
          ),
          from: todoByIdProvider,
          name: r'todoByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$todoByIdHash,
          dependencies: TodoByIdFamily._dependencies,
          allTransitiveDependencies: TodoByIdFamily._allTransitiveDependencies,
          id: id,
        );

  TodoByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Todo? Function(TodoByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TodoByIdProvider._internal(
        (ref) => create(ref as TodoByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Todo?> createElement() {
    return _TodoByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TodoByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TodoByIdRef on AutoDisposeProviderRef<Todo?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TodoByIdProviderElement extends AutoDisposeProviderElement<Todo?>
    with TodoByIdRef {
  _TodoByIdProviderElement(super.provider);

  @override
  String get id => (origin as TodoByIdProvider).id;
}

String _$todosControllerHash() => r'9998a2c89d408ca33d4325cadce99b72aa3111f4';

/// See also [TodosController].
@ProviderFor(TodosController)
final todosControllerProvider =
    AsyncNotifierProvider<TodosController, List<Todo>>.internal(
  TodosController.new,
  name: r'todosControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todosControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodosController = AsyncNotifier<List<Todo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package

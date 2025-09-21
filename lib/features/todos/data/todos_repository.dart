import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/key_value_store.dart';
import '../domain/todo.dart';
import 'todos_api_client.dart';

part 'todos_repository.g.dart';

class TodosRepository {
  const TodosRepository(this._apiClient, this._store);

  final TodosApiClient _apiClient;
  final KeyValueStore _store;

  static const _storageKey = 'todos.v1';

  Future<List<Todo>> loadTodos() async {
    final cached = await _readFromCache();
    if (cached.isNotEmpty) {
      return cached;
    }

    final remote = await _apiClient.fetchTodos();
    if (remote.isNotEmpty) {
      await saveTodos(remote);
      return remote;
    }

    final seeded = _seedTodos();
    await saveTodos(seeded);
    return seeded;
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final json = jsonEncode(todos.map((todo) => todo.toJson()).toList());
    await _store.writeString(_storageKey, json);
  }

  Future<List<Todo>> _readFromCache() async {
    final raw = await _store.readString(_storageKey);
    if (raw == null) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (dynamic item) => Todo.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList();
    } on FormatException {
      return [];
    }
  }

  Future<void> clear() async {
    await _store.remove(_storageKey);
  }

  List<Todo> _seedTodos() {
    return <Todo>[
      Todo(
        id: 'panic-1',
        title: '호흡 연습 5분 하기',
        description: '과호흡을 느낄 때 사용할 수 있는 호흡 루틴을 점검해요.',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Todo(
        id: 'panic-2',
        title: '오늘 일기 한 줄 쓰기',
        description: '지금의 감정과 상황을 한 줄로 정리해 보세요.',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Todo(
        id: 'panic-3',
        title: '산책 10분',
        description: '실내 공기가 답답하다면 가볍게 움직여 봐요.',
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}

@Riverpod(keepAlive: true)
TodosRepository todosRepository(TodosRepositoryRef ref) {
  final apiClient = ref.watch(todosApiClientProvider);
  final store = ref.watch(keyValueStoreProvider);
  return TodosRepository(apiClient, store);
}

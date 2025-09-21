import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/todos_repository.dart';
import '../domain/todo.dart';

part 'todos_controller.g.dart';

TodosRepository _readRepository(Ref ref) => ref.read(todosRepositoryProvider);

@Riverpod(keepAlive: true)
class TodosController extends _$TodosController {
  @override
  FutureOr<List<Todo>> build() async {
    final repository = ref.watch(todosRepositoryProvider);
    return repository.loadTodos();
  }

  Future<void> addTodo({required String title, String description = ''}) async {
    if (title.trim().isEmpty) {
      return;
    }

    final current = _currentTodos();
    final todo = Todo.create(
      id: 'todo-${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
    );

    final updated = [...current, todo];
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Future<void> toggleTodo(String id) async {
    final current = _currentTodos();
    final index = current.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      return;
    }

    final updated = [...current];
    final target = updated[index];
    updated[index] = target.copyWith(isCompleted: !target.isCompleted);
    state = AsyncValue.data(updated);
    await _persist(updated);
  }

  Todo? findById(String id) {
    final todos = state.asData?.value;
    if (todos == null) {
      return null;
    }
    for (final todo in todos) {
      if (todo.id == id) {
        return todo;
      }
    }
    return null;
  }

  List<Todo> _currentTodos() {
    return state.maybeWhen(data: (value) => value, orElse: () => <Todo>[]);
  }

  Future<void> _persist(List<Todo> todos) async {
    final repository = _readRepository(ref);
    await repository.saveTodos(todos);
  }
}

@riverpod
int completedTodoCount(CompletedTodoCountRef ref) {
  final todos = ref.watch(todosControllerProvider);
  return todos.maybeWhen(
    data: (items) => items.where((todo) => todo.isCompleted).length,
    orElse: () => 0,
  );
}

@riverpod
Todo? todoById(TodoByIdRef ref, String id) {
  final todos = ref.watch(todosControllerProvider);
  return todos.maybeWhen(
    data: (items) {
      for (final todo in items) {
        if (todo.id == id) {
          return todo;
        }
      }
      return null;
    },
    orElse: () => null,
  );
}

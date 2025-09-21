import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/todos_controller.dart';

class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({super.key, required this.todoId});

  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(todosControllerProvider);
    final todo = ref.watch(todoByIdProvider(todoId));

    return Scaffold(
      appBar: AppBar(title: const Text('할 일 상세')),
      body: todosState.when(
        data: (todos) {
          if (todo == null) {
            return const _MissingTodoView();
          }

          final theme = Theme.of(context);
          final createdAtLabel = todo.createdAt
              .toLocal()
              .toString()
              .split('.')
              .first;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      todo.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: todo.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        todo.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  todo.description.isEmpty ? '설명이 없어요.' : todo.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  '생성 시각: $createdAtLabel',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(todosControllerProvider.notifier)
                      .toggleTodo(todo.id),
                  icon: Icon(todo.isCompleted ? Icons.refresh : Icons.check),
                  label: Text(todo.isCompleted ? '미완료로 되돌리기' : '완료 처리'),
                ),
              ],
            ),
          );
        },
        error: (error, stackTrace) => _TodosDetailErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(todosControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _MissingTodoView extends StatelessWidget {
  const _MissingTodoView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.search_off, size: 64),
          SizedBox(height: 12),
          Text('할 일을 찾을 수 없어요.'),
        ],
      ),
    );
  }
}

class _TodosDetailErrorView extends StatelessWidget {
  const _TodosDetailErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('상세 정보를 불러오지 못했어요.\n$message', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}

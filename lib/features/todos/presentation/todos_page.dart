import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/todos_controller.dart';
import 'add_todo_dialog.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(todosControllerProvider);
    final completedCount = ref.watch(completedTodoCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(todosControllerProvider),
            tooltip: '새로고침',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                '완료한 할 일: $completedCount개',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: todosState.when(
                data: (todos) {
                  if (todos.isEmpty) {
                    return const _EmptyTodosView();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: CheckboxListTile(
                          value: todo.isCompleted,
                          onChanged: (_) => ref
                              .read(todosControllerProvider.notifier)
                              .toggleTodo(todo.id),
                          title: Text(todo.title),
                          subtitle: Text(
                            todo.description.isEmpty
                                ? '상세 내용을 추가해 보세요.'
                                : todo.description,
                          ),
                          secondary: IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: '상세 보기',
                            onPressed: () => context.push('/todos/${todo.id}'),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemCount: todos.length,
                  );
                },
                error: (error, stackTrace) => _TodosErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(todosControllerProvider),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showAddTodoDialog(context);
          if (result != null) {
            await ref
                .read(todosControllerProvider.notifier)
                .addTodo(title: result.title, description: result.description);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('할 일 추가'),
      ),
    );
  }
}

class _EmptyTodosView extends StatelessWidget {
  const _EmptyTodosView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('오늘 할 일을 모두 완료했어요!'),
          const SizedBox(height: 4),
          const Text(
            '새로운 할 일을 추가해 보세요.',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TodosErrorView extends StatelessWidget {
  const _TodosErrorView({required this.message, required this.onRetry});

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
          Text('문제가 발생했어요.\n$message', textAlign: TextAlign.center),
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

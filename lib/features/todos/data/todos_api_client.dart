import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/todo.dart';

part 'todos_api_client.g.dart';

class TodosApiClient {
  TodosApiClient(this._dio);

  final Dio _dio;

  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await _dio.get<List<dynamic>>('/todos');
      final data = response.data;
      if (data == null) {
        return [];
      }
      return data
          .map(
            (dynamic item) => Todo.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          )
          .toList();
    } on DioException {
      return [];
    }
  }
}

@Riverpod(keepAlive: true)
TodosApiClient todosApiClient(TodosApiClientRef ref) {
  final dio = ref.watch(dioProvider);
  return TodosApiClient(dio);
}

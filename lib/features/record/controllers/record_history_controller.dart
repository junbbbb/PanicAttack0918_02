import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/record_repository.dart';
import '../domain/panic_record.dart';

part 'record_history_controller.g.dart';

@Riverpod(keepAlive: true)
class RecordHistoryController extends _$RecordHistoryController {
  @override
  FutureOr<List<PanicRecord>> build() async {
    final repository = ref.watch(recordRepositoryProvider);
    return repository.loadRecords();
  }

  Future<void> refresh() async {
    final repository = ref.read(recordRepositoryProvider);
    final records = await repository.loadRecords();
    state = AsyncValue.data(records);
  }

  Future<void> addRecord(PanicRecord record) async {
    final current = _currentRecords();
    final updated = [record, ...current];
    state = AsyncValue.data(updated);
    final repository = ref.read(recordRepositoryProvider);
    await repository.saveRecords(updated);
  }

  List<PanicRecord> _currentRecords() {
    return state.maybeWhen(
      data: (items) => items,
      orElse: () => const <PanicRecord>[],
    );
  }
}

import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/key_value_store.dart';
import '../domain/panic_record.dart';

part 'record_repository.g.dart';

const _recordsStorageKey = 'panic_records_v1';

class RecordRepository {
  RecordRepository(this._store);

  final KeyValueStore _store;

  Future<List<PanicRecord>> loadRecords() async {
    final raw = await _store.readString(_recordsStorageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((entry) => PanicRecord.fromJson(entry as Map<String, dynamic>))
          .toList();
    } catch (error) {
      // 데이터 파싱 실패 시 기존 데이터를 제거해 일관성 유지
      await _store.remove(_recordsStorageKey);
      return const [];
    }
  }

  Future<void> saveRecords(List<PanicRecord> records) async {
    final payload = jsonEncode(
      records.map((record) => record.toJson()).toList(),
    );
    await _store.writeString(_recordsStorageKey, payload);
  }

  Future<void> appendRecord(PanicRecord record) async {
    final current = await loadRecords();
    final updated = [record, ...current];
    await saveRecords(updated);
  }
}

@riverpod
RecordRepository recordRepository(RecordRepositoryRef ref) {
  final store = ref.watch(keyValueStoreProvider);
  return RecordRepository(store);
}

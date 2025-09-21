import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class KeyValueStore {
  Future<void> writeString(String key, String value);
  Future<String?> readString(String key);
  Future<void> remove(String key);
}

final keyValueStoreProvider = Provider<KeyValueStore>((ref) {
  throw UnimplementedError('KeyValueStore provider가 초기화되지 않았습니다.');
});

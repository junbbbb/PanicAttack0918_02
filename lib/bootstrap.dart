import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/storage/key_value_store.dart';
import 'core/storage/shared_preferences_store.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    setUrlStrategy(const HashUrlStrategy());
  }

  final sharedPreferences = await SharedPreferences.getInstance();
  final keyValueStore = SharedPreferencesKeyValueStore(sharedPreferences);

  runApp(
    ProviderScope(
      overrides: [keyValueStoreProvider.overrideWithValue(keyValueStore)],
      child: const PanicAttackApp(),
    ),
  );
}

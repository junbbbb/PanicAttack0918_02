import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class PanicAttackApp extends ConsumerWidget {
  const PanicAttackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    final baseScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    final colorScheme = baseScheme.copyWith(
      surface: Colors.white,
      background: Colors.white,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '패닉어택0918',
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: Colors.white,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

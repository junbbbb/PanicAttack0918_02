import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/analysis/presentation/analysis_page.dart';
import '../features/breathing/presentation/breathing_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/record/presentation/record_page.dart';
import '../features/settings/presentation/settings_page.dart';
import 'shell_scaffold.dart';

part 'router.g.dart';

enum AppRoute { home, breathing, record, analysis, profile, settings }

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _analysisNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'analysis');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'breathing',
                    name: AppRoute.breathing.name,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const BreathingPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _analysisNavigatorKey,
            routes: [
              GoRoute(
                path: '/analysis',
                name: AppRoute.analysis.name,
                builder: (context, state) => const AnalysisPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: AppRoute.settings.name,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/record',
        name: AppRoute.record.name,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecordPage(),
      ),
    ],
  );
}

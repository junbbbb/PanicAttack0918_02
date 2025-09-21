import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: const [
          NavigationDestination(
            icon: _NavIcon(baseName: 'home'),
            selectedIcon: _NavIcon(
              baseName: 'home',
              isSelected: true,
            ),
            label: '홈',
          ),
          NavigationDestination(
            icon: _NavIcon(baseName: 'record'),
            selectedIcon: _NavIcon(
              baseName: 'record',
              isSelected: true,
            ),
            label: '기록',
          ),
          NavigationDestination(
            icon: _NavIcon(baseName: 'analyis'),
            selectedIcon: _NavIcon(
              baseName: 'analyis',
              isSelected: true,
            ),
            label: '분석',
          ),
          NavigationDestination(
            icon: _NavIcon(baseName: 'profile'),
            selectedIcon: _NavIcon(
              baseName: 'profile',
              isSelected: true,
            ),
            label: '프로필',
          ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            context.pushNamed(AppRoute.record.name);
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.baseName, this.isSelected = false});

  final String baseName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final suffix = isSelected ? '_s' : '';
    final assetPath = 'assets/icons/navigation/${baseName}${suffix}.svg';

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
    );
  }
}

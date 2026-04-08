import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_detail_screen.dart';
import '../features/history/presentation/history_list_screen.dart';
import '../features/audience/presentation/audience_home_screen.dart';
import '../features/audience/presentation/interview_screen.dart';
import '../features/ai_settings/presentation/ai_settings_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/audience/domain/audience_roles.dart';
import '../features/audience/domain/personalities.dart';
import '../features/training/presentation/training_detail_screen.dart';
import '../features/training/presentation/training_list_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/tracking/presentation/result_screen.dart';
import '../features/tracking/presentation/tracking_screen.dart';
import 'shell/home_page.dart';
import 'shell/main_shell.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    // 底部导航 Tab（5 个分支）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryListScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/audience',
              builder: (context, state) => const AudienceHomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen()),
        ]),
      ],
    ),

    // 独立全屏页（无底部导航）— 250ms 快速过渡
    GoRoute(
      path: '/tracking',
      pageBuilder: (context, state) =>
          _fastTransition(state, const TrackingScreen()),
    ),
    GoRoute(
      path: '/tracking/result/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fastTransition(state, ResultScreen(sessionId: id));
      },
    ),
    GoRoute(
      path: '/history/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fastTransition(state, HistoryDetailScreen(sessionId: id));
      },
    ),
    GoRoute(
      path: '/ai-settings',
      pageBuilder: (context, state) =>
          _fastTransition(state, const AiSettingsScreen()),
    ),
    GoRoute(
      path: '/training',
      pageBuilder: (context, state) =>
          _fastTransition(state, const TrainingListScreen()),
    ),
    GoRoute(
      path: '/training/:id',
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return _fastTransition(state, TrainingDetailScreen(planId: id));
      },
    ),
    GoRoute(
      path: '/audience/interview',
      pageBuilder: (context, state) {
        final sessionId = int.tryParse(
            state.uri.queryParameters['sessionId'] ?? '');
        final roleName = state.uri.queryParameters['role'];
        final personalityName = state.uri.queryParameters['personality'];
        final role = AudienceRole.values
            .where((item) => item.name == roleName)
            .firstOrNull;
        final personality = Personality.values
            .where((item) => item.name == personalityName)
            .firstOrNull;
        if (sessionId == null || role == null || personality == null) {
          return _fastTransition(state, const AudienceHomeScreen());
        }
        return _fastTransition(
          state,
          InterviewScreen(
            sessionId: sessionId,
            role: role,
            personality: personality,
          ),
        );
      },
    ),
  ],
);

/// 250ms 快速 slide-from-right 过渡
CustomTransitionPage<void> _fastTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween =
          Tween(begin: const Offset(1, 0), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
  );
}

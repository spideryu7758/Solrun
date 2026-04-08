import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/locale_provider.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'app/theme_provider.dart';
import 'data/daos/training_dao.dart';
import 'data/providers.dart';
import 'features/tracking/data/checkpoint_service.dart';
import 'features/tracking/data/foreground_task_service.dart';
import 'l10n/app_localizations.dart';
import 'shared/services/update_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化前台服务通信端口 + 服务配置
  ForegroundTaskService.init();

  // 运动中页面锁定竖屏（全局默认竖屏）
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: SolrunApp()));
}

class SolrunApp extends ConsumerStatefulWidget {
  const SolrunApp({super.key});

  @override
  ConsumerState<SolrunApp> createState() => _SolrunAppState();
}

class _SolrunAppState extends ConsumerState<SolrunApp> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 种子内置训练计划（复用 provider 单例，避免多连接导致 database is locked）
    try {
      final db = ref.read(databaseProvider);
      final trainingDao = TrainingDao(db);
      await trainingDao.seedBuiltInPlans();
    } catch (e) {
      debugPrint('[Solrun] 种子训练计划初始化失败，跳过: $e');
    }

    try {
      await _checkCrashRecovery();
    } catch (e) {
      debugPrint('[Solrun] 崩溃恢复检查失败，跳过: $e');
    }

    // 延迟 2 秒后静默检查更新（不阻塞启动）
    Future.delayed(const Duration(seconds: 2), () {
      final ctx = router.routerDelegate.navigatorKey.currentContext;
      if (ctx != null && mounted) {
        UpdateChecker.check(ctx);
      }
    });
  }

  /// 启动时检测是否有未完成的检查点
  Future<void> _checkCrashRecovery() async {
    final checkpointService = CheckpointService();
    final hasCheckpoint = await checkpointService.hasCheckpoint();
    if (!hasCheckpoint || !mounted) return;

    final meta = await checkpointService.readMeta();
    if (meta == null || !mounted) return;

    final distKm = (meta.distanceMeters / 1000).toStringAsFixed(2);
    final durMin = meta.durationSeconds ~/ 60;
    final durSec = meta.durationSeconds % 60;
    final durStr = '$durMin:${durSec.toString().padLeft(2, '0')}';

    // 延迟显示弹窗，等路由初始化完成
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final navigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    final action = await showDialog<String>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: SolrunColors.darkCard,
        title: Text(S.of(ctx)!.main_crashRecoveryTitle, style: const TextStyle(color: SolrunColors.darkText)),
        content: Text(
          S.of(ctx)!.main_crashRecoveryContent(distKm, durStr),
          style: TextStyle(color: SolrunColors.darkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('discard'),
            child: Text(S.of(ctx)!.main_discard, style: TextStyle(color: SolrunColors.danger)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('recover'),
            child: Text(S.of(ctx)!.main_recover, style: const TextStyle(color: SolrunColors.accent)),
          ),
        ],
      ),
    );

    if (action == 'recover') {
      // TODO: 恢复到运动中页面（从检查点重建状态）
      // 当前阶段先跳转到 /tracking，后续完善恢复逻辑
      router.go('/tracking');
    } else {
      // 放弃：以 incomplete 状态保存（session 在 startRun 时已创建，DB 中已存在）
      await checkpointService.deleteCheckpoint();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Solrun',
      debugShowCheckedModeBanner: false,
      theme: SolrunTheme.light(),
      darkTheme: SolrunTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      locale: locale,
    );
  }
}

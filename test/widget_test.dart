import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:run_pure/app/router.dart';
import 'package:run_pure/app/theme.dart';
import 'package:run_pure/data/database.dart';
import 'package:run_pure/data/providers.dart';
import 'package:run_pure/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App 启动并展示底部导航', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(() async {
      await db.close();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          title: 'Solrun',
          theme: SolrunTheme.light(),
          darkTheme: SolrunTheme.dark(),
          themeMode: ThemeMode.dark,
          routerConfig: router,
          locale: const Locale('zh'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.supportedLocales,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('历史'), findsOneWidget);
    expect(find.text('统计'), findsOneWidget);
    expect(find.text('观众'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class ScentMatchApp extends ConsumerWidget {
  const ScentMatchApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
        title: 'ScentMatch',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.create(Brightness.light),
        darkTheme: AppTheme.create(Brightness.dark),
        themeMode: settings.dark ? ThemeMode.dark : ThemeMode.light,
        locale: Locale(settings.locale),
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: ref.watch(routerProvider));
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/services/hive_service.dart';
import 'core/services/currency_service.dart';
import 'core/theme/app_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'providers/theme_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'screens/shell/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141928),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await HiveService.init();
  await CurrencyService.init(); // loads cached rates, refreshes in background

  final themeProvider = ThemeProvider();
  final currencyProvider = CurrencyProvider();
  final localeProvider = LocaleProvider();
  final transactionProvider = TransactionProvider();
  final budgetProvider = BudgetProvider();

  await Future.wait([
    themeProvider.init(),
    currencyProvider.init(),
    localeProvider.init(),
    transactionProvider.init(),
    budgetProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: transactionProvider),
        ChangeNotifierProvider.value(value: budgetProvider),
      ],
      child: const DataFlowApp(),
    ),
  );
}

class DataFlowApp extends StatelessWidget {
  const DataFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: 'DataFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,

      // ── Localisation ──────────────────────────────────────────────────────
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── RTL for Arabic ────────────────────────────────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      home: const AppShell(),
    );
  }
}

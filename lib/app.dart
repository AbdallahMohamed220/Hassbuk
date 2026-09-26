import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

class HassbukApp extends StatefulWidget {
  const HassbukApp({super.key});

  @override
  State<HassbukApp> createState() => _AppState();
}

class _AppState extends State<HassbukApp> {
  final settings = EvaluationSettings();
  AppLanguage language = AppLanguage.ar;
  ThemeMode themeMode = ThemeMode.light;
  late final Future<void> settingsReady;
  late final Future<QuranRepository> repository = QuranRepository.load();

  @override
  void initState() {
    super.initState();
    settingsReady = settings.load();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = language == AppLanguage.ar;
    return MaterialApp(
      title: 'Hassbuk',
      debugShowCheckedModeBanner: false,
      locale: Locale(isArabic ? 'ar' : 'en'),
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(brightness: Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: FutureBuilder<void>(
        future: settingsReady,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return FutureBuilder<QuranRepository>(
            future: repository,
            builder: (context, repositorySnapshot) {
              if (!repositorySnapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return HomeScreen(
                settings: settings,
                repository: repositorySnapshot.data!,
                language: language,
                onLanguageChanged: (value) => setState(() => language = value),
                isDarkMode: themeMode == ThemeMode.dark,
                onThemeChanged: (isDark) => setState(
                  () => themeMode = isDark ? ThemeMode.dark : ThemeMode.light,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

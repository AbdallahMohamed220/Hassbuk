import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';
import 'settings_sheet.dart';
import 'setup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.repository,
    required this.language,
    required this.onLanguageChanged,
    required this.isDarkMode,
    required this.onThemeChanged,
  });
  final EvaluationSettings settings;
  final QuranRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(language);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _Brand(),
                      // TextButton(
                      //   onPressed: () => onLanguageChanged(
                      //     language == AppLanguage.ar
                      //         ? AppLanguage.en
                      //         : AppLanguage.ar,
                      //   ),
                      //   child: Text(strings.languageToggle),
                      // ),
                      IconButton(
                        onPressed: () => onThemeChanged(!isDarkMode),
                        tooltip: isDarkMode
                            ? strings.lightMode
                            : strings.darkMode,
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 54),
                  Text(
                    strings.subtitle,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.homeDescription,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 36),
                  FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SetupScreen(
                          settings: settings,
                          repository: repository,
                          language: language,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(strings.startReview),
                    style: primaryButton,
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          SettingsSheet(settings: settings, language: language),
                    ),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(strings.settings),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 58),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: colors.primary,
                          size: 19,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            strings.offline,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 60,
        height: 60,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Image.asset('assets/images/app_icon.png', fit: BoxFit.cover),
        ),
      ),
      SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hassbuk',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          Text(
            'حسبك',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ],
  );
}

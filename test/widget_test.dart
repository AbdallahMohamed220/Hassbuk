import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassbuk/models.dart';
import 'package:hassbuk/screens/home_screen.dart';
import 'package:hassbuk/screens/review_screen.dart';
import 'package:hassbuk/theme.dart';

void main() {
  testWidgets('shows the Hassbuk home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: HomeScreen(
            settings: EvaluationSettings(),
            repository: QuranRepository([]),
            language: AppLanguage.ar,
            onLanguageChanged: _ignoreLanguageChange,
            isDarkMode: false,
            onThemeChanged: _ignoreThemeChange,
          ),
        ),
      ),
    );

    expect(find.text('Hassbuk'), findsOneWidget);
    expect(find.text('بدء الاختبار'), findsOneWidget);
    expect(find.text('إعدادات التقييم'), findsOneWidget);
  });

  testWidgets('offline notice uses readable dark theme colors', (
    WidgetTester tester,
  ) async {
    final theme = buildAppTheme(brightness: Brightness.dark);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: HomeScreen(
          settings: EvaluationSettings(),
          repository: QuranRepository([]),
          language: AppLanguage.ar,
          onLanguageChanged: _ignoreLanguageChange,
          isDarkMode: true,
          onThemeChanged: _ignoreThemeChange,
        ),
      ),
    );

    final notice = tester.widget<Text>(
      find.text('تعمل الاختبارات دون اتصال باستخدام بيانات القرآن المحلية.'),
    );
    expect(notice.style?.color, theme.colorScheme.onSurfaceVariant);
  });

  testWidgets('ayah card and text follow the dark color scheme', (
    WidgetTester tester,
  ) async {
    final theme = buildAppTheme(brightness: Brightness.dark);
    final verses = List.generate(
      3,
      (index) => QuranVerse(
        'الفاتحة',
        'The Opening',
        'مكية',
        'meccan',
        index + 1,
        1,
        1,
        'ayah ${index + 1}',
        'verse ${index + 1}',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: ReviewScreen(
          student: 'Student',
          from: 1,
          to: 1,
          count: 1,
          settings: EvaluationSettings()..ayahsPerQuestion = 3,
          repository: QuranRepository(verses),
          language: AppLanguage.en,
        ),
      ),
    );

    final ayah = tester.widget<Text>(find.text('verse 1 ۝1'));
    expect(ayah.style?.color, theme.colorScheme.onSurface);
    final card = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('verse 1 ۝1'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    expect(
      (card.decoration! as BoxDecoration).color,
      theme.colorScheme.surfaceContainerHighest,
    );
  });
}

void _ignoreLanguageChange(AppLanguage _) {}

void _ignoreThemeChange(bool _) {}

import 'package:flutter_test/flutter_test.dart';
import 'package:hassbuk/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'loads English surah transliteration from the bundled database',
    () async {
      final repository = await QuranRepository.load();

      expect(repository.verses.first.surahTransliteration, 'Al-Fatihah');
    },
  );

  test('passage starts at the question and includes three verses', () {
    final first = QuranVerse(
      'A',
      'A',
      'meccan',
      'meccan',
      1,
      1,
      1,
      'one',
      'one',
    );
    final second = QuranVerse(
      'A',
      'A',
      'meccan',
      'meccan',
      2,
      1,
      1,
      'two',
      'two',
    );
    final third = QuranVerse(
      'A',
      'A',
      'meccan',
      'meccan',
      3,
      1,
      1,
      'three',
      'three',
    );
    final repository = QuranRepository([first, second, third]);

    expect(repository.passageFrom(second), [second, third]);
    expect(repository.randomQuestions(1, 1, 3), [first]);
  });

  test('question count scales with the selected Juz range', () {
    final settings = EvaluationSettings()..questionsPerJuz = 10;
    expect(settings.questionCountForRange(1, 5), 50);
    expect(settings.questionCountForRange(7, 7), 10);
  });

  test('session score totals question points and subtracts all deductions', () {
    final settings = EvaluationSettings()
      ..mistakeDeduction = .25
      ..hesitationDeduction = .1
      ..tajweedDeduction = .2
      ..questionMaximum = 10
      ..tajweedMaximum = 10
      ..masteryMaximum = 5
      ..performanceMaximum = 5;
    final questionIssues = List.generate(
      20,
      (index) => IssueCounts(
        mistakes: index == 0 ? 4 : 0,
        hesitations: index == 0 ? 3 : 0,
        tajweedIssues: index == 0 ? 2 : 0,
      ),
    );
    final score = SessionScore.calculate(
      questionIssues: questionIssues,
      tajweedScore: 8,
      masteryScore: 4,
      performanceScore: 5,
      settings: settings,
    );

    expect(score.deductions, closeTo(1.7, 0.0001));
    expect(score.questionsScore, closeTo(198.3, 0.0001));
    expect(score.total, closeTo(215.3, 0.0001));
    expect(score.maximum, 220);
    expect(score.percentage, closeTo(97.8636364, 0.0001));
  });

  test('question score cannot fall below zero', () {
    final settings = EvaluationSettings()
      ..mistakeDeduction = 1
      ..questionMaximum = 10
      ..tajweedMaximum = 0
      ..masteryMaximum = 0
      ..performanceMaximum = 0;
    final score = SessionScore.calculate(
      questionIssues: [IssueCounts(mistakes: 25), IssueCounts()],
      tajweedScore: 0,
      masteryScore: 0,
      performanceScore: 0,
      settings: settings,
    );

    expect(score.questionsScore, 0);
    expect(score.deductions, 25);
    expect(score.total, 0);
    expect(score.maximum, 20);
  });

  test('question maximum scales with the number of questions', () {
    final settings = EvaluationSettings()
      ..questionMaximum = 10
      ..tajweedMaximum = 10
      ..masteryMaximum = 10
      ..performanceMaximum = 10;
    SessionScore scoreFor(List<IssueCounts> questions) =>
        SessionScore.calculate(
          questionIssues: questions,
          tajweedScore: 10,
          masteryScore: 10,
          performanceScore: 10,
          settings: settings,
        );

    final oneQuestion = scoreFor([IssueCounts()]);
    final fiveQuestions = scoreFor(List.generate(5, (_) => IssueCounts()));

    expect(oneQuestion.maximum, 40);
    expect(fiveQuestions.maximum, 80);
    expect(oneQuestion.percentage, 100);
    expect(fiveQuestions.percentage, 100);
  });

  test('default deductions are one, half, and one point', () {
    final settings = EvaluationSettings();

    expect(settings.mistakeDeduction, 1);
    expect(settings.hesitationDeduction, .5);
    expect(settings.tajweedDeduction, 1);
  });

  test(
    'evaluation settings persist question count, deductions, and maxima',
    () async {
      SharedPreferences.setMockInitialValues({});
      final settings = EvaluationSettings()
        ..questionsPerJuz = 12
        ..ayahsPerQuestion = 4
        ..questionMaximum = 12
        ..mistakeDeduction = 1
        ..hesitationDeduction = .5
        ..tajweedDeduction = 1
        ..tajweedMaximum = 8
        ..masteryMaximum = 7
        ..performanceMaximum = 6;
      await settings.save();

      final restored = EvaluationSettings();
      await restored.load();

      expect(restored.questionsPerJuz, 12);
      expect(restored.ayahsPerQuestion, 4);
      expect(restored.questionMaximum, 12);
      expect(restored.mistakeDeduction, 1);
      expect(restored.hesitationDeduction, .5);
      expect(restored.tajweedDeduction, 1);
      expect(restored.tajweedMaximum, 8);
      expect(restored.masteryMaximum, 7);
      expect(restored.performanceMaximum, 6);
    },
  );

  test(
    'migrates a previously saved hesitation deduction of one to one half',
    () async {
      SharedPreferences.setMockInitialValues({'hesitation_deduction': 1.0});
      final settings = EvaluationSettings();

      await settings.load();

      expect(settings.hesitationDeduction, .5);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getDouble('hesitation_deduction'), .5);
    },
  );

  TestWidgetsFlutterBinding.ensureInitialized();
}

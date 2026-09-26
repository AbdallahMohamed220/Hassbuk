import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EvaluationSettings {
  static const _questionsPerJuzKey = 'questions_per_juz';
  static const _ayahsPerQuestionKey = 'ayahs_per_question';
  static const _questionMaximumKey = 'question_maximum';
  static const _mistakeDeductionKey = 'mistake_deduction';
  static const _hesitationDeductionKey = 'hesitation_deduction';
  static const _hesitationDeductionMigrationKey =
      'hesitation_deduction_half_point_migrated';
  static const _tajweedDeductionKey = 'tajweed_deduction';
  static const _tajweedMaximumKey = 'tajweed_maximum';
  static const _masteryMaximumKey = 'mastery_maximum';
  static const _performanceMaximumKey = 'performance_maximum';

  int questionsPerJuz = 10;
  int ayahsPerQuestion = 3;
  double questionMaximum = 10;
  double mistakeDeduction = 1;
  double hesitationDeduction = .5;
  double tajweedDeduction = 1;
  double tajweedMaximum = 10;
  double masteryMaximum = 10;
  double performanceMaximum = 10;

  int questionCountForRange(int fromJuz, int toJuz) =>
      (toJuz - fromJuz + 1) * questionsPerJuz;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    questionsPerJuz =
        preferences.getInt(_questionsPerJuzKey) ?? questionsPerJuz;
    ayahsPerQuestion =
        preferences.getInt(_ayahsPerQuestionKey) ?? ayahsPerQuestion;
    questionMaximum =
        preferences.getDouble(_questionMaximumKey) ?? questionMaximum;
    mistakeDeduction =
        preferences.getDouble(_mistakeDeductionKey) ?? mistakeDeduction;
    hesitationDeduction =
        preferences.getDouble(_hesitationDeductionKey) ?? hesitationDeduction;
    if (!(preferences.getBool(_hesitationDeductionMigrationKey) ?? false)) {
      if (hesitationDeduction == 1) {
        hesitationDeduction = .5;
        await preferences.setDouble(
          _hesitationDeductionKey,
          hesitationDeduction,
        );
      }
      await preferences.setBool(_hesitationDeductionMigrationKey, true);
    }
    tajweedDeduction =
        preferences.getDouble(_tajweedDeductionKey) ?? tajweedDeduction;
    tajweedMaximum =
        preferences.getDouble(_tajweedMaximumKey) ?? tajweedMaximum;
    masteryMaximum =
        preferences.getDouble(_masteryMaximumKey) ?? masteryMaximum;
    performanceMaximum =
        preferences.getDouble(_performanceMaximumKey) ?? performanceMaximum;
  }

  Future<void> save() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setInt(_questionsPerJuzKey, questionsPerJuz),
      preferences.setInt(_ayahsPerQuestionKey, ayahsPerQuestion),
      preferences.setDouble(_questionMaximumKey, questionMaximum),
      preferences.setDouble(_mistakeDeductionKey, mistakeDeduction),
      preferences.setDouble(_hesitationDeductionKey, hesitationDeduction),
      preferences.setDouble(_tajweedDeductionKey, tajweedDeduction),
      preferences.setDouble(_tajweedMaximumKey, tajweedMaximum),
      preferences.setDouble(_masteryMaximumKey, masteryMaximum),
      preferences.setDouble(_performanceMaximumKey, performanceMaximum),
    ]);
  }
}

class QuranVerse {
  const QuranVerse(
    this.surahAr,
    this.surahEn,
    this.revelationAr,
    this.revelationEn,
    this.ayah,
    this.juz,
    this.page,
    this.textAr,
    this.textEn, {
    this.surahTransliteration = '',
    this.audioUrl,
  });

  final String surahAr;
  final String surahEn;
  final String revelationAr;
  final String revelationEn;
  final int ayah;
  final int juz;
  final int page;
  final String textAr;
  final String textEn;
  final String surahTransliteration;
  final String? audioUrl;
}

enum Evaluation { mastered, minorMistake, mistake }

enum AppLanguage { ar, en }

class IssueCounts {
  IssueCounts({
    this.mistakes = 0,
    this.hesitations = 0,
    this.tajweedIssues = 0,
  });

  int mistakes;
  int hesitations;
  int tajweedIssues;

  IssueCounts copy() => IssueCounts(
    mistakes: mistakes,
    hesitations: hesitations,
    tajweedIssues: tajweedIssues,
  );

  IssueCounts operator +(IssueCounts other) => IssueCounts(
    mistakes: mistakes + other.mistakes,
    hesitations: hesitations + other.hesitations,
    tajweedIssues: tajweedIssues + other.tajweedIssues,
  );
}

class SessionScore {
  const SessionScore({
    required this.questionsScore,
    required this.deductions,
    required this.rubricScore,
    required this.total,
    required this.maximum,
  });

  final double questionsScore;
  final double deductions;
  final double rubricScore;
  final double total;
  final double maximum;

  double get percentage => maximum == 0 ? 0 : total / maximum * 100;

  factory SessionScore.calculate({
    required List<IssueCounts> questionIssues,
    required double tajweedScore,
    required double masteryScore,
    required double performanceScore,
    required EvaluationSettings settings,
  }) {
    final count = questionIssues.length;
    final totalIssues = questionIssues.fold(
      IssueCounts(),
      (total, question) => total + question,
    );
    final deductions =
        totalIssues.mistakes * settings.mistakeDeduction +
        totalIssues.hesitations * settings.hesitationDeduction +
        totalIssues.tajweedIssues * settings.tajweedDeduction;
    final questionMaximum = count * settings.questionMaximum;
    final questionScore = max(0.0, questionMaximum - deductions);
    final rubricScore = tajweedScore + masteryScore + performanceScore;
    final maximum =
        questionMaximum +
        settings.tajweedMaximum +
        settings.masteryMaximum +
        settings.performanceMaximum;
    return SessionScore(
      questionsScore: questionScore,
      deductions: deductions,
      rubricScore: rubricScore,
      total: questionScore + rubricScore,
      maximum: maximum,
    );
  }
}

class QuranRepository {
  const QuranRepository(this.verses);
  final List<QuranVerse> verses;

  static Future<QuranRepository> load() async {
    final raw = await rootBundle.loadString('assets/database.json');
    final surahs = jsonDecode(raw) as List<dynamic>;
    final loaded = <QuranVerse>[];
    for (final item in surahs) {
      final surah = item as Map<String, dynamic>;
      final name = surah['name'] as Map<String, dynamic>;
      final revelation = surah['revelation_place'] as Map<String, dynamic>;
      final surahNumber = surah['number'] as int;
      for (final item in surah['verses'] as List<dynamic>) {
        final verse = item as Map<String, dynamic>;
        final text = verse['text'] as Map<String, dynamic>;
        loaded.add(
          QuranVerse(
            name['ar'] as String,
            name['en'] as String,
            revelation['ar'] as String,
            revelation['en'] as String,
            verse['number'] as int,
            verse['juz'] as int,
            verse['page'] as int,
            text['ar'] as String,
            text['en'] as String,
            surahTransliteration: name['transliteration'] as String,
            audioUrl:
                'https://www.everyayah.com/data/Ghamadi_40kbps/${surahNumber.toString().padLeft(3, '0')}${(verse['number'] as int).toString().padLeft(3, '0')}.mp3',
          ),
        );
      }
    }
    return QuranRepository(loaded);
  }

  List<QuranVerse> randomQuestions(
    int from,
    int to,
    int count, {
    int passageLength = 3,
  }) {
    final pool =
        verses
            .where(
              (verse) =>
                  verse.juz >= from &&
                  verse.juz <= to &&
                  passageFrom(verse, count: passageLength).length ==
                      passageLength,
            )
            .toList()
          ..shuffle(Random());
    return pool.take(min(count, pool.length)).toList();
  }

  QuranVerse? randomQuestion(
    int from,
    int to, {
    QuranVerse? excluding,
    int passageLength = 3,
  }) {
    final pool =
        verses
            .where(
              (verse) =>
                  verse.juz >= from &&
                  verse.juz <= to &&
                  verse != excluding &&
                  passageFrom(verse, count: passageLength).length ==
                      passageLength,
            )
            .toList()
          ..shuffle(Random());
    return pool.isEmpty ? null : pool.first;
  }

  List<QuranVerse> passageFrom(QuranVerse start, {int count = 3}) {
    final startIndex = verses.indexOf(start);
    if (startIndex == -1) return [start];
    return verses
        .skip(startIndex)
        .takeWhile((verse) => verse.surahAr == start.surahAr)
        .take(count)
        .toList();
  }
}

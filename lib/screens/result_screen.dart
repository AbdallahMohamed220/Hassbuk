import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';
import 'setup_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.student,
    required this.questionIssues,
    required this.issueCounts,
    required this.tajweedScore,
    required this.masteryScore,
    required this.performanceScore,
    required this.settings,
    required this.language,
    required this.repository,
  });
  final String student;
  final List<IssueCounts> questionIssues;
  final IssueCounts issueCounts;
  final double tajweedScore;
  final double masteryScore;
  final double performanceScore;
  final EvaluationSettings settings;
  final AppLanguage language;
  final QuranRepository repository;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(language);
    final colors = Theme.of(context).colorScheme;
    final score = SessionScore.calculate(
      questionIssues: questionIssues,
      tajweedScore: tajweedScore,
      masteryScore: masteryScore,
      performanceScore: performanceScore,
      settings: settings,
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Icon(Icons.verified_rounded, color: colors.primary, size: 58),
                  const SizedBox(height: 18),
                  Text(
                    strings.complete,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    student,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 26),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${score.total.toStringAsFixed(2)} / ${score.maximum.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${score.percentage.round()}%',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ResultRow(strings.errorsTotal, issueCounts.mistakes),
                  _ResultRow(strings.hesitationsTotal, issueCounts.hesitations),
                  _ResultRow(
                    strings.tajweedIssuesTotal,
                    issueCounts.tajweedIssues,
                  ),
                  _ResultRow(
                    strings.deductionsTotal,
                    score.deductions,
                    decimal: true,
                  ),
                  const Divider(height: 28),
                  _ScoreRow(
                    strings.questionScore,
                    score.questionsScore,
                    questionIssues.length * settings.questionMaximum,
                  ),
                  _ScoreRow(
                    strings.tajweed,
                    tajweedScore,
                    settings.tajweedMaximum,
                  ),
                  _ScoreRow(
                    strings.mastery,
                    masteryScore,
                    settings.masteryMaximum,
                  ),
                  _ScoreRow(
                    strings.performance,
                    performanceScore,
                    settings.performanceMaximum,
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.undo_rounded),
                    label: Text(strings.undoEvaluation),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SetupScreen(
                          settings: settings,
                          repository: repository,
                          language: language,
                        ),
                      ),
                      (route) => route.isFirst,
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(strings.startNew),
                    style: primaryButton,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    child: Text(strings.backHome),
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

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value, {this.decimal = false});
  final String label;
  final num value;
  final bool decimal;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          decimal ? value.toStringAsFixed(2) : value.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow(this.label, this.score, this.maximum);
  final String label;
  final double score;
  final double maximum;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          '${score.toStringAsFixed(1)} / ${maximum.toStringAsFixed(1)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

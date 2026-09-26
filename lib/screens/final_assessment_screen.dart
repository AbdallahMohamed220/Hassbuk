import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';
import 'result_screen.dart';

class FinalAssessmentScreen extends StatefulWidget {
  const FinalAssessmentScreen({
    super.key,
    required this.student,
    required this.questionIssues,
    required this.issueCounts,
    required this.settings,
    required this.language,
    required this.repository,
  });
  final String student;
  final List<IssueCounts> questionIssues;
  final IssueCounts issueCounts;
  final EvaluationSettings settings;
  final AppLanguage language;
  final QuranRepository repository;

  @override
  State<FinalAssessmentScreen> createState() => _FinalAssessmentScreenState();
}

class _FinalAssessmentScreenState extends State<FinalAssessmentScreen> {
  late final tajweed = TextEditingController(
    text: widget.settings.tajweedMaximum.toString(),
  );
  late final mastery = TextEditingController(
    text: widget.settings.masteryMaximum.toString(),
  );
  late final performance = TextEditingController(
    text: widget.settings.performanceMaximum.toString(),
  );

  @override
  void dispose() {
    tajweed.dispose();
    mastery.dispose();
    performance.dispose();
    super.dispose();
  }

  void finish() {
    final strings = AppStrings(widget.language);
    final maxima = [
      widget.settings.tajweedMaximum,
      widget.settings.masteryMaximum,
      widget.settings.performanceMaximum,
    ];
    final scores = [
      _scoreOrDefault(tajweed.text, maxima[0]),
      _scoreOrDefault(mastery.text, maxima[1]),
      _scoreOrDefault(performance.text, maxima[2]),
    ];
    if (scores.asMap().entries.any((entry) {
      final score = entry.value;
      return score == null ||
          !score.isFinite ||
          score < 0 ||
          score > maxima[entry.key];
    })) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.scoreMustBeWithinMaximum)));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          student: widget.student,
          questionIssues: widget.questionIssues,
          issueCounts: widget.issueCounts,
          tajweedScore: scores[0]!,
          masteryScore: scores[1]!,
          performanceScore: scores[2]!,
          settings: widget.settings,
          language: widget.language,
          repository: widget.repository,
        ),
      ),
    );
  }

  double? _scoreOrDefault(String value, double defaultValue) =>
      value.trim().isEmpty ? defaultValue : double.tryParse(value);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(strings.finalAssessment)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.complete,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.student,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 26),
                _AssessmentField(
                  label: strings.tajweed,
                  maximum: widget.settings.tajweedMaximum,
                  maximumLabel: strings.maximumPoints(
                    widget.settings.tajweedMaximum,
                  ),
                  controller: tajweed,
                ),
                const SizedBox(height: 16),
                _AssessmentField(
                  label: strings.mastery,
                  maximum: widget.settings.masteryMaximum,
                  maximumLabel: strings.maximumPoints(
                    widget.settings.masteryMaximum,
                  ),
                  controller: mastery,
                ),
                const SizedBox(height: 16),
                _AssessmentField(
                  label: strings.performance,
                  maximum: widget.settings.performanceMaximum,
                  maximumLabel: strings.maximumPoints(
                    widget.settings.performanceMaximum,
                  ),
                  controller: performance,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: finish,
                  style: primaryButton,
                  child: Text(strings.showResult),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssessmentField extends StatelessWidget {
  const _AssessmentField({
    required this.label,
    required this.maximum,
    required this.maximumLabel,
    required this.controller,
  });
  final String label;
  final double maximum;
  final String maximumLabel;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(labelText: label, helperText: maximumLabel),
  );
}

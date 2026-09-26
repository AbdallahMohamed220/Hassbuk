import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.settings,
    required this.language,
  });
  final EvaluationSettings settings;
  final AppLanguage language;

  @override
  State<SettingsSheet> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsSheet> {
  late final questionsPerJuz = TextEditingController(
    text: '${widget.settings.questionsPerJuz}',
  );
  late final ayahsPerQuestion = TextEditingController(
    text: '${widget.settings.ayahsPerQuestion}',
  );
  late final questionMaximum = TextEditingController(
    text: widget.settings.questionMaximum.toString(),
  );
  late final mistakeDeduction = TextEditingController(
    text: widget.settings.mistakeDeduction.toString(),
  );
  late final hesitationDeduction = TextEditingController(
    text: widget.settings.hesitationDeduction.toString(),
  );
  late final tajweedDeduction = TextEditingController(
    text: widget.settings.tajweedDeduction.toString(),
  );
  late final tajweedMaximum = TextEditingController(
    text: widget.settings.tajweedMaximum.toString(),
  );
  late final masteryMaximum = TextEditingController(
    text: widget.settings.masteryMaximum.toString(),
  );
  late final performanceMaximum = TextEditingController(
    text: widget.settings.performanceMaximum.toString(),
  );

  List<TextEditingController> get controllers => [
    questionsPerJuz,
    ayahsPerQuestion,
    questionMaximum,
    mistakeDeduction,
    hesitationDeduction,
    tajweedDeduction,
    tajweedMaximum,
    masteryMaximum,
    performanceMaximum,
  ];

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    final strings = AppStrings(widget.language);
    final questionCount = int.tryParse(questionsPerJuz.text);
    final ayahCount = int.tryParse(ayahsPerQuestion.text);
    final questionMaximumScore = double.tryParse(questionMaximum.text);
    final decimals = [
      double.tryParse(mistakeDeduction.text),
      double.tryParse(hesitationDeduction.text),
      double.tryParse(tajweedDeduction.text),
      double.tryParse(tajweedMaximum.text),
      double.tryParse(masteryMaximum.text),
      double.tryParse(performanceMaximum.text),
    ];
    if (questionCount == null ||
        questionCount < 1 ||
        ayahCount == null ||
        ayahCount < 1 ||
        questionMaximumScore == null ||
        !questionMaximumScore.isFinite ||
        questionMaximumScore <= 0 ||
        decimals.any(
          (value) => value == null || !value.isFinite || value < 0,
        )) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.invalidScores)));
      return;
    }
    widget.settings
      ..questionsPerJuz = questionCount
      ..ayahsPerQuestion = ayahCount
      ..questionMaximum = questionMaximumScore
      ..mistakeDeduction = decimals[0]!
      ..hesitationDeduction = decimals[1]!
      ..tajweedDeduction = decimals[2]!
      ..tajweedMaximum = decimals[3]!
      ..masteryMaximum = decimals[4]!
      ..performanceMaximum = decimals[5]!;
    await widget.settings.save();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 22,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.settings,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              strings.customizeScores,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _NumberField(
              label: strings.questionsPerJuz,
              controller: questionsPerJuz,
              integer: true,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.ayahsPerQuestion,
              controller: ayahsPerQuestion,
              integer: true,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.questionMaximum,
              controller: questionMaximum,
            ),
            const SizedBox(height: 18),
            _NumberField(
              label: strings.mistakeDeduction,
              controller: mistakeDeduction,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.hesitationDeduction,
              controller: hesitationDeduction,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.tajweedDeduction,
              controller: tajweedDeduction,
            ),
            const SizedBox(height: 22),
            Text(
              strings.finalAssessment,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _NumberField(
              label: strings.maximumPointsLabel(strings.tajweed),
              controller: tajweedMaximum,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.maximumPointsLabel(strings.mastery),
              controller: masteryMaximum,
            ),
            const SizedBox(height: 10),
            _NumberField(
              label: strings.maximumPointsLabel(strings.performance),
              controller: performanceMaximum,
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: save,
              style: primaryButton,
              child: Text(strings.saveSettings),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    this.integer = false,
  });
  final String label;
  final TextEditingController controller;
  final bool integer;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    decoration: InputDecoration(labelText: label),
  );
}

import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';
import 'review_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({
    super.key,
    required this.settings,
    required this.repository,
    required this.language,
  });
  final EvaluationSettings settings;
  final QuranRepository repository;
  final AppLanguage language;

  @override
  State<SetupScreen> createState() => _SetupState();
}

class _SetupState extends State<SetupScreen> {
  final name = TextEditingController();
  int from = 1;
  int to = 5;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void begin() {
    final strings = AppStrings(widget.language);
    final count = widget.settings.questionCountForRange(from, to);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewScreen(
          student: name.text.trim().isEmpty
              ? strings.unnamedStudent
              : name.text.trim(),
          from: from,
          to: to,
          count: count,
          settings: widget.settings,
          repository: widget.repository,
          language: widget.language,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(widget.language);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.newReview),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.setupTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.setupDescription,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 30),
                _Label(strings.studentName),
                TextField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: strings.studentHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 28),
                _Label(strings.quranRange),
                Row(
                  children: [
                    Expanded(
                      child: _Picker(
                        label: strings.fromJuz,
                        value: from,
                        onChanged: (value) => setState(() {
                          from = value!;
                          if (to < from) to = from;
                        }),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _Picker(
                        label: strings.toJuz,
                        value: to,
                        onChanged: (value) => setState(() => to = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _Label(strings.questionCount),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    strings.totalQuestions(
                      widget.settings.questionCountForRange(from, to),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.randomQuestions,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 36),
                FilledButton.icon(
                  onPressed: begin,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(strings.beginReview),
                  style: primaryButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  );
}

class _Picker extends StatelessWidget {
  const _Picker({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int?> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int>(
    initialValue: value,
    decoration: InputDecoration(labelText: label),
    items: List.generate(
      30,
      (index) =>
          DropdownMenuItem(value: index + 1, child: Text('${index + 1}')),
    ),
    onChanged: onChanged,
  );
}

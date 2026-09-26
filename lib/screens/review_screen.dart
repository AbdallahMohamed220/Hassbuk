import 'dart:math';

import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../models.dart';
import '../theme.dart';
import 'final_assessment_screen.dart';
import 'full_question_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.student,
    required this.from,
    required this.to,
    required this.count,
    required this.settings,
    required this.repository,
    required this.language,
  });
  final String student;
  final int from;
  final int to;
  final int count;
  final EvaluationSettings settings;
  final QuranRepository repository;
  final AppLanguage language;

  @override
  State<ReviewScreen> createState() => _ReviewState();
}

class _ReviewState extends State<ReviewScreen> {
  late final List<QuranVerse> questions;
  int current = 0;
  double ayahFontSize = 24;
  IssueCounts currentIssues = IssueCounts();
  final assessedIssues = <IssueCounts>[];

  IssueCounts get totalIssues =>
      assessedIssues.fold(IssueCounts(), (total, item) => total + item);

  @override
  void initState() {
    super.initState();
    questions = widget.repository.randomQuestions(
      widget.from,
      widget.to,
      widget.count,
      passageLength: widget.settings.ayahsPerQuestion,
    );
  }

  void advanceQuestion() {
    assessedIssues.add(currentIssues.copy());
    currentIssues = IssueCounts();
    if (current + 1 == questions.length) {
      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinalAssessmentScreen(
            student: widget.student,
            questionIssues: List.of(assessedIssues),
            issueCounts: totalIssues,
            settings: widget.settings,
            language: widget.language,
            repository: widget.repository,
          ),
        ),
      );
    } else {
      setState(() => current++);
    }
  }

  void undoLastQuestion() {
    if (assessedIssues.isEmpty) return;
    final previousIssues = assessedIssues.removeLast();
    setState(() {
      current = assessedIssues.length;
      currentIssues = previousIssues;
    });
  }

  void changeIssue(void Function(IssueCounts) change) {
    setState(() => change(currentIssues));
  }

  void resetCurrentErrors() {
    setState(() => currentIssues = IssueCounts());
  }

  void changeQuestion() {
    final replacement = widget.repository.randomQuestion(
      widget.from,
      widget.to,
      excluding: questions[current],
      passageLength: widget.settings.ayahsPerQuestion,
    );
    if (replacement == null) return;
    setState(() {
      questions[current] = replacement;
      currentIssues = IssueCounts();
    });
  }

  Future<void> confirmExit() async {
    final strings = AppStrings(widget.language);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.leaveReviewTitle),
        content: Text(strings.leaveReviewMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.stayInReview),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.leaveReview),
          ),
        ],
      ),
    );
    if (shouldLeave == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[current];
    final strings = AppStrings(widget.language);
    final colors = Theme.of(context).colorScheme;
    final passage = widget.repository.passageFrom(
      question,
      count: widget.settings.ayahsPerQuestion,
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) confirmExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: confirmExit,
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Text(
                        strings.question(current + 1, questions.length),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (assessedIssues.isEmpty)
                        const SizedBox(width: 48)
                      else
                        IconButton(
                          onPressed: undoLastQuestion,
                          tooltip: strings.undoEvaluation,
                          icon: const Icon(Icons.undo_rounded),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: (current + 1) / questions.length,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                strings.juz(question.juz),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                strings.page(question.page),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                strings.revelationPlace(
                                  widget.language == AppLanguage.ar
                                      ? question.revelationAr
                                      : question.revelationEn,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.language == AppLanguage.ar
                              ? question.surahAr
                              : question.surahTransliteration,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),

                        Text(
                          strings.readFromQuote,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _QuoteText(
                          text: widget.language == AppLanguage.ar
                              ? '${passage.first.textAr} ${strings.quranVerseNumber(passage.first.ayah)}'
                              : '${passage.first.textEn} ${strings.quranVerseNumber(passage.first.ayah)}',
                          language: widget.language,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          strings.toQuote,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        _QuoteText(
                          text: widget.language == AppLanguage.ar
                              ? '${passage.last.textAr} ${strings.quranVerseNumber(passage.last.ayah)}'
                              : '${passage.last.textEn} ${strings.quranVerseNumber(passage.last.ayah)}',
                          language: widget.language,
                        ),
                        const SizedBox(height: 25),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullQuestionScreen(
                                question: question,
                                passage: passage,
                                language: widget.language,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: Text(strings.viewFullQuestion),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    strings.howDidStudentDo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _IssueCounter(
                    label: strings.mistakeCount,
                    count: currentIssues.mistakes,
                    deduction: widget.settings.mistakeDeduction,
                    onIncrement: () =>
                        changeIssue((issues) => issues.mistakes++),
                    onDecrement: () => changeIssue((issues) {
                      if (issues.mistakes > 0) issues.mistakes--;
                    }),
                  ),
                  const SizedBox(height: 10),
                  _IssueCounter(
                    label: strings.hesitationCount,
                    count: currentIssues.hesitations,
                    deduction: widget.settings.hesitationDeduction,
                    onIncrement: () =>
                        changeIssue((issues) => issues.hesitations++),
                    onDecrement: () => changeIssue((issues) {
                      if (issues.hesitations > 0) issues.hesitations--;
                    }),
                  ),
                  const SizedBox(height: 10),
                  _IssueCounter(
                    label: strings.tajweedIssues,
                    count: currentIssues.tajweedIssues,
                    deduction: widget.settings.tajweedDeduction,
                    onIncrement: () =>
                        changeIssue((issues) => issues.tajweedIssues++),
                    onDecrement: () => changeIssue((issues) {
                      if (issues.tajweedIssues > 0) issues.tajweedIssues--;
                    }),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: resetCurrentErrors,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(strings.resetErrors),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: changeQuestion,
                    icon: const Icon(Icons.shuffle_rounded),
                    label: Text(strings.changeQuestion),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: advanceQuestion,
                    icon: Icon(
                      current + 1 == questions.length
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      current + 1 == questions.length
                          ? strings.finishQuestions
                          : strings.nextQuestion,
                    ),
                    style: primaryButton,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${strings.currentQuestionScore}: ${_currentQuestionScore.toStringAsFixed(2)} / ${widget.settings.questionMaximum.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${strings.deductionsTotal}: ${_currentDeduction.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double get _currentDeduction {
    return currentIssues.mistakes * widget.settings.mistakeDeduction +
        currentIssues.hesitations * widget.settings.hesitationDeduction +
        currentIssues.tajweedIssues * widget.settings.tajweedDeduction;
  }

  double get _currentQuestionScore =>
      max(0.0, widget.settings.questionMaximum - _currentDeduction);
}

class _QuoteText extends StatelessWidget {
  const _QuoteText({required this.text, required this.language});
  final String text;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: language == AppLanguage.ar
        ? TextDirection.rtl
        : TextDirection.ltr,
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: language == AppLanguage.ar ? 'Amiri Quran' : 'Georgia',
        fontSize: language == AppLanguage.ar ? 19 : 12,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _IssueCounter extends StatelessWidget {
  const _IssueCounter({
    required this.label,
    required this.count,
    required this.deduction,
    required this.onIncrement,
    required this.onDecrement,
  });
  final String label;
  final int count;
  final double deduction;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 58),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          '-${deduction.toStringAsFixed(2)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add_circle_outline_rounded),
        ),
      ],
    ),
  );
}

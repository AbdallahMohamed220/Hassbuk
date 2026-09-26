import 'models.dart';

class AppStrings {
  const AppStrings(this.language);
  final AppLanguage language;
  bool get isArabic => language == AppLanguage.ar;
  String get subtitle => isArabic ? 'اختبار الاجزاء القرآنية' : 'Quran test';
  String get homeDescription => isArabic
      ? 'طريقة هادئة وبسيطة لإدارة اختبار قرآني مركز.'
      : 'A quiet, simple way to conduct a focused Quran test.';
  String get startReview => isArabic ? 'بدء الاختبار' : 'Start test';
  String get settings => isArabic ? 'إعدادات التقييم' : 'Evaluation settings';
  String get offline => isArabic
      ? 'تعمل الاختبارات دون اتصال باستخدام بيانات القرآن المحلية.'
      : 'Tests work offline with the bundled Quran database.';
  String get newReview => isArabic ? 'اختبار جديد' : 'New test';
  String get setupTitle => isArabic ? 'إعداد الجلسة' : 'Set up the session';
  String get setupDescription => isArabic
      ? 'اختر الطالب والنطاق لاختبار اليوم.'
      : 'Choose the student and range for today’s test.';
  String get studentName => isArabic ? 'اسم الطالب' : 'Student name';
  String get studentHint => isArabic ? 'مثال: أحمد محمد' : 'e.g. Ahmed Mohamed';
  String get quranRange => isArabic ? 'نطاق القرآن' : 'Quran range';
  String get fromJuz => isArabic ? 'من الجزء' : 'From juz';
  String get toJuz => isArabic ? 'إلى الجزء' : 'To juz';
  String get questionCount => isArabic ? 'عدد الأسئلة' : 'Number of questions';
  String questions(int count) => isArabic ? '$count أسئلة' : '$count questions';
  String get randomQuestions => isArabic
      ? 'يتم اختيار الأسئلة عشوائياً دون تكرار.'
      : 'Questions are selected randomly without repeats.';
  String get beginReview => isArabic ? 'بدء الاختبار' : 'Begin test';
  String get enterStudent =>
      isArabic ? 'يرجى إدخال اسم الطالب.' : 'Please enter the student name.';
  String question(int current, int total) =>
      isArabic ? 'السؤال $current من $total' : 'Question $current of $total';
  String juz(int value) => isArabic ? 'الجزء $value' : 'Juz $value';
  String page(int value) => isArabic ? 'الصفحة $value' : 'Page $value';
  String get readFromQuote =>
      isArabic ? 'اقرأ من قوله تعالى:' : 'Read from the words of Allah:';
  String get toQuote => isArabic ? 'إلى قوله تعالى:' : 'to the words of Allah:';
  String get viewFullQuestion =>
      isArabic ? 'عرض السؤال كاملًا' : 'View the full question';
  String get fullQuestion => isArabic ? 'السؤال كاملًا' : 'Full question';
  String get playRecitation =>
      isArabic ? 'تشغيل تلاوة السورة' : 'Play surah recitation';
  String get pauseRecitation => isArabic ? 'إيقاف التلاوة' : 'Pause recitation';
  String get audioUnavailable => isArabic
      ? 'لا يتوفر رابط صوتي لهذه السورة.'
      : 'No audio link is available for this surah.';
  String quranVerseNumber(int value) {
    final number = value.toString();
    if (!isArabic) return '۝$number';
    const western = '0123456789';
    const eastern = '٠١٢٣٤٥٦٧٨٩';
    final arabicNumber = number.split('').map((digit) {
      final index = western.indexOf(digit);
      return index == -1 ? digit : eastern[index];
    }).join();
    return '۝$arabicNumber';
  }

  String revelationPlace(String value) => isArabic
      ? 'مكان النزول: $value'
      : 'Revelation: ${value[0].toUpperCase()}${value.substring(1)}';
  String ayah(int value) => isArabic ? 'الآية $value' : 'Ayah $value';
  String get startFromHere => isArabic ? 'ابدأ من هنا' : 'Start from here';
  String get howDidStudentDo =>
      isArabic ? 'كيف كانت إجابة الطالب؟' : 'How did the student do?';
  String get mastered => isArabic ? 'متقن' : 'Mastered';
  String get minorMistake => isArabic ? 'خطأ بسيط' : 'Minor mistake';
  String get mistake => isArabic ? 'خطأ' : 'Mistake';
  String get complete => isArabic ? 'اكتمل الاختبار' : 'Test complete';
  String get startNew => isArabic ? 'بدء اختبار جديد' : 'Start new test';
  String get backHome => isArabic ? 'العودة للرئيسية' : 'Back to home';
  String get customizeScores => isArabic
      ? 'خصص النقاط المستخدمة في النتيجة النهائية.'
      : 'Customize the points used in the final score.';
  String get saveSettings => isArabic ? 'حفظ الإعدادات' : 'Save settings';
  String get points => isArabic ? 'نقاط' : 'points';
  String get invalidScores => isArabic
      ? 'أدخل نقاطاً صحيحة وغير سالبة.'
      : 'Enter valid, non-negative scores.';
  String get languageToggle => isArabic ? 'English' : 'العربية';
  String get darkMode => isArabic ? 'الوضع الليلي' : 'Dark mode';
  String get lightMode => isArabic ? 'الوضع النهاري' : 'Light mode';
  String get undoEvaluation =>
      isArabic ? 'تراجع عن آخر تقييم' : 'Undo last evaluation';
  String get resetErrors =>
      isArabic ? 'تصفير أخطاء السؤال' : 'Reset question errors';
  String get changeQuestion => isArabic ? 'تغيير السؤال' : 'Change question';
  String get leaveReviewTitle => isArabic ? 'مغادرة الاختبار؟' : 'Leave test?';
  String get leaveReviewMessage => isArabic
      ? 'سيتم فقدان التقييمات الحالية لهذا الاختبار.'
      : 'Your current evaluations in this test will be lost.';
  String get stayInReview => isArabic ? 'البقاء' : 'Stay';
  String get leaveReview => isArabic ? 'مغادرة' : 'Leave';
  String get questionsPerJuz =>
      isArabic ? 'عدد الأسئلة لكل جزء' : 'Questions per Juz';
  String get ayahsPerQuestion =>
      isArabic ? 'عدد الآيات في كل سؤال' : 'Ayahs per question';
  String get questionMaximum =>
      isArabic ? 'الدرجة القصوى لكل سؤال' : 'Maximum points per question';
  String totalQuestions(int count) =>
      isArabic ? 'إجمالي الأسئلة: $count' : 'Total questions: $count';
  String get mistakeDeduction =>
      isArabic ? 'خصم الخطأ الواحد' : 'Deduction per mistake';
  String get hesitation => isArabic ? 'تردد' : 'Hesitation';
  String get hesitationDeduction =>
      isArabic ? 'خصم التردد الواحد' : 'Deduction per hesitation';
  String get tajweed => isArabic ? 'التجويد النظري' : 'Theoretical Tajweed';
  String get tajweedDeduction =>
      isArabic ? 'خصم ملاحظة التجويد' : 'Deduction per Tajweed issue';
  String get mastery => isArabic ? 'الإتقان' : 'Mastery';
  String get performance => isArabic ? 'الأداء' : 'Performance';
  String get finalAssessment => isArabic ? 'التقييم العام' : 'Final assessment';
  String get earnedPoints => isArabic ? 'الدرجة المكتسبة' : 'Earned points';
  String maximumPoints(double maximum) => isArabic
      ? 'الحد الأعلى: ${maximum.toStringAsFixed(1)}'
      : 'Maximum: ${maximum.toStringAsFixed(1)}';
  String get nextQuestion => isArabic ? 'السؤال التالي' : 'Next question';
  String get finishQuestions => isArabic ? 'إنهاء الأسئلة' : 'Finish questions';
  String get addOccurrence => isArabic ? 'إضافة حالة' : 'Add occurrence';
  String get noQuestionsAvailable => isArabic
      ? 'لا توجد آيات متاحة في نطاق الأجزاء المحدد.'
      : 'No verses are available in the selected Juz range.';
  String get showResult => isArabic ? 'عرض النتيجة' : 'Show result';
  String get unnamedStudent => isArabic ? 'طالب' : 'Student';
  String get mistakeCount => isArabic ? 'أخطاء' : 'Mistakes';
  String get hesitationCount => isArabic ? 'مرات التردد' : 'Hesitations';
  String get tajweedIssues => isArabic ? 'ملاحظات التجويد' : 'Tajweed issues';
  String get maximum => isArabic ? 'الحد الأعلى' : 'Maximum';
  String get noDeduction => isArabic ? 'لا يوجد خصم' : 'No deduction';
  String get scoreMustBeWithinMaximum => isArabic
      ? 'يجب أن تكون كل درجة بين صفر والحد الأعلى.'
      : 'Each score must be between zero and its maximum.';
  String get errorsTotal => isArabic ? 'إجمالي الأخطاء' : 'Total mistakes';
  String get hesitationsTotal =>
      isArabic ? 'إجمالي التردد' : 'Total hesitations';
  String get tajweedIssuesTotal =>
      isArabic ? 'إجمالي ملاحظات التجويد' : 'Total Tajweed issues';
  String get deductionsTotal =>
      isArabic ? 'إجمالي الخصومات' : 'Total deductions';
  String get questionScore => isArabic ? 'درجة الأسئلة' : 'Questions score';
  String get currentQuestionScore =>
      isArabic ? 'درجة هذا السؤال' : 'Current question score';
  String maximumPointsLabel(String category) =>
      isArabic ? 'الحد الأعلى لدرجة $category' : '$category maximum score';
}

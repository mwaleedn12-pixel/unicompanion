import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ur')];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  bool get isUrdu => locale.languageCode == 'ur';

  // ── Strings ──
  String get appTitle => isUrdu ? 'یونی کمپینین' : 'UniCompanion';
  String get home => isUrdu ? 'ہوم' : 'Home';
  String get explore => isUrdu ? 'دریافت کریں' : 'Explore';
  String get tools => isUrdu ? 'ٹولز' : 'Tools';
  String get track => isUrdu ? 'ٹریک' : 'Track';
  String get profile => isUrdu ? 'پروفائل' : 'Profile';
  String get login => isUrdu ? 'لاگ ان' : 'Login';
  String get register => isUrdu ? 'رجسٹر' : 'Register';
  String get email => isUrdu ? 'ای میل' : 'Email';
  String get password => isUrdu ? 'پاس ورڈ' : 'Password';
  String get forgotPassword => isUrdu ? 'پاس ورڈ بھول گئے؟' : 'Forgot Password?';
  String get logout => isUrdu ? 'لاگ آؤٹ' : 'Logout';
  String get logoutConfirm => isUrdu ? 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟' : 'Are you sure you want to logout?';
  String get cancel => isUrdu ? 'منسوخ' : 'Cancel';
  String get confirm => isUrdu ? 'تصدیق' : 'Confirm';
  String get save => isUrdu ? 'محفوظ کریں' : 'Save';
  String get delete => isUrdu ? 'حذف کریں' : 'Delete';
  String get search => isUrdu ? 'تلاش' : 'Search';
  String get loading => isUrdu ? 'لوڈ ہو رہا ہے...' : 'Loading...';
  String get error => isUrdu ? 'کچھ غلط ہو گیا' : 'Something went wrong';
  String get retry => isUrdu ? 'دوبارہ کوشش' : 'Retry';
  String get noData => isUrdu ? 'کوئی ڈیٹا دستیاب نہیں' : 'No data available';
  String get darkMode => isUrdu ? 'ڈارک موڈ' : 'Dark Mode';
  String get language => isUrdu ? 'زبان' : 'Language';
  String get settings => isUrdu ? 'ترتیبات' : 'Settings';
  String get about => isUrdu ? 'ایپ کے بارے میں' : 'About';
  String get parentMode => isUrdu ? 'والدین موڈ' : 'Parent Mode';
  String get redoOnboarding => isUrdu ? 'آن بورڈنگ دوبارہ' : 'Redo Onboarding';
  String get findYourDreamUniversity => isUrdu ? 'اپنی پسندیدہ یونیورسٹی تلاش کریں' : 'Find your dream university';
  String get searchUniversities => isUrdu ? 'یونیورسٹیاں تلاش کریں...' : 'Search universities...';
  String get scholarships => isUrdu ? 'وظائف' : 'Scholarships';
  String get careerQuiz => isUrdu ? 'کیریئر کوئز' : 'Career Quiz';
  String get programs => isUrdu ? 'پروگرامز' : 'Programs';
  String get campuses => isUrdu ? 'کیمپسز' : 'Campuses';
  String get aiHelp => isUrdu ? 'اے آئی مدد' : 'AI Help';
  String get jobs => isUrdu ? 'نوکریاں' : 'Jobs';
  String get community => isUrdu ? 'کمیونٹی' : 'Community';
  String get gpaCalculator => isUrdu ? 'جی پی اے کیلکولیٹر' : 'GPA Calculator';
  String get cgpaCalculator => isUrdu ? 'سی جی پی اے کیلکولیٹر' : 'CGPA Calculator';
  String get targetGpa => isUrdu ? 'ٹارگٹ جی پی اے' : 'Target GPA';
  String get attendanceCalculator => isUrdu ? 'حاضری کیلکولیٹر' : 'Attendance Calculator';
  String get gradeCalculator => isUrdu ? 'گریڈ کیلکولیٹر' : 'Grade Calculator';
  String get meritCalculator => isUrdu ? 'میرٹ کیلکولیٹر' : 'Merit Calculator';
  String get eligibilityChecker => isUrdu ? 'اہلیت چیکر' : 'Eligibility Checker';
  String get compareUniversities => isUrdu ? 'یونیورسٹیاں موازنہ' : 'Compare Universities';
  String get entryTestPrep => isUrdu ? 'انٹری ٹیسٹ تیاری' : 'Entry Test Prep';
  String get universityMatch => isUrdu ? 'یونیورسٹی میچ' : 'University Match';
  String get semesterTracker => isUrdu ? 'سمسٹر ٹریکر' : 'Semester Tracker';
  String get applicationTracker => isUrdu ? 'درخواست ٹریکر' : 'Application Tracker';
  String get academicDashboard => isUrdu ? 'تعلیمی ڈیش بورڈ' : 'Academic Dashboard';
  String get shortlist => isUrdu ? 'شارٹ لسٹ' : 'Shortlist';
  String get assignments => isUrdu ? 'اسائنمنٹس' : 'Assignments';
  String get degreeProgress => isUrdu ? 'ڈگری پیشرفت' : 'Degree Progress';
  String get applied => isUrdu ? 'درخواست دی' : 'Applied';
  String get accepted => isUrdu ? 'منظور' : 'Accepted';
  String get rejected => isUrdu ? 'مسترد' : 'Rejected';
  String get upcomingDeadlines => isUrdu ? 'آنے والی ڈیڈلائنز' : 'Upcoming Deadlines';
  String get writeReview => isUrdu ? 'جائزہ لکھیں' : 'Write Review';
  String get startPractice => isUrdu ? 'مشق شروع کریں' : 'Start Practice';
  String get applyNow => isUrdu ? 'ابھی درخواست دیں' : 'Apply Now';
  String get visitWebsite => isUrdu ? 'ویب سائٹ دیکھیں' : 'Visit Website';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ur'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
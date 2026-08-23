import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'UniCompanion'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @track.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get track;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @parentMode.
  ///
  /// In en, this message translates to:
  /// **'Parent Mode'**
  String get parentMode;

  /// No description provided for @redoOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Redo Onboarding'**
  String get redoOnboarding;

  /// No description provided for @findYourDreamUniversity.
  ///
  /// In en, this message translates to:
  /// **'Find your dream university'**
  String get findYourDreamUniversity;

  /// No description provided for @searchUniversities.
  ///
  /// In en, this message translates to:
  /// **'Search universities...'**
  String get searchUniversities;

  /// No description provided for @scholarships.
  ///
  /// In en, this message translates to:
  /// **'Scholarships'**
  String get scholarships;

  /// No description provided for @careerQuiz.
  ///
  /// In en, this message translates to:
  /// **'Career Quiz'**
  String get careerQuiz;

  /// No description provided for @programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// No description provided for @campuses.
  ///
  /// In en, this message translates to:
  /// **'Campuses'**
  String get campuses;

  /// No description provided for @aiHelp.
  ///
  /// In en, this message translates to:
  /// **'AI Help'**
  String get aiHelp;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @gpaCalculator.
  ///
  /// In en, this message translates to:
  /// **'GPA Calculator'**
  String get gpaCalculator;

  /// No description provided for @cgpaCalculator.
  ///
  /// In en, this message translates to:
  /// **'CGPA Calculator'**
  String get cgpaCalculator;

  /// No description provided for @targetGpa.
  ///
  /// In en, this message translates to:
  /// **'Target GPA'**
  String get targetGpa;

  /// No description provided for @attendanceCalculator.
  ///
  /// In en, this message translates to:
  /// **'Attendance Calculator'**
  String get attendanceCalculator;

  /// No description provided for @gradeCalculator.
  ///
  /// In en, this message translates to:
  /// **'Grade Calculator'**
  String get gradeCalculator;

  /// No description provided for @meritCalculator.
  ///
  /// In en, this message translates to:
  /// **'Merit Calculator'**
  String get meritCalculator;

  /// No description provided for @eligibilityChecker.
  ///
  /// In en, this message translates to:
  /// **'Eligibility Checker'**
  String get eligibilityChecker;

  /// No description provided for @compareUniversities.
  ///
  /// In en, this message translates to:
  /// **'Compare Universities'**
  String get compareUniversities;

  /// No description provided for @entryTestPrep.
  ///
  /// In en, this message translates to:
  /// **'Entry Test Prep'**
  String get entryTestPrep;

  /// No description provided for @universityMatch.
  ///
  /// In en, this message translates to:
  /// **'University Match'**
  String get universityMatch;

  /// No description provided for @semesterTracker.
  ///
  /// In en, this message translates to:
  /// **'Semester Tracker'**
  String get semesterTracker;

  /// No description provided for @applicationTracker.
  ///
  /// In en, this message translates to:
  /// **'Application Tracker'**
  String get applicationTracker;

  /// No description provided for @academicDashboard.
  ///
  /// In en, this message translates to:
  /// **'Academic Dashboard'**
  String get academicDashboard;

  /// No description provided for @shortlist.
  ///
  /// In en, this message translates to:
  /// **'Shortlist'**
  String get shortlist;

  /// No description provided for @assignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// No description provided for @degreeProgress.
  ///
  /// In en, this message translates to:
  /// **'Degree Progress'**
  String get degreeProgress;

  /// No description provided for @addCourse.
  ///
  /// In en, this message translates to:
  /// **'Add Course'**
  String get addCourse;

  /// No description provided for @addSemester.
  ///
  /// In en, this message translates to:
  /// **'Add Semester'**
  String get addSemester;

  /// No description provided for @addAssignment.
  ///
  /// In en, this message translates to:
  /// **'Add Assignment'**
  String get addAssignment;

  /// No description provided for @courseName.
  ///
  /// In en, this message translates to:
  /// **'Course Name'**
  String get courseName;

  /// No description provided for @creditHours.
  ///
  /// In en, this message translates to:
  /// **'Credit Hours'**
  String get creditHours;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @upcomingDeadlines.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Deadlines'**
  String get upcomingDeadlines;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// No description provided for @selectTest.
  ///
  /// In en, this message translates to:
  /// **'Select Test'**
  String get selectTest;

  /// No description provided for @seeResults.
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// No description provided for @newDiscussion.
  ///
  /// In en, this message translates to:
  /// **'New Discussion'**
  String get newDiscussion;

  /// No description provided for @postDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Post Discussion'**
  String get postDiscussion;

  /// No description provided for @applyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get applyNow;

  /// No description provided for @visitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get visitWebsite;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

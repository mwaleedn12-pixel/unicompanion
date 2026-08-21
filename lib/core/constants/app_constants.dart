abstract final class AppConstants {
  // ── Supabase ──
static const String supabaseUrl = 'https://gdgctotikklntfmepwiw.supabase.co';
static const String supabaseAnonKey = 'sb_publishable_OfW4AnXCI91QUTzYQGF-HA_qs9irdMc';
  // ── App Info ──
  static const String appName = 'UniCompanion';
  static const String appTagline = 'FSC to Graduation, everything in one app';
  static const String appVersion = '1.0.0';

  // ── Pagination ──
  static const int defaultPageSize = 20;

  // ── Validation ──
  static const int minPasswordLength = 8;
  static const double minPercentage = 0.0;
  static const double maxPercentage = 100.0;
  static const double maxGpa = 4.0;
  static const int maxCreditHours = 5;

  // ── Cache Durations ──
  static const Duration universityCacheDuration = Duration(hours: 24);
  static const Duration programCacheDuration = Duration(hours: 24);

  // ── User Types ──
  static const String userTypeFsc = 'fsc_student';
  static const String userTypeUniversity = 'university_student';
  static const String userTypeOther = 'other';

  // ── FSC Streams ──
  static const Map<String, String> fscStreams = {
    'pre_engineering': 'Pre-Engineering',
    'pre_medical': 'Pre-Medical',
    'ics': 'ICS',
    'icom': 'I.Com',
    'fa': 'FA',
    'general_science': 'General Science',
  };

  // ── Application Statuses ──
  static const Map<String, String> applicationStatuses = {
    'interested': 'Interested',
    'preparing': 'Preparing',
    'applied': 'Applied',
    'test_taken': 'Test Taken',
    'interview': 'Interview',
    'selected': 'Selected',
    'rejected': 'Rejected',
    'withdrawn': 'Withdrawn',
  };
}
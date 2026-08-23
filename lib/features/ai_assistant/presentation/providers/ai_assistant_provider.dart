import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Chat Message Model ──

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({required this.id, required this.text, required this.isUser, required this.timestamp});
}

// ── Provider ──

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) => ChatNotifier());

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([
    ChatMessage(
      id: 'welcome',
      text: 'Assalam o Alaikum! 👋 I\'m your UniCompanion AI assistant. Ask me about:\n\n'
          '• University admissions & eligibility\n'
          '• GPA/CGPA calculations\n'
          '• Entry test preparation\n'
          '• Career guidance\n'
          '• Scholarship information\n\n'
          'How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]);

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [...state, userMsg];

    _isTyping = true;
    state = [...state]; // trigger rebuild for typing indicator

    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 800));

    final response = _generateResponse(text.toLowerCase());
    final botMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_bot',
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    _isTyping = false;
    state = [...state, botMsg];
  }

  void clearChat() {
    state = [state.first]; // Keep welcome message
  }

  String _generateResponse(String input) {
    // GPA/CGPA
    if (_matches(input, ['gpa', 'cgpa', 'grade point'])) {
      return 'For GPA calculations:\n\n'
          '• **GPA Calculator** — Go to Tools → GPA Calculator to calculate your semester GPA\n'
          '• **CGPA Calculator** — Use Tools → CGPA Calculator for cumulative GPA across semesters\n'
          '• **Target GPA** — Tools → Target GPA tells you what GPA you need this semester\n\n'
          'Pakistan\'s HEC grading scale:\n'
          'A = 4.0, A- = 3.67, B+ = 3.33, B = 3.0, B- = 2.67, C+ = 2.33, C = 2.0, D = 1.0, F = 0.0\n\n'
          'Most universities require minimum 2.0 CGPA for graduation. Would you like to know more about a specific calculation?';
    }

    // Merit / Aggregate
    if (_matches(input, ['merit', 'aggregate', 'weightage', 'formula'])) {
      return 'Merit/aggregate formulas vary by university:\n\n'
          '• **NUST**: Matric 10% + FSC 15% + NET 75%\n'
          '• **UET**: Matric 10% + FSC 40% + ECAT 50%\n'
          '• **FAST**: FSC 30-40% + NU Entry Test 60-70%\n'
          '• **COMSATS**: Matric 10% + FSC 40% + NTS 50%\n'
          '• **GIKI**: FSC 30% + GIKI Test 70%\n\n'
          'Use our **Merit Calculator** in Tools to calculate your aggregate for any university! 📊';
    }

    // ECAT
    if (_matches(input, ['ecat', 'engineering test', 'uet test'])) {
      return 'ECAT (Engineering College Admission Test):\n\n'
          '• **Subjects**: Physics, Chemistry, Mathematics, English\n'
          '• **Total MCQs**: 100 questions\n'
          '• **Duration**: 100 minutes\n'
          '• **Negative marking**: Yes (-1 for wrong answers)\n'
          '• **Used by**: UET, PU Engineering, NFC-IET, UMT\n\n'
          'Tips: Focus on FSC textbook MCQs, especially past papers. Practice from our **Entry Test Prep** section! 📝';
    }

    // MDCAT
    if (_matches(input, ['mdcat', 'medical test', 'medical college', 'doctor'])) {
      return 'MDCAT (Medical & Dental College Admission Test):\n\n'
          '• **Subjects**: Biology (58%), Chemistry (18%), Physics (18%), English (6%)\n'
          '• **Total MCQs**: 200 questions\n'
          '• **Duration**: 210 minutes (3.5 hours)\n'
          '• **Passing marks**: Typically 55-60%\n'
          '• **Required for**: All public & private medical/dental colleges\n\n'
          'Start practicing from our **Entry Test Prep** → MDCAT section! 🩺';
    }

    // NET / NUST
    if (_matches(input, ['net', 'nust', 'national engineering'])) {
      return 'NUST Entry Test (NET):\n\n'
          '• **Subjects**: Mathematics, Physics, Chemistry, English, Intelligence\n'
          '• **Conducted**: Multiple times per year (3 attempts allowed)\n'
          '• **Best score used**: Your highest NET score is considered\n'
          '• **Weightage**: NET 75% + FSC 15% + Matric 10%\n'
          '• **Apply at**: ugadmissions.nust.edu.pk\n\n'
          'Practice NET questions in our **Entry Test Prep** section! 🎯';
    }

    // Scholarship
    if (_matches(input, ['scholarship', 'financial aid', 'funding', 'fee waiver'])) {
      return 'Scholarship options in Pakistan:\n\n'
          '• **HEC Need-Based** — For students with financial need, covers tuition\n'
          '• **PEEF** — Punjab Educational Endowment Fund for Punjab domicile students\n'
          '• **Ehsaas Scholarship** — Government program for undergraduate students\n'
          '• **University Merit** — Most universities offer merit-based fee waivers (top 5-10%)\n'
          '• **USAID** — Various funded programs for Pakistani students\n\n'
          'Check our **Scholarships** section in Explore for detailed eligibility & deadlines! 💰';
    }

    // Attendance
    if (_matches(input, ['attendance', 'absent', 'classes', 'miss'])) {
      return 'Attendance requirements:\n\n'
          '• Most universities require **75% minimum** attendance\n'
          '• Some strict universities need **80%**\n'
          '• Below minimum → you can be **debarred from exams**\n\n'
          'Use our **Attendance Calculator** in Tools to:\n'
          '• See how many classes you can still miss\n'
          '• Calculate classes needed to reach target %\n'
          '• View best/worst case scenarios\n\n'
          'Stay on top of your attendance! 📋';
    }

    // Career
    if (_matches(input, ['career', 'job', 'profession', 'salary', 'scope'])) {
      return 'For career guidance:\n\n'
          '• Take our **Career Quiz** in Explore to find your best-fit career based on interests\n'
          '• Check **Jobs & Internships** for current opportunities\n'
          '• Use **University Match** to find universities aligned with your career goals\n\n'
          'Top fields in Pakistan by demand:\n'
          '1. Software Engineering & CS\n'
          '2. Data Science & AI\n'
          '3. Healthcare & Medicine\n'
          '4. Business Analytics\n'
          '5. Cyber Security\n\n'
          'Would you like guidance on a specific career path? 🎯';
    }

    // University selection
    if (_matches(input, ['which university', 'best university', 'top university', 'university recommend'])) {
      return 'Top universities in Pakistan (by HEC ranking):\n\n'
          '🏆 **Engineering**: NUST, UET Lahore, GIKI, PIEAS\n'
          '🏆 **CS/IT**: FAST-NUCES, NUST, LUMS, COMSATS\n'
          '🏆 **Medical**: Aga Khan, King Edward, Allama Iqbal\n'
          '🏆 **Business**: LUMS, IBA Karachi, NUST, Lahore School\n'
          '🏆 **General**: QAU, Punjab University, Karachi University\n\n'
          'Use our **University Match** tool (Tools → University Match) for personalized recommendations based on your profile! 🎓';
    }

    // Admission
    if (_matches(input, ['admission', 'apply', 'deadline', 'last date', 'requirements'])) {
      return 'Admission season tips:\n\n'
          '• **NUST**: Applications usually open Jan-Apr, NET tests Feb-Jun\n'
          '• **FAST**: Apply Apr-Jul, test in Jul-Aug\n'
          '• **UET**: ECAT registration May-Jun, test in Jul\n'
          '• **COMSATS**: Rolling admissions, NTS-based\n'
          '• **Medical**: MDCAT in Aug-Sep, merit lists Oct-Nov\n\n'
          'Track your applications in our **Application Tracker** (Track tab)!\n'
          'Check **Eligibility Checker** in Tools to verify requirements. 📅';
    }

    // Greetings
    if (_matches(input, ['hello', 'hi', 'hey', 'salam', 'assalam', 'aoa'])) {
      return 'Wa Alaikum Assalam! 😊 How can I help you today?\n\n'
          'You can ask me about admissions, GPA calculations, test prep, career guidance, or anything related to your academic journey!';
    }

    // Thanks
    if (_matches(input, ['thank', 'thanks', 'shukriya', 'jazak'])) {
      return 'You\'re welcome! 😊 Feel free to ask anything else. I\'m here to help you with your academic journey!';
    }

    // Default
    return 'That\'s a great question! Here are some things I can help with:\n\n'
        '• **"How to calculate GPA?"** — GPA/CGPA guidance\n'
        '• **"Tell me about ECAT"** — Entry test info\n'
        '• **"Best university for CS?"** — University recommendations\n'
        '• **"Scholarship options"** — Financial aid info\n'
        '• **"Career guidance"** — Career paths & quiz\n'
        '• **"Admission deadlines"** — Application timeline\n\n'
        'Try asking about any of these topics! 🎓';
  }

  bool _matches(String input, List<String> keywords) {
    return keywords.any((kw) => input.contains(kw));
  }
}

final isTypingProvider = Provider<bool>((ref) {
  ref.watch(chatProvider); // rebuild when chat changes
  return ref.read(chatProvider.notifier).isTyping;
});
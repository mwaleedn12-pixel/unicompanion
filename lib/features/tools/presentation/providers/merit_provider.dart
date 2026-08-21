import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeritFormula {
  final String name;
  final double matricWeight;
  final double fscWeight;
  final double testWeight;
  final double hafizBonus;

  const MeritFormula({
    required this.name,
    this.matricWeight = 10,
    this.fscWeight = 40,
    this.testWeight = 50,
    this.hafizBonus = 0,
  });
}

const universityFormulas = [
  MeritFormula(name: 'NUST (NET)', matricWeight: 10, fscWeight: 15, testWeight: 75),
  MeritFormula(name: 'UET (ECAT)', matricWeight: 10, fscWeight: 40, testWeight: 50),
  MeritFormula(name: 'FAST (NU Test)', matricWeight: 10, fscWeight: 30, testWeight: 60),
  MeritFormula(name: 'COMSATS (NTS)', matricWeight: 10, fscWeight: 40, testWeight: 50),
  MeritFormula(name: 'GIKI', matricWeight: 10, fscWeight: 15, testWeight: 75),
  MeritFormula(name: 'PIEAS', matricWeight: 10, fscWeight: 15, testWeight: 75),
  MeritFormula(name: 'Air University', matricWeight: 10, fscWeight: 40, testWeight: 50),
  MeritFormula(name: 'Bahria University', matricWeight: 10, fscWeight: 50, testWeight: 40),
  MeritFormula(name: 'IIUI', matricWeight: 10, fscWeight: 40, testWeight: 50),
  MeritFormula(name: 'Punjab University', matricWeight: 10, fscWeight: 50, testWeight: 40, hafizBonus: 20),
  MeritFormula(name: 'Custom', matricWeight: 10, fscWeight: 40, testWeight: 50),
];

class MeritState {
  final int selectedFormulaIndex;
  final double matricMarks;
  final double matricTotal;
  final double fscMarks;
  final double fscTotal;
  final double testMarks;
  final double testTotal;
  final bool isHafiz;
  // Custom weights
  final double customMatricWeight;
  final double customFscWeight;
  final double customTestWeight;

  const MeritState({
    this.selectedFormulaIndex = 0,
    this.matricMarks = 0,
    this.matricTotal = 1100,
    this.fscMarks = 0,
    this.fscTotal = 1100,
    this.testMarks = 0,
    this.testTotal = 200,
    this.isHafiz = false,
    this.customMatricWeight = 10,
    this.customFscWeight = 40,
    this.customTestWeight = 50,
  });

  MeritState copyWith({
    int? selectedFormulaIndex, double? matricMarks, double? matricTotal,
    double? fscMarks, double? fscTotal, double? testMarks, double? testTotal,
    bool? isHafiz, double? customMatricWeight, double? customFscWeight, double? customTestWeight,
  }) {
    return MeritState(
      selectedFormulaIndex: selectedFormulaIndex ?? this.selectedFormulaIndex,
      matricMarks: matricMarks ?? this.matricMarks,
      matricTotal: matricTotal ?? this.matricTotal,
      fscMarks: fscMarks ?? this.fscMarks,
      fscTotal: fscTotal ?? this.fscTotal,
      testMarks: testMarks ?? this.testMarks,
      testTotal: testTotal ?? this.testTotal,
      isHafiz: isHafiz ?? this.isHafiz,
      customMatricWeight: customMatricWeight ?? this.customMatricWeight,
      customFscWeight: customFscWeight ?? this.customFscWeight,
      customTestWeight: customTestWeight ?? this.customTestWeight,
    );
  }

  MeritFormula get formula => universityFormulas[selectedFormulaIndex];
  bool get isCustom => formula.name == 'Custom';

  double get _matricW => isCustom ? customMatricWeight : formula.matricWeight;
  double get _fscW => isCustom ? customFscWeight : formula.fscWeight;
  double get _testW => isCustom ? customTestWeight : formula.testWeight;

  double get matricPercentage => matricTotal > 0 ? (matricMarks / matricTotal) * 100 : 0;
  double get fscPercentage => fscTotal > 0 ? (fscMarks / fscTotal) * 100 : 0;
  double get testPercentage => testTotal > 0 ? (testMarks / testTotal) * 100 : 0;

  double get aggregate {
    final matric = matricPercentage * _matricW / 100;
    final fsc = fscPercentage * _fscW / 100;
    final test = testPercentage * _testW / 100;
    final bonus = isHafiz ? formula.hafizBonus : 0;
    return matric + fsc + test + bonus;
  }

  bool get hasData => matricMarks > 0 || fscMarks > 0 || testMarks > 0;

  String get aggregateVerdict {
    if (!hasData) return '';
    if (aggregate >= 85) return 'Excellent! Strong chance at top unis 🏆';
    if (aggregate >= 75) return 'Very Good! Competitive for most programs 💪';
    if (aggregate >= 65) return 'Good — check specific merit cutoffs 📊';
    if (aggregate >= 55) return 'Average — consider backup options';
    return 'Below average — focus on entry test prep';
  }
}

final meritProvider = StateNotifierProvider<MeritNotifier, MeritState>((ref) {
  return MeritNotifier();
});

class MeritNotifier extends StateNotifier<MeritState> {
  MeritNotifier() : super(const MeritState());

  void setFormula(int index) => state = state.copyWith(selectedFormulaIndex: index);
  void setMatricMarks(double v) => state = state.copyWith(matricMarks: v);
  void setMatricTotal(double v) => state = state.copyWith(matricTotal: v);
  void setFscMarks(double v) => state = state.copyWith(fscMarks: v);
  void setFscTotal(double v) => state = state.copyWith(fscTotal: v);
  void setTestMarks(double v) => state = state.copyWith(testMarks: v);
  void setTestTotal(double v) => state = state.copyWith(testTotal: v);
  void setHafiz(bool v) => state = state.copyWith(isHafiz: v);
  void setCustomMatricWeight(double v) => state = state.copyWith(customMatricWeight: v);
  void setCustomFscWeight(double v) => state = state.copyWith(customFscWeight: v);
  void setCustomTestWeight(double v) => state = state.copyWith(customTestWeight: v);
  void reset() => state = const MeritState();
}
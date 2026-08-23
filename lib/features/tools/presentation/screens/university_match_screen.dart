import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../explore/presentation/providers/explore_provider.dart';
import '../../../explore/data/models/university_model.dart';

class UniversityMatchScreen extends ConsumerStatefulWidget {
  const UniversityMatchScreen({super.key});

  @override
  ConsumerState<UniversityMatchScreen> createState() => _UniversityMatchScreenState();
}

class _UniversityMatchScreenState extends ConsumerState<UniversityMatchScreen> {
  int _step = 0; // 0-4 = questions, 5 = results
  final _answers = <String, dynamic>{};

  // Questions
  static const _questions = [
    {
      'key': 'uni_type',
      'question': 'What type of university do you prefer?',
      'subtitle': 'Public universities are government-funded, private are independently operated',
      'type': 'single',
      'options': ['Public', 'Private', 'No Preference'],
    },
    {
      'key': 'field',
      'question': 'Which field interests you the most?',
      'subtitle': 'This helps match universities with strong programs in your area',
      'type': 'single',
      'options': ['Engineering & Technology', 'Medical & Health Sciences', 'Computer Science & IT', 'Business & Management', 'Natural Sciences', 'Social Sciences & Arts'],
    },
    {
      'key': 'city',
      'question': 'Which city would you prefer?',
      'subtitle': 'Select your preferred location for studies',
      'type': 'multi',
      'options': ['Islamabad', 'Lahore', 'Karachi', 'Peshawar', 'Rawalpindi', 'Faisalabad', 'Any City'],
    },
    {
      'key': 'priority',
      'question': 'What matters most to you?',
      'subtitle': 'Pick the most important factor',
      'type': 'single',
      'options': ['National Ranking', 'Affordable Fees', 'Campus Facilities', 'Research Opportunities', 'Industry Connections'],
    },
    {
      'key': 'budget',
      'question': 'What is your budget per semester?',
      'subtitle': 'Approximate fee range you can afford',
      'type': 'single',
      'options': ['Under 50K', '50K - 100K', '100K - 200K', '200K - 500K', '500K+'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
                  const SizedBox(width: 4),
                  Expanded(child: Text('University Match', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
            ),

            if (_step < _questions.length) ...[
              // Progress
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: List.generate(_questions.length, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _step ? AppColors.primary : AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),

              // Question
              Expanded(child: _buildQuestion(context)),
            ] else
              Expanded(child: _buildResults(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final q = _questions[_step];
    final key = q['key'] as String;
    final options = q['options'] as List<String>;
    final isMulti = q['type'] == 'multi';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question ${_step + 1} of ${_questions.length}', style: TextStyle(fontSize: 13, color: AppColors.textTertiaryLight)),
          const SizedBox(height: 8),
          Text(q['question'] as String, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(q['subtitle'] as String, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
          if (isMulti) const Padding(padding: EdgeInsets.only(top: 4), child: Text('(Select all that apply)', style: TextStyle(fontSize: 12, color: AppColors.primary))),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, i) {
                final option = options[i];
                bool isSelected;
                if (isMulti) {
                  final selected = (_answers[key] as List<String>?) ?? [];
                  isSelected = selected.contains(option);
                } else {
                  isSelected = _answers[key] == option;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isMulti) {
                        final list = List<String>.from((_answers[key] as List<String>?) ?? []);
                        if (option == 'Any City') {
                          _answers[key] = ['Any City'];
                        } else {
                          list.remove('Any City');
                          isSelected ? list.remove(option) : list.add(option);
                          _answers[key] = list;
                        }
                      } else {
                        _answers[key] = option;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withValues(alpha: 0.15), width: isSelected ? 2 : 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(isMulti ? 6 : 12),
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.textTertiaryLight, width: 2),
                          ),
                          child: isSelected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(option, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Nav buttons
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _step--),
                    child: const Text('Back'),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canProceed(key, isMulti) ? () => setState(() => _step++) : null,
                    child: Text(_step == _questions.length - 1 ? 'See Matches' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canProceed(String key, bool isMulti) {
    if (isMulti) {
      final list = (_answers[key] as List<String>?) ?? [];
      return list.isNotEmpty;
    }
    return _answers[key] != null;
  }

  Widget _buildResults(BuildContext context) {
    final uniState = ref.watch(universitiesProvider);

    return uniState.when(
      initial: () => const AppLoadingIndicator(),
      loading: () => const AppLoadingIndicator(message: 'Finding matches...'),
      error: (msg) => AppErrorView(message: msg),
      success: (universities) {
        final scored = _scoreUniversities(universities);

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Matches', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Based on your preferences', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight)),
              const SizedBox(height: 16),

              Expanded(
                child: scored.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiaryLight),
                            const SizedBox(height: 12),
                            Text('No exact matches found', style: Theme.of(context).textTheme.titleSmall),
                            const SizedBox(height: 4),
                            Text('Try adjusting your preferences', style: TextStyle(color: AppColors.textSecondaryLight)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: scored.length,
                        itemBuilder: (context, i) {
                          final entry = scored[i];
                          final uni = entry.university;
                          final match = entry.matchPercent;

                          return GestureDetector(
                            onTap: () => context.push('/explore/university/${uni.id}'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: i == 0 ? AppColors.primary.withValues(alpha: 0.3) : Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
                                  width: i == 0 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Match % circle
                                  SizedBox(
                                    width: 52, height: 52,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: match / 100,
                                          strokeWidth: 4,
                                          backgroundColor: AppColors.dividerLight,
                                          valueColor: AlwaysStoppedAnimation(_matchColor(match)),
                                        ),
                                        Text('${match.toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _matchColor(match))),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (i == 0)
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Best Match', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                          ),
                                        Text(uni.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 2),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(uni.typeLabel, style: TextStyle(fontSize: 12, color: uni.type == 'public' ? AppColors.primary : AppColors.secondary)),
                                            if (uni.rankingNational != null) ...[
                                              const Text(' · ', style: TextStyle(color: AppColors.textTertiaryLight)),
                                              Text('Rank #${uni.rankingNational}', style: const TextStyle(fontSize: 12, color: AppColors.textTertiaryLight)),
                                            ],
                                          ],
                                        ),
                                        // Match reasons
                                        const SizedBox(height: 4),
                                        Text(entry.reasons.join(' · '), style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiaryLight),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // Retake
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _step = 0;
                    _answers.clear();
                  }),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retake Questionnaire'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_ScoredUniversity> _scoreUniversities(List<UniversityModel> universities) {
    final results = <_ScoredUniversity>[];

    for (final uni in universities) {
      double score = 0;
      double maxScore = 0;
      final reasons = <String>[];

      // Type preference (20 points)
      maxScore += 20;
      final typePref = _answers['uni_type'] as String?;
      if (typePref == 'No Preference' || typePref == null) {
        score += 20;
      } else if (typePref == 'Public' && uni.type == 'public' || typePref == 'Private' && uni.type == 'private') {
        score += 20;
        reasons.add('✓ ${uni.typeLabel}');
      }

      // Ranking priority (25 points)
      maxScore += 25;
      final priority = _answers['priority'] as String?;
      if (priority == 'National Ranking' && uni.rankingNational != null) {
        if (uni.rankingNational! <= 5) {
          score += 25;
          reasons.add('✓ Top 5');
        } else if (uni.rankingNational! <= 15) {
          score += 18;
          reasons.add('✓ Top 15');
        } else {
          score += 10;
        }
      } else if (priority != 'National Ranking') {
        // Give some base score if ranking isn't priority
        score += 12;
      }

      // City match (25 points)
      maxScore += 25;
      final cities = (_answers['city'] as List<String>?) ?? [];
      if (cities.contains('Any City') || cities.isEmpty) {
        score += 25;
      } else {
        // Check university city from description or name (simplified — real impl would use campus data)
        final uniInfo = '${uni.name} ${uni.description ?? ''}'.toLowerCase();
        for (final city in cities) {
          if (uniInfo.contains(city.toLowerCase())) {
            score += 25;
            reasons.add('✓ $city');
            break;
          }
        }
      }

      // Field match (20 points) — simplified based on university name/description
      maxScore += 20;
      final field = _answers['field'] as String?;
      if (field != null) {
        final uniInfo = '${uni.name} ${uni.description ?? ''}'.toLowerCase();
        final fieldKeywords = _fieldKeywords(field);
        for (final kw in fieldKeywords) {
          if (uniInfo.contains(kw)) {
            score += 20;
            reasons.add('✓ $field');
            break;
          }
        }
        // Base score for general universities
        if (!reasons.any((r) => r.contains(field))) score += 8;
      }

      // Budget match (10 points) — simplified
      maxScore += 10;
      final budget = _answers['budget'] as String?;
      if (budget != null) {
        if (uni.type == 'public' && (budget == 'Under 50K' || budget == '50K - 100K')) {
          score += 10;
          reasons.add('✓ Budget-friendly');
        } else if (uni.type == 'private' && (budget == '200K - 500K' || budget == '500K+')) {
          score += 10;
        } else {
          score += 5;
        }
      }

      final percent = maxScore > 0 ? (score / maxScore) * 100 : 0.0;
      if (percent >= 30) {
        results.add(_ScoredUniversity(university: uni, matchPercent: percent, reasons: reasons));
      }
    }

    results.sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
    return results.take(10).toList();
  }

  List<String> _fieldKeywords(String field) {
    switch (field) {
      case 'Engineering & Technology': return ['engineering', 'technology', 'uet', 'nust', 'giki', 'pieas'];
      case 'Medical & Health Sciences': return ['medical', 'health', 'aku', 'king edward', 'allama iqbal'];
      case 'Computer Science & IT': return ['computer', 'information', 'it', 'fast', 'comsats', 'nust'];
      case 'Business & Management': return ['business', 'management', 'lums', 'iba', 'lahore school'];
      case 'Natural Sciences': return ['science', 'quaid', 'punjab', 'karachi'];
      case 'Social Sciences & Arts': return ['social', 'arts', 'humanities', 'forman', 'beaconhouse'];
      default: return [];
    }
  }

  Color _matchColor(double percent) {
    if (percent >= 70) return AppColors.success;
    if (percent >= 40) return AppColors.accent;
    return AppColors.textTertiaryLight;
  }
}

class _ScoredUniversity {
  final UniversityModel university;
  final double matchPercent;
  final List<String> reasons;
  const _ScoredUniversity({required this.university, required this.matchPercent, required this.reasons});
}
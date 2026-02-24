import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exercise.dart';
import '../../data/models/training_schedule.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/constants/exercises_data.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/exercise_detail_sheet.dart';

class ProgramSetupScreen extends ConsumerStatefulWidget {
  const ProgramSetupScreen({super.key});

  @override
  ConsumerState<ProgramSetupScreen> createState() =>
      _ProgramSetupScreenState();
}

class _ProgramSetupScreenState extends ConsumerState<ProgramSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '計畫設定',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '我的程度'),
            Tab(text: '訓練計畫'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProgressionTab(),
          _ScheduleTab(),
        ],
      ),
    );
  }
}

// ─── Progression Tab ─────────────────────────────────────────────────────────

class _ProgressionTab extends ConsumerWidget {
  const _ProgressionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: ExerciseType.values.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return const _TierQuickSet();
        final type = ExerciseType.values[index - 1];
        final currentStep = progression.stepFor(type);
        return _ExerciseStepCard(type: type, currentStep: currentStep);
      },
    );
  }
}

// ─── Tier quick-set ───────────────────────────────────────────────────────────

class _TierQuickSet extends ConsumerWidget {
  const _TierQuickSet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速設定全部',
          style:
              theme.textTheme.labelMedium?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
              child: _TierButton(
                label: '入門',
                subtitle: '第 1 式',
                step: 1,
                color: kTierBeginner,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _TierButton(
                label: '中級',
                subtitle: '第 5 式',
                step: 5,
                color: kTierMid,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _TierButton(
                label: '進階',
                subtitle: '第 8 式',
                step: 8,
                color: kTierAdvanced,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _TierButton extends ConsumerWidget {
  const _TierButton({
    required this.label,
    required this.subtitle,
    required this.step,
    required this.color,
  });

  final String label;
  final String subtitle;
  final int step;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(progressionProvider.notifier).setAllSteps(step),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseStepCard extends ConsumerWidget {
  const _ExerciseStepCard({
    required this.type,
    required this.currentStep,
  });

  final ExerciseType type;
  final int currentStep;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = exerciseForType(type);
    final step = exercise.stepAt(currentStep);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(exercise.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                exercise.nameZh,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '第 $currentStep / 10 式',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              // Info button — opens exercise detail sheet with photo
              GestureDetector(
                onTap: () =>
                    ExerciseDetailSheet.show(context, type, currentStep),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.white38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            step.nameZh,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          // Step slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              thumbColor: theme.colorScheme.primary,
              inactiveTrackColor: Colors.white12,
              overlayColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: currentStep.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                ref
                    .read(progressionProvider.notifier)
                    .setStep(type, value.round());
              },
            ),
          ),
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              10,
              (i) {
                final stepNum = i + 1;
                final active = stepNum == currentStep;
                return GestureDetector(
                  onTap: () => ref
                      .read(progressionProvider.notifier)
                      .setStep(type, stepNum),
                  child: Column(
                    children: [
                      Container(
                        width: active ? 24 : 18,
                        height: active ? 24 : 18,
                        decoration: BoxDecoration(
                          color: stepNum <= currentStep
                              ? theme.colorScheme.primary
                              : Colors.white12,
                          shape: BoxShape.circle,
                          border: active
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$stepNum',
                          style: TextStyle(
                            fontSize: active ? 11 : 9,
                            color: Colors.white,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          // Progression target info
          _ProgressionStandard(step: step),
        ],
      ),
    );
  }
}

class _ProgressionStandard extends StatelessWidget {
  const _ProgressionStandard({required this.step});

  final dynamic step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '晉級標準',
            style: theme.textTheme.labelMedium
                ?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _StandardChip(
                  label: '入門', value: step.beginner.display, color: Colors.green),
              const SizedBox(width: 8),
              _StandardChip(
                  label: '中級',
                  value: step.intermediate.display,
                  color: Colors.orange),
              const SizedBox(width: 8),
              _StandardChip(
                  label: '晉級',
                  value: step.progression.display,
                  color: theme.colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StandardChip extends StatelessWidget {
  const _StandardChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }
}

// ─── Schedule Tab ─────────────────────────────────────────────────────────────

class _ScheduleTab extends ConsumerWidget {
  const _ScheduleTab();

  static const List<String> _weekdays = [
    '', '週一', '週二', '週三', '週四', '週五', '週六', '週日',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '設定每週訓練日，以及當天要訓練的動作。',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 20),
        ...List.generate(7, (i) {
          final weekday = i + 1;
          final daySchedule = schedule.days
              .where((d) => d.weekday == weekday)
              .firstOrNull;
          return _DayScheduleCard(
            weekday: weekday,
            weekdayName: _weekdays[weekday],
            daySchedule: daySchedule,
          );
        }),
      ],
    );
  }
}

class _DayScheduleCard extends ConsumerStatefulWidget {
  const _DayScheduleCard({
    required this.weekday,
    required this.weekdayName,
    this.daySchedule,
  });

  final int weekday;
  final String weekdayName;
  final DaySchedule? daySchedule;

  @override
  ConsumerState<_DayScheduleCard> createState() => _DayScheduleCardState();
}

class _DayScheduleCardState extends ConsumerState<_DayScheduleCard> {
  bool _expanded = false;

  bool get _isTrainingDay => widget.daySchedule != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = DateTime.now().weekday == widget.weekday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isToday
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _isTrainingDay
                          ? theme.colorScheme.primary
                          : Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.weekdayName.substring(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isTrainingDay ? Colors.white : Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.weekdayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isToday)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '今天',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (_isTrainingDay && widget.daySchedule != null)
                          Text(
                            widget.daySchedule!.exercises
                                .map((e) => e.nameZh)
                                .join('、'),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white54),
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            '休息日',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white38),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isTrainingDay,
                    activeThumbColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      if (val) {
                        ref.read(scheduleProvider.notifier).updateDay(
                              DaySchedule(
                                  weekday: widget.weekday, exercises: []),
                            );
                        setState(() => _expanded = true);
                      } else {
                        ref
                            .read(scheduleProvider.notifier)
                            .removeDay(widget.weekday);
                        setState(() => _expanded = false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          // Exercise selector
          if (_isTrainingDay && _expanded)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _ExerciseSelector(
                weekday: widget.weekday,
                selected:
                    widget.daySchedule?.exercises ?? [],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseSelector extends ConsumerWidget {
  const _ExerciseSelector({
    required this.weekday,
    required this.selected,
  });

  final int weekday;
  final List<ExerciseType> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExerciseType.values.map((type) {
        final isSelected = selected.contains(type);
        return GestureDetector(
          onTap: () {
            final newList = List<ExerciseType>.from(selected);
            if (isSelected) {
              newList.remove(type);
            } else {
              newList.add(type);
            }
            ref.read(scheduleProvider.notifier).updateDay(
                  DaySchedule(weekday: weekday, exercises: newList),
                );
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.white24,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(type.emoji,
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  type.nameZh,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

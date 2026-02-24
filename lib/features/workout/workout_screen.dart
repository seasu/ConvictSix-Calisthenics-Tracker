import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/exercise.dart';
import '../../data/models/workout_session.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/constants/exercises_data.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/exercise_detail_sheet.dart';

const _uuid = Uuid();

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeWorkoutProvider);
    return activeSession == null
        ? const _NoActiveWorkoutView()
        : _ActiveWorkoutView(session: activeSession);
  }
}

// ─── No active workout ────────────────────────────────────────────────────────

class _NoActiveWorkoutView extends ConsumerWidget {
  const _NoActiveWorkoutView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);
    final progression = ref.watch(progressionProvider);
    final todayExercises = schedule.todaysExercises;

    return Scaffold(
      appBar: AppBar(title: const Text('訓練')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          // Today's plan preview
          if (todayExercises.isNotEmpty) ...[
            const _SectionLabel('今日計畫'),
            const SizedBox(height: 10),
            ...todayExercises.map(
              (type) => _PlanRow(
                  type: type,
                  step: progression.stepFor(type)),
            ),
            const SizedBox(height: 24),
          ] else ...[
            _RestDayInfo(),
            const SizedBox(height: 24),
          ],
          // CTA
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  ref.read(activeWorkoutProvider.notifier).startWorkout(),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('開始訓練'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends ConsumerWidget {
  const _PlanRow({required this.type, required this.step});

  final ExerciseType type;
  final int step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = exerciseForType(type);
    final stepInfo = exercise.stepAt(step);
    final tierColor = stepTierColor(step);
    final trainingLevel =
        ref.watch(progressionProvider).trainingLevelFor(type);
    final targetStandard = trainingLevel == 0
        ? stepInfo.beginner
        : trainingLevel == 1
            ? stepInfo.intermediate
            : stepInfo.progression;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                'assets/images/exercises/${type.name}_${step.toString().padLeft(2, '0')}.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: tierColor.withValues(alpha: 0.12),
                  child: Center(
                    child: Text(exercise.emoji,
                        style: const TextStyle(fontSize: 20)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.nameZh,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '第$step式 · ${stepInfo.nameZh}',
                  style: const TextStyle(
                      fontSize: 12, color: kTextSecondary),
                ),
              ],
            ),
          ),
          Text(
            targetStandard.display,
            style: TextStyle(
              fontSize: 12,
              color: tierColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RestDayInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle),
      ),
      child: const Column(
        children: [
          Text('😴', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            '今天是休息日',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary),
          ),
          SizedBox(height: 6),
          Text(
            '適當休息有助肌肉恢復與成長。\n如需訓練，仍可隨時開始。',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: kTextSecondary, height: 1.6, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Active workout ───────────────────────────────────────────────────────────

class _ActiveWorkoutView extends ConsumerWidget {
  const _ActiveWorkoutView({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final schedule = ref.watch(scheduleProvider);
    final todayExercises = schedule.todaysExercises;

    final loggedExercises = session.exercises;
    final allExercises = [
      ...todayExercises,
      ...loggedExercises.where((e) => !todayExercises.contains(e)),
    ];
    final exercisesToShow =
        allExercises.isEmpty ? ExerciseType.values.toList() : allExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text('訓練中'),
        actions: [
          TextButton(
            onPressed: () => _confirmDiscard(context, ref),
            child: const Text('放棄',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: exercisesToShow.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final type = exercisesToShow[index];
                final step = progression.stepFor(type);
                final sets = session.sets
                    .where((s) => s.exercise == type)
                    .toList();
                return _ExerciseBlock(
                    type: type, currentStep: step, sets: sets);
              },
            ),
          ),
          // ── Finish button ──────────────────────────────────────────────
          Container(
            color: kBgBase,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: session.sets.isEmpty
                    ? null
                    : () => _confirmFinish(context, ref),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text('完成訓練（${session.sets.length} 組）'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFinish(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('完成訓練'),
        content: Text('共記錄 ${session.sets.length} 組，確定儲存？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('繼續訓練'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('儲存完成'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
    }
  }

  Future<void> _confirmDiscard(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('放棄訓練'),
        content: const Text('本次所有記錄將被刪除，確定放棄？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('繼續'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('放棄'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(activeWorkoutProvider.notifier).discardWorkout();
    }
  }
}

// ─── Exercise block ───────────────────────────────────────────────────────────

class _ExerciseBlock extends ConsumerStatefulWidget {
  const _ExerciseBlock({
    required this.type,
    required this.currentStep,
    required this.sets,
  });

  final ExerciseType type;
  final int currentStep;
  final List<WorkoutSet> sets;

  @override
  ConsumerState<_ExerciseBlock> createState() => _ExerciseBlockState();
}

class _ExerciseBlockState extends ConsumerState<_ExerciseBlock> {
  // Quick-add options: reps and hold (seconds) variants
  static const List<int> _quickReps = [5, 8, 10, 12, 15, 20];
  static const List<int> _quickHolds = [10, 20, 30, 45, 60, 90];

  bool _showCustomInput = false;
  final _repsController = TextEditingController();

  late bool _isHoldStep;

  @override
  void initState() {
    super.initState();
    final exercise = exerciseForType(widget.type);
    _isHoldStep = exercise.stepAt(widget.currentStep).progression.isHold;
  }

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  Future<void> _logValue(int value) async {
    HapticFeedback.lightImpact();
    final workoutSet = WorkoutSet(
      id: _uuid.v4(),
      exercise: widget.type,
      stepNumber: widget.currentStep,
      reps: _isHoldStep ? 0 : value,
      holdSeconds: _isHoldStep ? value : 0,
      timestamp: DateTime.now(),
    );
    await ref.read(activeWorkoutProvider.notifier).logSet(workoutSet);
  }

  Future<void> _logCustom() async {
    final val = int.tryParse(_repsController.text.trim());
    if (val == null || val <= 0) return;
    await _logValue(val);
    _repsController.clear();
    setState(() => _showCustomInput = false);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exerciseForType(widget.type);
    final step = exercise.stepAt(widget.currentStep);
    final tierColor = stepTierColor(widget.currentStep);
    final quickValues = _isHoldStep ? _quickHolds : _quickReps;
    final unit = _isHoldStep ? '秒' : '下';
    // Highlight the target based on the selected training level
    final trainingLevel =
        ref.watch(progressionProvider).trainingLevelFor(widget.type);
    final targetStandard = trainingLevel == 0
        ? step.beginner
        : trainingLevel == 1
            ? step.intermediate
            : step.progression;
    final targetValue =
        _isHoldStep ? targetStandard.holdSeconds : targetStandard.reps;

    final imagePath =
        'assets/images/exercises/${exercise.type.name}_${widget.currentStep.toString().padLeft(2, '0')}.jpg';

    return Container(
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Exercise image banner ────────────────────────────────────────
          GestureDetector(
            onTap: () => ExerciseDetailSheet.show(
                context, widget.type, widget.currentStep),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: tierColor.withValues(alpha: 0.08),
                    child: Center(
                      child: Text(exercise.emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.nameZh,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: kTextPrimary,
                            ),
                          ),
                          Text(
                            '第${widget.currentStep}式 · ${step.nameZh}',
                            style: const TextStyle(
                                fontSize: 12, color: kTextSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Target (reflects selected training level)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('目標',
                            style: TextStyle(
                                fontSize: 10, color: kTextTertiary)),
                        Text(
                          targetStandard.display,
                          style: TextStyle(
                            fontSize: 12,
                            color: tierColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          // ── Logged set pills ────────────────────────────────────────────
          if (widget.sets.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.sets.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: tierColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    '第${i + 1}組  ${s.displayReps}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: tierColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Quick-add buttons ───────────────────────────────────────────
          if (!_showCustomInput) ...[
            Row(
              children: [
                const Text(
                  '快速記錄',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kTextTertiary,
                    letterSpacing: 0.4,
                  ),
                ),
                const Spacer(),
                // Undo last set
                if (widget.sets.isNotEmpty)
                  GestureDetector(
                    onTap: () => ref
                        .read(activeWorkoutProvider.notifier)
                        .removeLastSet(widget.type),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo_rounded,
                            size: 14, color: kTextTertiary),
                        SizedBox(width: 3),
                        Text(
                          '撤銷',
                          style: TextStyle(
                              fontSize: 12, color: kTextTertiary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Quick-tap value buttons
            Row(
              children: [
                ...quickValues.map((v) {
                  final isTarget = v == targetValue;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _QuickButton(
                        value: v,
                        unit: unit,
                        isTarget: isTarget,
                        tierColor: tierColor,
                        onTap: () => _logValue(v),
                      ),
                    ),
                  );
                }),
                // Custom button
                _QuickButton(
                  value: -1,
                  unit: unit,
                  isTarget: false,
                  tierColor: tierColor,
                  label: '自訂',
                  onTap: () => setState(() {
                    _showCustomInput = true;
                    _repsController.clear();
                  }),
                ),
              ],
            ),
          ] else ...[
            // ── Custom input ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: _isHoldStep ? '秒數' : '下數',
                      suffixText: unit,
                      suffixStyle: const TextStyle(
                          color: kTextSecondary, fontSize: 14),
                    ),
                    onSubmitted: (_) => _logCustom(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _logCustom,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  child: const Text('記錄'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _showCustomInput = false),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: kBgSurface2,
                    foregroundColor: kTextSecondary,
                  ),
                ),
              ],
            ),
          ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick-add button ─────────────────────────────────────────────────────────

class _QuickButton extends StatelessWidget {
  const _QuickButton({
    required this.value,
    required this.unit,
    required this.isTarget,
    required this.tierColor,
    required this.onTap,
    this.label,
  });

  final int value;
  final String unit;
  final bool isTarget;
  final Color tierColor;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = label ?? '$value';
    final isSpecial = label != null; // "自訂" button

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 44,
        decoration: BoxDecoration(
          color: isTarget
              ? tierColor.withValues(alpha: 0.18)
              : isSpecial
                  ? kBgSurface3
                  : kBgSurface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isTarget
                ? tierColor.withValues(alpha: 0.6)
                : kBorderDefault,
            width: isTarget ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            displayLabel,
            style: TextStyle(
              fontSize: isSpecial ? 12 : 14,
              fontWeight: isTarget ? FontWeight.w800 : FontWeight.w600,
              color: isTarget
                  ? tierColor
                  : isSpecial
                      ? kTextSecondary
                      : kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kTextTertiary,
        letterSpacing: 0.6,
      ),
    );
  }
}

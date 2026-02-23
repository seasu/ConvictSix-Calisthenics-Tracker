import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/exercise.dart';
import '../../data/models/workout_session.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/constants/exercises_data.dart';
import '../../shared/widgets/set_log_tile.dart';

const _uuid = Uuid();

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeWorkoutProvider);

    if (activeSession == null) {
      return const _NoActiveWorkoutView();
    }
    return _ActiveWorkoutView(session: activeSession);
  }
}

// ─── No active workout ────────────────────────────────────────────────────────

class _NoActiveWorkoutView extends ConsumerWidget {
  const _NoActiveWorkoutView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(scheduleProvider);
    final todayExercises = schedule.todaysExercises;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '訓練',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todayExercises.isNotEmpty) ...[
              Text(
                '今日計畫',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _TodayPlanList(exercises: todayExercises),
              const SizedBox(height: 24),
            ] else ...[
              _RestDayInfo(),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () =>
                    ref.read(activeWorkoutProvider.notifier).startWorkout(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('開始訓練'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayPlanList extends ConsumerWidget {
  const _TodayPlanList({required this.exercises});

  final List<ExerciseType> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final theme = Theme.of(context);

    return Column(
      children: exercises.map((type) {
        final exercise = exerciseForType(type);
        final step = progression.stepFor(type);
        final stepInfo = exercise.stepAt(step);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text(exercise.emoji,
                  style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nameZh,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '第$step式 · ${stepInfo.nameZh}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Text(
                stepInfo.progression.display,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RestDayInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text('😴', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text(
            '今天是休息日',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            '適當休息有助肌肉恢復與成長。\n如需訓練，可隨時手動開始。',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white54, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Active workout ────────────────────────────────────────────────────────────

class _ActiveWorkoutView extends ConsumerWidget {
  const _ActiveWorkoutView({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final schedule = ref.watch(scheduleProvider);
    final todayExercises = schedule.todaysExercises;

    // Exercises to show: today's scheduled ones + any already logged ones
    final loggedExercises = session.exercises;
    final allExercises = [
      ...todayExercises,
      ...loggedExercises.where((e) => !todayExercises.contains(e)),
    ];
    // If nothing scheduled and nothing logged yet, show all six
    final exercisesToShow = allExercises.isEmpty
        ? ExerciseType.values.toList()
        : allExercises;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '訓練中',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmDiscard(context, ref),
            child: const Text(
              '放棄',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: exercisesToShow.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final type = exercisesToShow[index];
                final step = progression.stepFor(type);
                final sets = session.sets
                    .where((s) => s.exercise == type)
                    .toList();
                return _ExerciseBlock(
                  type: type,
                  currentStep: step,
                  sets: sets,
                );
              },
            ),
          ),
          // Finish button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: session.sets.isEmpty
                    ? null
                    : () => _confirmFinish(context, ref),
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  '完成訓練（${session.sets.length} 組）',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
        content: Text(
            '本次訓練共記錄了 ${session.sets.length} 組，確定儲存並結束？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('繼續訓練')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('儲存完成')),
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
        content: const Text('所有本次記錄將被刪除，確定放棄？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('繼續')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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

// ─── Exercise block within active workout ────────────────────────────────────

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
  final _repsController = TextEditingController();
  bool _showInput = false;
  bool _isHold = false;

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  void _toggleInput() => setState(() {
        _showInput = !_showInput;
        if (_showInput) _repsController.clear();
      });

  Future<void> _logSet() async {
    final val = int.tryParse(_repsController.text.trim());
    if (val == null || val <= 0) return;

    final workoutSet = WorkoutSet(
      id: _uuid.v4(),
      exercise: widget.type,
      stepNumber: widget.currentStep,
      reps: _isHold ? 0 : val,
      holdSeconds: _isHold ? val : 0,
      timestamp: DateTime.now(),
    );

    await ref.read(activeWorkoutProvider.notifier).logSet(workoutSet);
    _repsController.clear();
    setState(() => _showInput = false);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exerciseForType(widget.type);
    final step = exercise.stepAt(widget.currentStep);
    final theme = Theme.of(context);
    final isHoldStep = step.progression.isHold;

    if (!_isHold && isHoldStep) {
      _isHold = true;
    }

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
              Text(exercise.emoji,
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nameZh,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '第${widget.currentStep}式 · ${step.nameZh}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              // Target info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '目標',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.white38),
                  ),
                  Text(
                    step.progression.display,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Logged sets
          if (widget.sets.isNotEmpty) ...[
            ...widget.sets.asMap().entries.map(
                  (e) => SetLogTile(
                      setNumber: e.key + 1, workoutSet: e.value),
                ),
            const SizedBox(height: 4),
          ],
          // Input area
          if (_showInput) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                // Hold / Reps toggle
                GestureDetector(
                  onTap: () => setState(() => _isHold = !_isHold),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isHold ? '秒' : '下',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: _isHold ? '秒數' : '下數',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _logSet(),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _logSet,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                  child: const Text('記錄'),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: _toggleInput,
                  icon: const Icon(Icons.close, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _toggleInput,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    widget.sets.isEmpty ? '記錄第一組' : '新增一組',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.5)),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                  ),
                ),
                if (widget.sets.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => ref
                        .read(activeWorkoutProvider.notifier)
                        .removeLastSet(widget.type),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('撤銷最後一組',
                        style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white38,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

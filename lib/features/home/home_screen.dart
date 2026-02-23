import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/exercise.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/widgets/exercise_progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final schedule = ref.watch(scheduleProvider);
    final activeSession = ref.watch(activeWorkoutProvider);
    final todayExercises = schedule.todaysExercises;

    final dateStr =
        DateFormat('yyyy年MM月dd日 EEEE', 'zh_TW').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ConvictSix',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Active session banner
                    if (activeSession != null)
                      _ActiveSessionBanner(session: activeSession),
                    // Today's schedule summary
                    if (todayExercises.isNotEmpty)
                      _TodayScheduleSummary(exercises: todayExercises)
                    else
                      _RestDayCard(),
                    const SizedBox(height: 24),
                    Text(
                      '我的六招進度',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final type = ExerciseType.values[index];
                    return ExerciseProgressCard(
                      type: type,
                      currentStep: progression.stepFor(type),
                      isScheduledToday: todayExercises.contains(type),
                    );
                  },
                  childCount: ExerciseType.values.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.session});

  final dynamic session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '訓練進行中，請前往訓練頁面繼續記錄',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}

class _TodayScheduleSummary extends StatelessWidget {
  const _TodayScheduleSummary({required this.exercises});

  final List<ExerciseType> exercises;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, size: 16, color: theme.colorScheme.secondary),
              const SizedBox(width: 6),
              Text(
                '今日計畫',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: exercises
                .map(
                  (e) => Chip(
                    avatar: Text(e.emoji,
                        style: const TextStyle(fontSize: 14)),
                    label: Text(e.nameZh,
                        style: const TextStyle(fontSize: 12)),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    side: BorderSide(
                        color: theme.colorScheme.primary.withOpacity(0.3)),
                    padding: EdgeInsets.zero,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('😴', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Text(
            '今天是休息日，好好恢復！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}

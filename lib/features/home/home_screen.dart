import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/exercise.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/exercise_detail_sheet.dart';
import '../../shared/widgets/exercise_progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final schedule = ref.watch(scheduleProvider);
    final activeSession = ref.watch(activeWorkoutProvider);
    final todayExercises = schedule.todaysExercises;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(
                todayExercises: todayExercises,
                hasActiveSession: activeSession != null,
              ),
            ),

            // ── Active session banner ────────────────────────────────────────
            if (activeSession != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _ActiveSessionBanner(
                      setCount: activeSession.sets.length),
                ),
              ),

            // ── Today's plan card ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: todayExercises.isNotEmpty
                    ? _TodayCard(exercises: todayExercises)
                    : const _RestDayCard(),
              ),
            ),

            // ── Section header ───────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Text(
                  '六招進度',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),

            // ── Exercise list ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final type = ExerciseType.values[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExerciseProgressCard(
                        type: type,
                        currentStep: progression.stepFor(type),
                        isScheduledToday: todayExercises.contains(type),
                        onTap: () => ExerciseDetailSheet.show(
                          context,
                          type,
                          progression.stepFor(type),
                        ),
                      ),
                    );
                  },
                  childCount: ExerciseType.values.length,
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

// ─── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.todayExercises,
    required this.hasActiveSession,
  });

  final List<ExerciseType> todayExercises;
  final bool hasActiveSession;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'zh_TW').format(now);
    final date = DateFormat('M月d日').format(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name
                const Text(
                  'ConvictSix',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: kPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$weekday · $date',
                  style: const TextStyle(
                    fontSize: 13,
                    color: kTextTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Streak / workout count placeholder
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderSubtle),
            ),
            child: Column(
              children: [
                Text(
                  todayExercises.isEmpty ? '😴' : '🔥',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  todayExercises.isEmpty ? '休息日' : '訓練日',
                  style: const TextStyle(
                    fontSize: 10,
                    color: kTextTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active session banner ───────────────────────────────────────────────────

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({required this.setCount});

  final int setCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center,
                color: kPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '訓練進行中',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kPrimary,
                  ),
                ),
                Text(
                  '已記錄 $setCount 組 · 前往訓練頁繼續',
                  style: const TextStyle(
                    fontSize: 12,
                    color: kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kTextTertiary, size: 20),
        ],
      ),
    );
  }
}

// ─── Today card ──────────────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.exercises});

  final List<ExerciseType> exercises;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              const Text(
                '今日計畫',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                '${exercises.length} 個動作',
                style: const TextStyle(
                  fontSize: 12,
                  color: kTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Exercise pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exercises.map((e) => _ExercisePill(type: e)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ExercisePill extends StatelessWidget {
  const _ExercisePill({required this.type});

  final ExerciseType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBgSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderDefault),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            type.nameZh,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Rest day card ───────────────────────────────────────────────────────────

class _RestDayCard extends StatelessWidget {
  const _RestDayCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle),
      ),
      child: const Row(
        children: [
          Text('😴', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今天是休息日',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '恢復同樣是訓練的一部分',
                style: TextStyle(fontSize: 12, color: kTextTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

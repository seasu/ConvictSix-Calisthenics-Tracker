import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/character.dart';
import '../../data/models/exercise.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/user_progression.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/character_painter.dart';
import '../../shared/widgets/exercise_detail_sheet.dart';
import '../../shared/widgets/exercise_progress_card.dart';

const _kAppVersion = 'v1.5.5';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(progressionProvider);
    final schedule = ref.watch(scheduleProvider);
    final activeSession = ref.watch(activeWorkoutProvider);
    final history = ref.watch(historyProvider);
    final todayExercises = schedule.todaysExercises;
    final activeUserId = ref.watch(activeUserIdProvider);
    final profiles = ref.watch(profilesProvider);
    final currentProfile =
        profiles.where((p) => p.id == activeUserId).firstOrNull;
    final characterType = currentProfile?.characterType ?? CharacterType.male;
    final charStage = characterStageFor(progression);

    final now = DateTime.now();
    final todayCompleted = history.any((s) =>
        s.isCompleted &&
        s.date.year == now.year &&
        s.date.month == now.month &&
        s.date.day == now.day);

    // ── Which exercises were actually trained today ──────────────────────────
    final todaySets = [
      ...history
          .where((s) =>
              s.isCompleted &&
              s.date.year == now.year &&
              s.date.month == now.month &&
              s.date.day == now.day)
          .expand((s) => s.sets),
      if (activeSession != null) ...activeSession.sets,
    ];
    final trainedTodaySet = {for (final s in todaySets) s.exercise};

    // ── Last session record per exercise ────────────────────────────────────
    final completedSorted = [...history.where((s) => s.isCompleted)]
      ..sort((a, b) => b.date.compareTo(a.date));

    final lastRecordMap = <ExerciseType, String>{};
    for (final exType in ExerciseType.values) {
      for (final session in completedSorted) {
        final sets =
            session.sets.where((s) => s.exercise == exType).toList();
        if (sets.isEmpty) continue;
        final count = sets.length;
        final String record;
        if (sets.first.holdSeconds > 0) {
          final best =
              sets.map((s) => s.holdSeconds).reduce((a, b) => a > b ? a : b);
          record = '$count組·$best秒';
        } else {
          final best =
              sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
          record = '$count組·$best下';
        }
        lastRecordMap[exType] = record;
        break;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(
                todayExercises: todayExercises,
                hasActiveSession: activeSession != null,
                todayCompleted: todayCompleted,
              ),
            ),

            // ── Active session banner ─────────────────────────────────────────
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
                    ? _TodayCard(
                        exercises: todayExercises,
                        isCompleted: todayCompleted && activeSession == null,
                      )
                    : const _RestDayCard(),
              ),
            ),

            // ── Character card ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _CharacterCard(
                  characterType: characterType,
                  stage: charStage,
                  progression: progression,
                ),
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
                        completedToday: trainedTodaySet.contains(type),
                        lastRecord: lastRecordMap[type],
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

class _Header extends ConsumerWidget {
  const _Header({
    required this.todayExercises,
    required this.hasActiveSession,
    required this.todayCompleted,
  });

  final List<ExerciseType> todayExercises;
  final bool hasActiveSession;
  final bool todayCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final weekday = DateFormat('EEEE', 'zh_TW').format(now);
    final date = DateFormat('M月d日').format(now);

    final activeUserId = ref.watch(activeUserIdProvider);
    final profiles = ref.watch(profilesProvider);
    final currentProfile = profiles
        .where((p) => p.id == activeUserId)
        .firstOrNull;
    final displayName = currentProfile?.name ?? '我';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: app name + date ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name + version
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'ConvictSix',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: kPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: kPrimary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        _kAppVersion,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
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

          // ── Right: user chip + workout status ─────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User switcher chip
              GestureDetector(
                onTap: () => _UserSwitcherSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kBgSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kBorderDefault),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar circle
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0]
                              : '我',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: kPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 14, color: kTextTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Workout status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: todayCompleted
                      ? kTierBeginner.withValues(alpha: 0.10)
                      : kBgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: todayCompleted
                        ? kTierBeginner.withValues(alpha: 0.35)
                        : kBorderSubtle,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      todayExercises.isEmpty
                          ? '😴'
                          : todayCompleted
                              ? '✅'
                              : '🔥',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todayExercises.isEmpty
                          ? '休息日'
                          : todayCompleted
                              ? '今日完成'
                              : '訓練日',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            todayCompleted ? kTierBeginner : kTextTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── User Switcher Bottom Sheet ──────────────────────────────────────────────

class _UserSwitcherSheet extends ConsumerStatefulWidget {
  const _UserSwitcherSheet();

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _UserSwitcherSheet(),
    );
  }

  @override
  ConsumerState<_UserSwitcherSheet> createState() =>
      _UserSwitcherSheetState();
}

class _UserSwitcherSheetState extends ConsumerState<_UserSwitcherSheet> {
  bool _adding = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final profile =
        await ref.read(profilesProvider.notifier).addProfile(name);
    await ref.read(activeUserIdProvider.notifier).switchUser(profile.id);
    _nameController.clear();
    setState(() => _adding = false);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _switchTo(String id) async {
    await ref.read(activeUserIdProvider.notifier).switchUser(id);
    HapticFeedback.selectionClick();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(UserProfile profile) async {
    final profiles = ref.read(profilesProvider);
    if (profiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少保留一個使用者')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBgSurface2,
        title: const Text('刪除使用者', style: TextStyle(color: kTextPrimary)),
        content: Text(
          '確定刪除「${profile.name}」？所有相關訓練記錄將一併移除，且無法復原。',
          style: const TextStyle(color: kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消', style: TextStyle(color: kTextTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('刪除',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final activeId = ref.read(activeUserIdProvider);
    await ref.read(profilesProvider.notifier).deleteProfile(profile.id);
    if (activeId == profile.id) {
      final remaining = ref.read(profilesProvider);
      if (remaining.isNotEmpty) {
        await ref
            .read(activeUserIdProvider.notifier)
            .switchUser(remaining.first.id);
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final activeId = ref.watch(activeUserIdProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kBgSurface3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text(
                  '切換使用者',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => _adding = !_adding),
                  icon: Icon(
                    _adding ? Icons.close : Icons.person_add_outlined,
                    size: 16,
                    color: kPrimary,
                  ),
                  label: Text(
                    _adding ? '取消' : '新增',
                    style:
                        const TextStyle(color: kPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          // Add user input
          if (_adding)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      autofocus: true,
                      style:
                          const TextStyle(color: kTextPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '輸入名稱',
                        hintStyle: const TextStyle(
                            color: kTextTertiary, fontSize: 14),
                        filled: true,
                        fillColor: kBgSurface2,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: kBorderDefault),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: kBorderDefault),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: kPrimary),
                        ),
                      ),
                      onSubmitted: (_) => _addUser(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('建立',
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          // Profile list
          ...profiles.map((profile) {
            final isActive = profile.id == activeId;
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive
                      ? kPrimary.withValues(alpha: 0.18)
                      : kBgSurface2,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(color: kPrimary, width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  profile.name.isNotEmpty
                      ? profile.name.isEmpty ? '?' : profile.name[0]
                      : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isActive ? kPrimary : kTextSecondary,
                  ),
                ),
              ),
              title: Text(
                profile.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? kTextPrimary : kTextSecondary,
                ),
              ),
              trailing: isActive
                  ? const Icon(Icons.check_circle_rounded,
                      color: kPrimary, size: 20)
                  : IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: kTextTertiary),
                      onPressed: () => _delete(profile),
                    ),
              onTap: isActive ? null : () => _switchTo(profile.id),
            );
          }),
          const SizedBox(height: 24),
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
  const _TodayCard({required this.exercises, this.isCompleted = false});

  final List<ExerciseType> exercises;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? kTierBeginner.withValues(alpha: 0.05)
            : kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? kTierBeginner.withValues(alpha: 0.3)
              : kBorderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(
                isCompleted ? '今日已完成' : '今日計畫',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? kTierBeginner : kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              if (isCompleted) ...[
                const SizedBox(width: 4),
                const Text('✅', style: TextStyle(fontSize: 12)),
              ],
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
            children: exercises
                .map((e) => _ExercisePill(type: e, isCompleted: isCompleted))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ExercisePill extends StatelessWidget {
  const _ExercisePill({required this.type, this.isCompleted = false});

  final ExerciseType type;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? kTierBeginner.withValues(alpha: 0.10)
            : kBgSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? kTierBeginner.withValues(alpha: 0.35)
              : kBorderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            type.nameZh,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isCompleted ? kTierBeginner : kTextPrimary,
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

// ─── Character card ───────────────────────────────────────────────────────────

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.characterType,
    required this.stage,
    required this.progression,
  });

  final CharacterType characterType;
  final int stage;
  final UserProgression progression;

  @override
  Widget build(BuildContext context) {
    final stageColor = _stageColor(stage);
    // Progress to next stage: fraction of the 4-step gap filled
    final total = ExerciseType.values
        .map<int>((t) => progression.stepFor(t))
        .fold(0, (a, b) => a + b);
    final avg = total / ExerciseType.values.length;
    final stageLow = (stage - 1) * 2.0;
    final stageHigh = stage < 5 ? stage * 2.0 : 10.0;
    final progress =
        ((avg - stageLow) / (stageHigh - stageLow)).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: kBgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stageColor.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // ── Character art ────────────────────────────────────────────────
          CharacterWidget(
            type: characterType,
            stage: stage,
            width: 72,
            height: 96,
          ),
          const SizedBox(width: 16),
          // ── Info ─────────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stage badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Lv.$stage  ${stageTitle(stage)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: stageColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stageSubtitle(stage),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                // Progress bar to next stage
                if (stage < 5) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor:
                                stageColor.withValues(alpha: 0.15),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(stageColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 10,
                          color: stageColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '距離下一段位',
                    style: TextStyle(
                        fontSize: 10, color: kTextTertiary),
                  ),
                ] else ...[
                  Text(
                    '已達最高境界！',
                    style: TextStyle(
                      fontSize: 12,
                      color: stageColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _stageColor(int s) => switch (s) {
        1 => kTextSecondary,
        2 => kTierBeginner,
        3 => kTierMid,
        4 => kTierAdvanced,
        _ => const Color(0xFFE040FB),
      };
}

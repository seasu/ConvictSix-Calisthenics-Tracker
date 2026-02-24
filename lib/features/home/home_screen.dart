import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/models/exercise.dart';
import '../../data/models/user_profile.dart';
import '../../data/providers/app_providers.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/exercise_detail_sheet.dart';
import '../../shared/widgets/exercise_progress_card.dart';

const _kAppVersion = 'v1.1.0';

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

class _Header extends ConsumerWidget {
  const _Header({
    required this.todayExercises,
    required this.hasActiveSession,
  });

  final List<ExerciseType> todayExercises;
  final bool hasActiveSession;

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
                  color: kBgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      todayExercises.isEmpty ? '😴' : '🔥',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
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

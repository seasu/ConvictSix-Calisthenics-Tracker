import 'package:flutter/material.dart';

import '../../data/models/exercise.dart';
import '../../shared/constants/exercises_data.dart';
import '../theme/app_theme.dart';
import 'step_dots.dart';

/// Full-width list-style card showing one exercise's current progression.
///
/// Layout:
///   [emoji box]  [name + step label]  [10-dot row]
///                [step name]          [tier badge]
///                                     [target label]
class ExerciseProgressCard extends StatelessWidget {
  const ExerciseProgressCard({
    super.key,
    required this.type,
    required this.currentStep,
    this.isScheduledToday = false,
    this.onTap,
  });

  final ExerciseType type;
  final int currentStep;
  final bool isScheduledToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final exercise = exerciseForType(type);
    final step = exercise.stepAt(currentStep);
    final tierColor = stepTierColor(currentStep);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: kBgSurface,
          borderRadius: BorderRadius.circular(16),
          border: isScheduledToday
              ? Border.all(color: kPrimary.withOpacity(0.7), width: 1)
              : Border.all(color: kBorderSubtle, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Emoji icon box ─────────────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tierColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  exercise.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // ── Name + step info ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Exercise name + 今日 badge
                  Row(
                    children: [
                      Text(
                        exercise.nameZh,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (isScheduledToday) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            '今日',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: kPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Step number + step name
                  Text(
                    '第 $currentStep 式 · ${step.nameZh}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 10-dot progress
                  StepDots(currentStep: currentStep),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // ── Right: tier + count + target ──────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                TierBadge(step: currentStep),
                const SizedBox(height: 6),
                Text(
                  '$currentStep / 10',
                  style: const TextStyle(
                    fontSize: 11,
                    color: kTextTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.progression.display,
                  style: TextStyle(
                    fontSize: 11,
                    color: tierColor.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

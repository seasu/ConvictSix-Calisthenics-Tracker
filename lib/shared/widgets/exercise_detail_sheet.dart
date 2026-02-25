import 'package:flutter/material.dart';

import '../../data/models/exercise.dart';
import '../../shared/constants/exercises_data.dart';
import '../theme/app_theme.dart';
import 'step_dots.dart';

/// Modal bottom sheet showing exercise photo, description, and training
/// standards for a specific progression step.
///
/// The user can navigate between steps 1–10 with the ← / → buttons.
///
/// Photo loading follows the convention:
///   assets/images/exercises/{exerciseTypeName}_{stepNumber:02d}_ls.jpg
/// When no photo file exists the sheet shows a styled placeholder.
class ExerciseDetailSheet extends StatefulWidget {
  const ExerciseDetailSheet({
    super.key,
    required this.type,
    required this.stepNumber,
  });

  final ExerciseType type;
  final int stepNumber;

  static void show(
      BuildContext context, ExerciseType type, int stepNumber) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ExerciseDetailSheet(type: type, stepNumber: stepNumber),
    );
  }

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late int _step;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _step = widget.stepNumber;
  }

  void _goTo(int step) {
    if (step < 1 || step > 10) return;
    _scrollController?.jumpTo(0);
    setState(() => _step = step);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = exerciseForType(widget.type);
    final step = exercise.stepAt(_step);
    final tierColor = stepTierColor(_step);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.93,
      builder: (context, scrollController) {
        _scrollController = scrollController;
        return Container(
          decoration: const BoxDecoration(
            color: kBgSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ─────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kBorderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),

              // ── Scrollable body ─────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photo area
                      _PhotoArea(
                        exercise: exercise,
                        stepNumber: _step,
                        tierColor: tierColor,
                      ),
                      const SizedBox(height: 20),

                      // Exercise name + tier badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              exercise.nameZh,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: kTextPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TierBadge(step: _step),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Step navigation row: ← 第 N 式 · Name → ─────────
                      Row(
                        children: [
                          _NavArrow(
                            icon: Icons.chevron_left_rounded,
                            enabled: _step > 1,
                            tierColor: tierColor,
                            onTap: () => _goTo(_step - 1),
                          ),
                          Expanded(
                            child: Text(
                              '第 $_step 式 · ${step.nameZh}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: tierColor,
                              ),
                            ),
                          ),
                          _NavArrow(
                            icon: Icons.chevron_right_rounded,
                            enabled: _step < 10,
                            tierColor: tierColor,
                            onTap: () => _goTo(_step + 1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Step progress dots
                      Center(child: StepDots(currentStep: _step)),
                      const SizedBox(height: 22),

                      // Description
                      const _SectionLabel('動作說明'),
                      const SizedBox(height: 8),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kTextSecondary,
                          height: 1.65,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Training standards
                      const _SectionLabel('訓練標準'),
                      const SizedBox(height: 10),
                      _StandardsRow(step: step, tierColor: tierColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Step navigation arrow ────────────────────────────────────────────────────

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.tierColor,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final Color tierColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled
              ? tierColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? tierColor : kTextTertiary,
        ),
      ),
    );
  }
}

// ─── Photo area ───────────────────────────────────────────────────────────────

class _PhotoArea extends StatelessWidget {
  const _PhotoArea({
    required this.exercise,
    required this.stepNumber,
    required this.tierColor,
  });

  final Exercise exercise;
  final int stepNumber;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    // Convention: assets/images/exercises/{typeName}_{step:02d}_ls.jpg
    // Landscape (16:9) images are used here for the full-width banner.
    // Square (_sq.jpg) images are used for thumbnails in workout_screen.dart.
    final assetPath =
        'assets/images/exercises/${exercise.type.name}_${stepNumber.toString().padLeft(2, '0')}_ls.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 230,
        width: double.infinity,
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PhotoPlaceholder(
            exercise: exercise,
            stepNumber: stepNumber,
            tierColor: tierColor,
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({
    required this.exercise,
    required this.stepNumber,
    required this.tierColor,
  });

  final Exercise exercise;
  final int stepNumber;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    final step = exercise.stepAt(stepNumber);
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.06),
        border:
            Border.all(color: tierColor.withValues(alpha: 0.18), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background emoji
          Text(exercise.emoji, style: const TextStyle(fontSize: 80)),

          // English step name at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    kBgSurface.withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: Text(
                step.nameEn,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: tierColor,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),

          // "No photo yet" badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kBgSurface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined,
                      size: 12, color: kTextTertiary),
                  SizedBox(width: 4),
                  Text(
                    '尚未有照片',
                    style: TextStyle(
                        fontSize: 10, color: kTextTertiary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kTextTertiary,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─── Training standards row ───────────────────────────────────────────────────

class _StandardsRow extends StatelessWidget {
  const _StandardsRow({required this.step, required this.tierColor});

  final ExerciseStep step;
  final Color tierColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StandardCard(
            label: '入門',
            value: step.beginner.display,
            color: kTierBeginner,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StandardCard(
            label: '中級',
            value: step.intermediate.display,
            color: kTierMid,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StandardCard(
            label: '晉級',
            value: step.progression.display,
            color: tierColor,
          ),
        ),
      ],
    );
  }
}

class _StandardCard extends StatelessWidget {
  const _StandardCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

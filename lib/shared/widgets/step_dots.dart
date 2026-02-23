import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A row of 10 colour-coded dots representing the 10 progression steps.
/// Filled dots = completed steps; empty = future steps.
/// Colour encodes tier: green (1–4 初學), amber (5–7 中級), orange (8–10 進階).
class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.currentStep,
    this.dotSize = 8.0,
    this.spacing = 5.0,
  });

  final int currentStep;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (i) {
        final stepNum = i + 1;
        final filled = stepNum <= currentStep;
        final color = filled ? stepTierColor(stepNum) : Colors.white12;
        final isActive = stepNum == currentStep;

        return Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.only(right: i < 9 ? spacing : 0),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// A compact tier label badge: 初學 / 中級 / 進階
class TierBadge extends StatelessWidget {
  const TierBadge({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final color = stepTierColor(step);
    final label = stepTierLabel(step);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

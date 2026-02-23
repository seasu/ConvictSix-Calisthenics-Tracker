import 'package:flutter/material.dart';

import '../../data/models/workout_session.dart';

/// A small chip / row showing a single logged set.
class SetLogTile extends StatelessWidget {
  const SetLogTile({
    super.key,
    required this.setNumber,
    required this.workoutSet,
  });

  final int setNumber;
  final WorkoutSet workoutSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$setNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            workoutSet.displayReps,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (workoutSet.note.isNotEmpty) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                workoutSet.note,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.white54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

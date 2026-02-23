import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/training_schedule.dart';
import '../models/user_progression.dart';
import '../models/workout_session.dart';
import '../repositories/progression_repository.dart';
import '../repositories/workout_repository.dart';

// ─── Infrastructure ───────────────────────────────────────────────────────────

/// Provided at app startup via ProviderScope overrides.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences not yet initialised'),
);

const _uuid = Uuid();

// ─── Repositories ─────────────────────────────────────────────────────────────

final progressionRepositoryProvider = Provider<ProgressionRepository>(
  (ref) => ProgressionRepository(ref.watch(sharedPreferencesProvider)),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(sharedPreferencesProvider)),
);

// ─── User Progression ─────────────────────────────────────────────────────────

class ProgressionNotifier extends Notifier<UserProgression> {
  @override
  UserProgression build() {
    return ref.read(progressionRepositoryProvider).loadProgression();
  }

  Future<void> setStep(ExerciseType type, int step) async {
    state = state.withStep(type, step);
    await ref.read(progressionRepositoryProvider).saveProgression(state);
  }
}

final progressionProvider =
    NotifierProvider<ProgressionNotifier, UserProgression>(
  ProgressionNotifier.new,
);

// ─── Training Schedule ────────────────────────────────────────────────────────

class ScheduleNotifier extends Notifier<TrainingSchedule> {
  @override
  TrainingSchedule build() {
    return ref.read(progressionRepositoryProvider).loadSchedule();
  }

  Future<void> updateDay(DaySchedule day) async {
    state = state.withDay(day);
    await ref.read(progressionRepositoryProvider).saveSchedule(state);
  }

  Future<void> removeDay(int weekday) async {
    state = state.withoutDay(weekday);
    await ref.read(progressionRepositoryProvider).saveSchedule(state);
  }
}

final scheduleProvider =
    NotifierProvider<ScheduleNotifier, TrainingSchedule>(
  ScheduleNotifier.new,
);

// ─── Active Workout Session ───────────────────────────────────────────────────

class ActiveWorkoutNotifier extends Notifier<WorkoutSession?> {
  @override
  WorkoutSession? build() {
    return ref.read(workoutRepositoryProvider).loadActiveSession();
  }

  Future<void> startWorkout() async {
    final session = WorkoutSession(
      id: _uuid.v4(),
      date: DateTime.now(),
      sets: [],
    );
    state = session;
    await ref.read(workoutRepositoryProvider).saveActiveSession(session);
  }

  Future<void> logSet(WorkoutSet workoutSet) async {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(sets: [...current.sets, workoutSet]);
    state = updated;
    await ref.read(workoutRepositoryProvider).saveActiveSession(updated);
  }

  Future<void> removeLastSet(ExerciseType exercise) async {
    final current = state;
    if (current == null) return;
    final sets = List<WorkoutSet>.from(current.sets);
    final idx = sets.lastIndexWhere((s) => s.exercise == exercise);
    if (idx == -1) return;
    sets.removeAt(idx);
    final updated = current.copyWith(sets: sets);
    state = updated;
    await ref.read(workoutRepositoryProvider).saveActiveSession(updated);
  }

  Future<void> finishWorkout() async {
    final current = state;
    if (current == null) return;
    final completed = current.copyWith(isCompleted: true);
    await ref.read(workoutRepositoryProvider).saveSession(completed);
    await ref.read(workoutRepositoryProvider).clearActiveSession();
    ref.read(historyProvider.notifier).reload();
    state = null;
  }

  Future<void> discardWorkout() async {
    await ref.read(workoutRepositoryProvider).clearActiveSession();
    state = null;
  }
}

final activeWorkoutProvider =
    NotifierProvider<ActiveWorkoutNotifier, WorkoutSession?>(
  ActiveWorkoutNotifier.new,
);

// ─── Workout History ─────────────────────────────────────────────────────────

class HistoryNotifier extends Notifier<List<WorkoutSession>> {
  @override
  List<WorkoutSession> build() {
    return ref.read(workoutRepositoryProvider).loadHistory();
  }

  void reload() {
    state = ref.read(workoutRepositoryProvider).loadHistory();
  }

  Future<void> delete(String id) async {
    await ref.read(workoutRepositoryProvider).deleteSession(id);
    reload();
  }
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<WorkoutSession>>(
  HistoryNotifier.new,
);

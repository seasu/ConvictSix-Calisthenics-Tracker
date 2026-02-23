import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_progression.dart';
import '../models/training_schedule.dart';

const _progressionKey = 'user_progression_v1';
const _scheduleKey = 'training_schedule_v1';

class ProgressionRepository {
  const ProgressionRepository(this._prefs);

  final SharedPreferences _prefs;

  UserProgression loadProgression() {
    final raw = _prefs.getString(_progressionKey);
    if (raw == null) return UserProgression.initial();
    try {
      return UserProgression.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProgression.initial();
    }
  }

  Future<void> saveProgression(UserProgression progression) async {
    await _prefs.setString(
        _progressionKey, jsonEncode(progression.toJson()));
  }

  TrainingSchedule loadSchedule() {
    final raw = _prefs.getString(_scheduleKey);
    if (raw == null) return TrainingSchedule.defaultSchedule();
    try {
      return TrainingSchedule.fromJson(
          jsonDecode(raw) as List<dynamic>);
    } catch (_) {
      return TrainingSchedule.defaultSchedule();
    }
  }

  Future<void> saveSchedule(TrainingSchedule schedule) async {
    await _prefs.setString(_scheduleKey, jsonEncode(schedule.toJson()));
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';

class WorkoutRepository {
  const WorkoutRepository(this._prefs, this._userId);

  final SharedPreferences _prefs;
  final String _userId;

  String get _historyKey => 'workout_history_v1_$_userId';
  String get _activeSessionKey => 'active_workout_session_v1_$_userId';

  List<WorkoutSession> loadHistory() {
    final raw = _prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSession(WorkoutSession session) async {
    final history = loadHistory();
    final updated = [
      session,
      ...history.where((s) => s.id != session.id),
    ]..sort((a, b) => b.date.compareTo(a.date));
    await _prefs.setString(
        _historyKey, jsonEncode(updated.map((s) => s.toJson()).toList()));
  }

  Future<void> deleteSession(String id) async {
    final history = loadHistory().where((s) => s.id != id).toList();
    await _prefs.setString(
        _historyKey, jsonEncode(history.map((s) => s.toJson()).toList()));
  }

  WorkoutSession? loadActiveSession() {
    final raw = _prefs.getString(_activeSessionKey);
    if (raw == null) return null;
    try {
      return WorkoutSession.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveSession(WorkoutSession session) async {
    await _prefs.setString(_activeSessionKey, jsonEncode(session.toJson()));
  }

  Future<void> clearActiveSession() async {
    await _prefs.remove(_activeSessionKey);
  }
}

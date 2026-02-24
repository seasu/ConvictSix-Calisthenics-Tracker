import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

const _profilesKey = 'user_profiles_v1';
const _activeUserKey = 'active_user_id_v1';
const _hasSeenIntroKey = 'has_seen_intro_v1';

class ProfileRepository {
  const ProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  // ─── Profiles ─────────────────────────────────────────────────────────────

  List<UserProfile> loadProfiles() {
    final raw = _prefs.getString(_profilesKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    await _prefs.setString(
        _profilesKey, jsonEncode(profiles.map((p) => p.toJson()).toList()));
  }

  // ─── Active user ──────────────────────────────────────────────────────────

  String? loadActiveUserId() => _prefs.getString(_activeUserKey);

  Future<void> saveActiveUserId(String id) async {
    await _prefs.setString(_activeUserKey, id);
  }

  // ─── Intro ────────────────────────────────────────────────────────────────

  bool hasSeenIntro() => _prefs.getBool(_hasSeenIntroKey) ?? false;

  Future<void> markIntroSeen() async {
    await _prefs.setBool(_hasSeenIntroKey, true);
  }
}

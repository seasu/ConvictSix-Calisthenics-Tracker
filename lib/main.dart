import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/models/user_profile.dart';
import 'data/providers/app_providers.dart';
import 'data/repositories/profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crashlytics is native-only; the web build (GitHub Pages) has no
  // Firebase project configured and must keep working without it.
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  await initializeDateFormatting('zh_TW', null);
  final prefs = await SharedPreferences.getInstance();

  // ── Ensure at least one user profile exists ──────────────────────────────
  final profileRepo = ProfileRepository(prefs);
  var profiles = profileRepo.loadProfiles();
  String activeUserId = profileRepo.loadActiveUserId() ?? '';

  if (profiles.isEmpty) {
    const defaultId = 'default';
    final defaultProfile = UserProfile(
      id: defaultId,
      name: '我',
      createdAt: DateTime.now(),
    );
    profiles = [defaultProfile];
    await profileRepo.saveProfiles(profiles);
    activeUserId = defaultId;
    await profileRepo.saveActiveUserId(defaultId);
  } else if (activeUserId.isEmpty ||
      !profiles.any((p) => p.id == activeUserId)) {
    activeUserId = profiles.first.id;
    await profileRepo.saveActiveUserId(activeUserId);
  }

  final showIntro = !profileRepo.hasSeenIntro();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: ConvictSixApp(showIntro: showIntro),
    ),
  );
}

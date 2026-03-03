# AGENTS.md

## Cursor Cloud specific instructions

This is a Flutter/Dart calisthenics tracker app with no backend services. All persistence is local via `SharedPreferences`.

### Prerequisites

- Flutter SDK is installed at `/opt/flutter/bin` and added to `PATH` via `~/.bashrc`.
- Platform host files (`web/`, etc.) are **not** checked into git. They must be generated before building — the update script handles this.

### Running the app

```bash
flutter run -d web-server --web-port 8080
```

Or for Chrome: `flutter run -d chrome`. See `CLAUDE.md` for the full command reference.

### Lint / Test / Build

Per `CLAUDE.md`:
- **Lint:** `flutter analyze`
- **Test:** `flutter test`
- **Format check:** `dart format --output=none --set-exit-if-changed .`
- **Web build:** `flutter build web --release --base-href /ConvictSix-Calisthenics-Tracker/`

### Gotchas

- The `web/` directory is generated (not committed). If missing, run: `flutter create --platforms web --project-name convict_six_calisthenics_tracker .`
- The `assets/images/exercises/` directory must exist for `flutter pub get` to succeed (it is committed to git).
- `flutter create` will generate `.idea/` and `*.iml` files — these are gitignored and safe to ignore.

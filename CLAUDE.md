# CLAUDE.md — ConvictSix Calisthenics Tracker

This file provides guidance for AI assistants (Claude Code, Copilot, etc.) working on this repository. Keep it up to date as the project evolves.

> **Before starting any session, read:**
> - [`tasks/agent-workflow.md`](tasks/agent-workflow.md) — how to plan, execute, and self-correct
> - [`tasks/lessons.md`](tasks/lessons.md) — mistakes already made; do not repeat them
> - [`tasks/todo.md`](tasks/todo.md) — current task log

---

## Project Overview

**ConvictSix Calisthenics Tracker** is a cross-platform mobile (and optionally desktop/web) application built with Flutter/Dart. Its purpose is to help users track progress through a structured calisthenics programme (inspired by the "Convict Conditioning" / ConvictSix progression system), recording workouts, sets, reps, and advancement through exercise progressions.

**Current state:** MVP scaffolding is complete. All six exercises with ten progression steps each are defined. The app supports setting your current level per exercise, scheduling weekly training days, logging workout sets/reps, and reviewing session history. Platform-specific host projects (android/, ios/, etc.) still need to be generated via `flutter create .`.

---

## Technology Stack

| Layer | Technology |
|---|---|
| UI / App framework | Flutter (Dart) — Material 3, dark theme |
| Language | Dart ≥ 3.x |
| State management | **flutter_riverpod ^2.5.1** — `Notifier` + `NotifierProvider` |
| Local persistence | **shared_preferences ^2.3.2** — JSON-encoded models |
| Unique IDs | **uuid ^4.4.0** — v4 UUIDs for session and set IDs |
| Date formatting | **intl ^0.19.0** — `DateFormat` with `zh_TW` locale |
| Testing | flutter_test + **mocktail ^1.0.4** |
| CI / Deployment | **GitHub Actions** — build + deploy to GitHub Pages on push to `main` |

**State management pattern:** `Notifier<T>` classes registered via `NotifierProvider`. All providers live in `lib/data/providers/app_providers.dart`. `SharedPreferences` is injected via a `Provider<SharedPreferences>` override at app startup.

**Persistence strategy:** Models implement `toJson()`/`fromJson()` and are stored as JSON strings in `SharedPreferences`. No code generation is required.

---

## Repository Layout

Current actual layout:

```
ConvictSix-Calisthenics-Tracker/
├── CLAUDE.md
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── lib/
│   ├── main.dart                         # App entry point; initialises SharedPreferences
│   ├── app.dart                          # ConvictSixApp (MaterialApp) + MainNavigationScreen
│   ├── data/
│   │   ├── models/
│   │   │   ├── exercise.dart             # ExerciseType enum, ExerciseStep, Exercise, StepStandard
│   │   │   ├── user_progression.dart     # UserProgression (current step per exercise)
│   │   │   ├── workout_session.dart      # WorkoutSession, WorkoutSet
│   │   │   └── training_schedule.dart    # TrainingSchedule, DaySchedule
│   │   ├── providers/
│   │   │   └── app_providers.dart        # All Riverpod providers (progression, schedule, workout, history)
│   │   └── repositories/
│   │       ├── progression_repository.dart
│   │       └── workout_repository.dart
│   ├── features/
│   │   ├── home/
│   │   │   └── home_screen.dart          # Dashboard: six-exercise progress grid + today's plan
│   │   ├── program_setup/
│   │   │   └── program_setup_screen.dart # Set current step + configure weekly schedule
│   │   ├── workout/
│   │   │   └── workout_screen.dart       # Start/log/finish a workout session
│   │   └── history/
│   │       └── history_screen.dart       # Past sessions list with expandable detail
│   └── shared/
│       ├── constants/
│       │   └── exercises_data.dart       # Full 6×10 exercise definitions (Chinese + English)
│       ├── theme/
│       │   └── app_theme.dart            # Design tokens (kBg*, kPrimary, kTier*, kText*) + buildAppTheme()
│       └── widgets/
│           ├── exercise_progress_card.dart  # Full-width list card with tier colour + step dots
│           ├── step_dots.dart               # StepDots (10-dot progress) + TierBadge widget
│           └── set_log_tile.dart
└── test/                                 # (to be populated)
    ├── unit/
    ├── widget/
    └── integration/
```

> **Note:** Platform host projects (`android/`, `ios/`, etc.) are not yet present.
> After cloning, run `flutter create . --project-name convict_six_calisthenics_tracker`
> to generate them, then `flutter pub get`.

---

## Development Workflows

### Prerequisites

- Flutter SDK ≥ 3.x (`flutter --version`)
- Dart SDK ≥ 3.x (bundled with Flutter)
- Android Studio / Xcode for platform targets
- `flutter doctor` should report no critical issues

### Common Commands

```bash
# Install / update dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Run in Chrome (web preview)
flutter config --enable-web
flutter run -d chrome

# Run as local web server (open http://localhost:8080 in any browser)
flutter run -d web-server --web-port 8080

# Run all tests
flutter test

# Run a specific test file
flutter test test/unit/workout_repository_test.dart

# Static analysis (must pass before every commit)
flutter analyze

# Format all Dart files
dart format .

# Check formatting without writing (CI-safe)
dart format --output=none --set-exit-if-changed .

# Build release APK (Android)
flutter build apk --release

# Build release iOS archive (requires macOS + Xcode)
flutter build ios --release

# Build web (for manual inspection of build/web/)
flutter build web --release --base-href /ConvictSix-Calisthenics-Tracker/

# Clean build artefacts
flutter clean && flutter pub get
```

### GitHub Pages (live web preview)

A GitHub Actions workflow (`.github/workflows/deploy-pages.yml`) automatically builds and deploys the app to GitHub Pages on every push to `main`.

**Live URL:** `https://seasu.github.io/ConvictSix-Calisthenics-Tracker/`

**One-time setup** (do this once in the GitHub repo settings):
1. Go to **Settings → Pages**
2. Set **Source** to **GitHub Actions**
3. Save — the next push to `main` will trigger a deployment

The workflow:
1. Installs Flutter stable
2. Adds `web/` platform files via `flutter create --platforms web .`
3. Runs `flutter analyze`
4. Builds with `--base-href /ConvictSix-Calisthenics-Tracker/`
5. Deploys `build/web/` to GitHub Pages

All dependencies (`shared_preferences`, `uuid`, `intl`) are fully web-compatible. `HapticFeedback` silently no-ops on web.

### Version Bumping

**Every commit that changes app behaviour must bump the version** in both:
- `pubspec.yaml` → `version:` field (e.g. `1.3.0+4`)
- `lib/features/home/home_screen.dart` → `_kAppVersion` constant (e.g. `'v1.3.0'`)

Follow [Semantic Versioning](https://semver.org/):
| Change type | Example | Rule |
|---|---|---|
| New feature | add screen, new UX flow | bump **minor** → `1.3.0` → `1.4.0` |
| Bug fix / tweak | fix display, adjust style | bump **patch** → `1.3.0` → `1.3.1` |
| Breaking / major rework | architecture change | bump **major** → `1.x.x` → `2.0.0` |

The build number (`+N`) always increments by 1 regardless of which part changed.

### Before Committing

1. Run `dart format .` — keep all Dart files consistently formatted.
2. Run `flutter analyze` — fix every warning and error before pushing.
3. Run `flutter test` — all tests must pass.
4. **Bump the version** in `pubspec.yaml` and `home_screen.dart` (see Version Bumping above).
5. Update `CLAUDE.md` if you add new packages, patterns, or directory conventions.

---

## Coding Conventions

### Dart / Flutter Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `dart format` (80-character line length by default).
- Prefer `const` constructors wherever possible to aid widget rebuild performance.
- In `CustomPainter`, local variables derived purely from `static const` fields should be declared `const` (not `final`), e.g. `const bodyTop = _hy + _hr - 6.0;`.
- Flutter geometry `const` cheat-sheet — **can** be `const`: `Offset(x, y)`, `Rect.fromLTWH(...)`, `Size(w, h)`, `Radius.circular(r)` when arguments are constants. **Cannot** be `const`: `Rect.fromCenter(...)`, `RRect.fromRectAndRadius(...)`, `Paint()`. Do not add `const` to these.
- Use named parameters for widgets with more than two meaningful arguments.
- Avoid `dynamic`; prefer explicit types or generics.
- Do not suppress analyser warnings with `// ignore:` without an explanatory comment.

### Widget Patterns

- Keep widgets small and focused (single responsibility).
- Extract reusable UI into `lib/shared/widgets/`.
- Prefer `StatelessWidget` + external state management over `StatefulWidget` where practical.
- **Use design token constants** from `lib/shared/theme/app_theme.dart` (e.g. `kBgSurface`, `kPrimary`, `kTextSecondary`) for colours — do NOT use `Colors.white.withOpacity(…)` or arbitrary hex literals inline. `Theme.of(context)` is still used for component styles (buttons, chips) but raw colour values come from tokens.
- The step-tier colour/label helpers (`stepTierColor(step)`, `stepTierLabel(step)`) live in `app_theme.dart` — use them whenever you need to colour-code a step number.

### State Management

- **Riverpod** is the chosen state management solution. Use `Notifier<T>` + `NotifierProvider`.
- All providers are declared in `lib/data/providers/app_providers.dart`.
- Keep business logic out of widgets; widgets call notifier methods and read state via `ref.watch`.
- Isolate side effects (I/O, persistence) behind repository classes.
- Inject `SharedPreferences` via `sharedPreferencesProvider` — never call `SharedPreferences.getInstance()` inside a provider or widget directly.

### Data Layer

- Define model classes with `copyWith`, `toJson`/`fromJson` (or equivalent serialisation).
- Keep data-layer code in `lib/data/`; never import data-layer packages directly inside feature UI files — go through a repository.
- Prefer immutable value objects for domain models.

### Naming

| Artefact | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `workout_repository.dart` |
| Classes | `PascalCase` | `WorkoutRepository` |
| Variables / functions | `camelCase` | `addSet()` |
| Constants | `camelCase` (Dart idiom) | `maxSets` |
| Test files | mirror source path + `_test` | `workout_repository_test.dart` |

### Tests

- Every public class or function in `lib/` should have a corresponding unit test in `test/unit/`.
- Widget tests live in `test/widget/` and test layout and user interactions.
- Use `mocktail` (preferred) or `mockito` for mocking dependencies.
- Test descriptions should read as sentences: `'returns empty list when no workouts are stored'`.

---

## Design System

The app uses an **Athletic Minimal** visual language — dark backgrounds, high contrast, and colour that carries meaning.

### Colour tokens (`lib/shared/theme/app_theme.dart`)

| Token | Hex | Usage |
|---|---|---|
| `kBgBase` | `#111111` | Scaffold background |
| `kBgSurface` | `#1C1C1C` | Card / container background |
| `kBgSurface2` | `#252525` | Slightly elevated surface (inputs, quick-buttons) |
| `kBgSurface3` | `#2E2E2E` | Highest elevation surface |
| `kBorderSubtle` | `#2A2A2A` | Card borders (default, non-interactive) |
| `kBorderDefault` | `#383838` | Interactive element borders |
| `kPrimary` | `#FF5722` | Primary CTA, active elements, today badge |
| `kPrimaryDim` | 15 % of primary | Focus overlay for sliders |
| `kTierBeginner` | `#52C41A` | Steps 1–4 (綠 · 初學) |
| `kTierMid` | `#FAC015` | Steps 5–7 (黃 · 中級) |
| `kTierAdvanced` | `#FF5722` | Steps 8–10 (橙 · 進階) |
| `kTextPrimary` | `#FFFFFF` | Primary text |
| `kTextSecondary` | `#9E9E9E` | Secondary / meta text |
| `kTextTertiary` | `#616161` | Placeholder, caption, disabled text |

### Step-tier helpers

```dart
// Returns the tier colour for a step number (1–10)
Color stepTierColor(int step)

// Returns the tier label: '初學' | '中級' | '進階'
String stepTierLabel(int step)
```

### Shared visual components

| Widget | File | Description |
|---|---|---|
| `ExerciseProgressCard` | `shared/widgets/exercise_progress_card.dart` | Full-width list card: emoji icon box, name, step dots, tier badge, target |
| `StepDots` | `shared/widgets/step_dots.dart` | Row of 10 colour-coded dots; active dot has glow |
| `TierBadge` | `shared/widgets/step_dots.dart` | Coloured pill badge: 初學 / 中級 / 進階 |
| `SetLogTile` | `shared/widgets/set_log_tile.dart` | Single logged-set row (set number + reps/hold) |

### Workout quick-add UX

The workout screen uses **quick-tap buttons** instead of a keyboard text field:
- **Reps exercises:** `[5] [8] [10] [12] [15] [20] [自訂]`
- **Hold exercises:** `[10s] [20s] [30s] [45s] [60s] [90s] [自訂]`
- The button matching the step's **progression target** is highlighted in the tier colour.
- "自訂" opens an inline text field for non-standard values.

---

## Architecture Overview

The app follows a **feature-first, layered architecture**:

```
Presentation (Flutter widgets)
       │  calls
       ▼
State / ViewModel layer (Riverpod providers / BLoC cubits)
       │  delegates I/O to
       ▼
Repository interfaces  (abstract classes in lib/data/)
       │  implemented by
       ▼
Data sources (local DB, remote API, shared preferences)
```

- Features must not reference each other's internal widgets or state — communicate via shared data layer or navigation only.
- Keep the dependency graph pointing inward: UI → State → Repository → Data Source.

---

## Key Domain Concepts

| Term | Meaning |
|---|---|
| **Exercise (招)** | One of the six movements: 伏地挺身, 深蹲, 引體向上, 舉腿, 橋式, 倒立推 |
| **Step / 式** | A difficulty tier within an exercise, numbered 1–10. Each step has Beginner / Intermediate / Progression standards. |
| **Progression standard** | The rep/set target that must be met to advance to the next step. |
| **Set (組)** | A single counted effort (e.g., 20 reps) or timed hold (e.g., 60 s) within a workout. |
| **Session / Workout** | A dated `WorkoutSession` containing one or more `WorkoutSet` entries. |
| **Training Schedule** | `TrainingSchedule` — maps weekdays to a list of exercises to perform that day. |
| **User Progression** | `UserProgression` — stores the user's current step (1–10) per exercise. |

---

## Git Workflow

- **Default branch:** `main`
- **Feature branches:** `feature/<short-description>` or `claude/<task-id>` for AI-generated branches
- Commit messages should be imperative, present-tense and under 72 characters on the first line:
  - `Add workout history screen`
  - `Fix set count reset on navigation pop`
- Squash trivial fixup commits before merging.
- Do not commit generated files (`build/`, `.dart_tool/`, `.packages`); these are already in `.gitignore`.

---

## Adding New Dependencies

1. Check the [pub.dev](https://pub.dev) package health score and maintenance status before adding.
2. Add to `pubspec.yaml` under the appropriate section (`dependencies` or `dev_dependencies`).
3. Run `flutter pub get` to update `pubspec.lock`.
4. Commit both `pubspec.yaml` and `pubspec.lock`.
5. Document the package and its purpose in this file under the Technology Stack table.

---

## Updating This File

Update `CLAUDE.md` whenever:
- A new dependency or architectural pattern is adopted.
- The directory structure changes meaningfully.
- New domain concepts or terminology are introduced.
- CI/CD pipelines are added or changed.
- Build/test commands change.

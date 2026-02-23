# CLAUDE.md — ConvictSix Calisthenics Tracker

This file provides guidance for AI assistants (Claude Code, Copilot, etc.) working on this repository. Keep it up to date as the project evolves.

---

## Project Overview

**ConvictSix Calisthenics Tracker** is a cross-platform mobile (and optionally desktop/web) application built with Flutter/Dart. Its purpose is to help users track progress through a structured calisthenics programme (inspired by the "Convict Conditioning" / ConvictSix progression system), recording workouts, sets, reps, and advancement through exercise progressions.

**Current state:** The repository was created with an initial commit containing only a Flutter `.gitignore` and a stub `README.md`. No application code exists yet. All foundational scaffolding is still to be written.

---

## Technology Stack

| Layer | Technology |
|---|---|
| UI / App framework | Flutter (Dart) |
| Language | Dart (≥ 3.x recommended) |
| State management | TBD — prefer Riverpod or BLoC when chosen |
| Local persistence | TBD — prefer Hive, Isar, or `sqflite` |
| Testing | Flutter test, Mockito / Mocktail |
| CI | TBD |

> When a dependency is chosen, record it here and in `pubspec.yaml`.

---

## Repository Layout

The expected standard Flutter layout once scaffolding is complete:

```
ConvictSix-Calisthenics-Tracker/
├── CLAUDE.md                   # This file
├── README.md                   # User-facing description
├── pubspec.yaml                # Package manifest & dependencies
├── pubspec.lock                # Locked dependency versions (commit this)
├── analysis_options.yaml       # Dart analyser / linter rules
├── lib/
│   ├── main.dart               # App entry point
│   ├── app.dart                # Root widget / MaterialApp / routing
│   ├── features/               # Feature-first organisation
│   │   ├── workout/            # Logging workouts & sets
│   │   ├── progression/        # Exercise progressions & step unlocks
│   │   ├── history/            # Past workout history & charts
│   │   └── settings/           # User preferences
│   ├── shared/                 # Reusable widgets, utilities, constants
│   └── data/                   # Repositories, data sources, models
├── test/
│   ├── unit/                   # Pure Dart unit tests
│   ├── widget/                 # Flutter widget tests
│   └── integration/            # End-to-end integration tests
├── android/                    # Android host project
├── ios/                        # iOS host project
├── macos/                      # macOS host project (optional)
├── web/                        # Web host project (optional)
└── assets/                     # Images, fonts, JSON seed data
```

If the actual layout diverges from the above, update this section to match reality.

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

# Clean build artefacts
flutter clean && flutter pub get
```

### Before Committing

1. Run `dart format .` — keep all Dart files consistently formatted.
2. Run `flutter analyze` — fix every warning and error before pushing.
3. Run `flutter test` — all tests must pass.
4. Update `CLAUDE.md` if you add new packages, patterns, or directory conventions.

---

## Coding Conventions

### Dart / Flutter Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `dart format` (80-character line length by default).
- Prefer `const` constructors wherever possible to aid widget rebuild performance.
- Use named parameters for widgets with more than two meaningful arguments.
- Avoid `dynamic`; prefer explicit types or generics.
- Do not suppress analyser warnings with `// ignore:` without an explanatory comment.

### Widget Patterns

- Keep widgets small and focused (single responsibility).
- Extract reusable UI into `lib/shared/widgets/`.
- Prefer `StatelessWidget` + external state management over `StatefulWidget` where practical.
- Use `Theme.of(context)` and `TextTheme` for styling — no hard-coded colours or font sizes.

### State Management

- Adopt one state-management approach for the whole app (document the choice here once made).
- Keep business logic out of widgets; widgets should only call methods and render state.
- Isolate side effects (I/O, persistence) behind repository interfaces.

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
| **Exercise** | A specific movement (e.g., Push-up, Pull-up, Squat) |
| **Step / Progression** | A difficulty tier within an exercise (e.g., Kneeling Push-up → Full Push-up → Uneven Push-up) |
| **Set** | A single timed or counted effort within a workout session |
| **Session / Workout** | A dated collection of sets across one or more exercises |
| **Programme** | An ordered list of exercises and their progressions that the user works through |

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

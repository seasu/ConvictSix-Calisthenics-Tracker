# Captured Lessons

Lessons learned from corrections during development. Updated after every mistake.

---

## Flutter / Dart

- **`Rect.fromCenter` is NOT a const constructor.** Only `Rect.fromLTWH`, `Offset(x, y)`,
  `Size(w, h)`, and `Radius.circular(r)` support `const` when arguments are constant.
  `Paint()` and `RRect.fromRectAndRadius(...)` also cannot be `const`.

- **Local variables derived entirely from `static const` fields should be `const`, not `final`.**
  Example: `const bodyTop = _hy + _hr - 6.0;` inside a `CustomPainter` method.

- **Unnecessary string interpolation braces trigger analyzer warnings.**
  Use `'$var'` not `'${var}'` unless the variable name is followed by alphanumerics or `.`.

- **Remove unnecessary casts.** If a method already returns `int`, `.map<int>((t) => x as int)`
  is flagged as `unnecessary_cast` — drop the `as int`.

## UX / State

- **A session can be active while `todayCompleted` is also `true`.**
  A user may complete one session and start another the same day.
  Guard `isCompleted` on today-plan cards with `&& activeSession == null`.

- **`history` being watched in a widget does NOT mean it's being used.**
  Always verify that watched providers are actually consumed (passed to child widgets or
  used in computation). Silent unused watches are a common data-connection bug.

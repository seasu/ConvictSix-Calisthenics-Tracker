import 'package:flutter/material.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────

/// Background layers (darkest → lightest)
const kBgBase = Color(0xFF111111);
const kBgSurface = Color(0xFF1C1C1C);
const kBgSurface2 = Color(0xFF252525);
const kBgSurface3 = Color(0xFF2E2E2E);

/// Stroke / divider
const kBorderSubtle = Color(0xFF2A2A2A);
const kBorderDefault = Color(0xFF383838);

/// Brand orange — used only for interactive / primary actions
const kPrimary = Color(0xFFFF5722);
const kPrimaryDim = Color(0x26FF5722); // 15 % opacity

/// Step-tier palette (one glance tells you where you stand)
const kTierBeginner = Color(0xFF52C41A); // green   · steps 1–4
const kTierMid = Color(0xFFFAC015); // amber   · steps 5–7
const kTierAdvanced = Color(0xFFFF5722); // orange  · steps 8–10

/// Text scale
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFF9E9E9E);
const kTextTertiary = Color(0xFF616161);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Returns the tier color for a given step number (1–10).
Color stepTierColor(int step) {
  if (step <= 4) return kTierBeginner;
  if (step <= 7) return kTierMid;
  return kTierAdvanced;
}

/// Returns the tier label for a given step number.
String stepTierLabel(int step) {
  if (step <= 4) return '初學';
  if (step <= 7) return '中級';
  return '進階';
}

// ─── ThemeData ────────────────────────────────────────────────────────────────

ThemeData buildAppTheme() {
  const cs = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: kPrimary,
    secondary: kTierMid,
    surface: kBgSurface,
    surfaceContainerHighest: kBgSurface3,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: kTextPrimary,
    outline: kBorderDefault,
    outlineVariant: kBorderSubtle,
  );

  return ThemeData(
    colorScheme: cs,
    scaffoldBackgroundColor: kBgBase,
    useMaterial3: true,

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: kBgBase,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: kTextPrimary),
    ),

    // ── Cards ───────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: kBgSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // ── Bottom nav ──────────────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBgSurface,
      selectedItemColor: kPrimary,
      unselectedItemColor: kTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11),
    ),

    // ── Filled buttons ──────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kBgSurface3,
        disabledForegroundColor: kTextTertiary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    ),

    // ── Outlined buttons ────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kPrimary,
        side: const BorderSide(color: kPrimary, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Text buttons ────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // ── Dialogs ─────────────────────────────────────────────────────────────
    dialogTheme: const DialogThemeData(
      backgroundColor: kBgSurface2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    // ── Chips ───────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: kBgSurface2,
      labelStyle: const TextStyle(color: kTextSecondary, fontSize: 12),
      side: const BorderSide(color: kBorderDefault),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    ),

    // ── Sliders ─────────────────────────────────────────────────────────────
    sliderTheme: const SliderThemeData(
      activeTrackColor: kPrimary,
      thumbColor: kPrimary,
      inactiveTrackColor: kBgSurface3,
      overlayColor: kPrimaryDim,
      trackHeight: 4,
    ),

    // ── Input fields ────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kBgSurface2,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: kTextTertiary),
    ),

    // ── Dividers ────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: kBorderSubtle,
      thickness: 1,
      space: 1,
    ),

    // ── Typography ──────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      // 28 bold — screen display numbers
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: kTextPrimary,
      ),
      // 22 bold — section or card headline
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: kTextPrimary,
      ),
      // 18 semibold — card title
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: kTextPrimary,
      ),
      // 16 semibold — exercise name in cards
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: kTextPrimary,
      ),
      // 14 medium — sub-labels
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: kTextPrimary,
      ),
      // 15 regular — body text
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: kTextPrimary,
        height: 1.5,
      ),
      // 14 regular — secondary body
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: kTextPrimary,
        height: 1.4,
      ),
      // 13 regular — meta text
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: kTextSecondary,
        height: 1.4,
      ),
      // 12 medium — labels / badges
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: kTextSecondary,
        letterSpacing: 0.1,
      ),
      // 11 medium — captions
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: kTextTertiary,
        letterSpacing: 0.1,
      ),
    ),
  );
}

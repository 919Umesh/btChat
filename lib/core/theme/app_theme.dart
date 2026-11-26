import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand palette ──────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color accent = Color(0xFFFF6B6B);

  // ── Light surfaces ─────────────────────────────────────────────────────────
  static const Color _lightBackground = Color(0xFFF6F8FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightDivider = Color(0xFFE8ECF0);
  static const Color _lightInputFill = Color(0xFFF0F2F5);
  static const Color _lightTextPrimary = Color(0xFF1A1D21);
  static const Color _lightTextSecondary = Color(0xFF6B7280);
  static const Color _lightTextTertiary = Color(0xFF9CA3AF);

  // ── Dark surfaces ──────────────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkCard = Color(0xFF161B22);
  static const Color _darkDivider = Color(0xFF21262D);
  static const Color _darkInputFill = Color(0xFF1C2128);
  static const Color _darkTextPrimary = Color(0xFFE6EDF3);
  static const Color _darkTextSecondary = Color(0xFF8B949E);
  static const Color _darkTextTertiary = Color(0xFF484F58);

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color online = Color(0xFF3FB950);
  static const Color error = Color(0xFFFA4549);
  static const Color warning = Color(0xFFD29922);

  // ── Context-aware getters ──────────────────────────────────────────────────
  static Color cardColor(BuildContext context) =>
      _isDark(context) ? _darkCard : _lightCard;

  static Color inputFillColor(BuildContext context) =>
      _isDark(context) ? _darkInputFill : _lightInputFill;

  static Color dividerColor(BuildContext context) =>
      _isDark(context) ? _darkDivider : _lightDivider;

  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? _darkTextPrimary : _lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? _darkTextSecondary : _lightTextSecondary;

  static Color textTertiary(BuildContext context) =>
      _isDark(context) ? _darkTextTertiary : _lightTextTertiary;

  static Color surfaceColor(BuildContext context) =>
      _isDark(context) ? _darkSurface : _lightSurface;

  static Color bubbleMe(BuildContext context) => primary;

  static Color bubblePeer(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1C2128) : const Color(0xFFF0F2F5);

  static Color bubbleTextMe(BuildContext context) => Colors.white;

  static Color bubbleTextPeer(BuildContext context) =>
      _isDark(context) ? _darkTextPrimary : _lightTextPrimary;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Shared constants ───────────────────────────────────────────────────────
  static const double radiusSmall = 12;
  static const double radiusMedium = 16;
  static const double radiusLarge = 20;
  static const double radiusXL = 24;
  static const double radiusPill = 28;

  static const _fontFallback = [
    '.SF Pro Text',
    '-apple-system',
    'BlinkMacSystemFont',
    'Roboto',
    'sans-serif',
  ];

  // ── Light theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: _lightBackground,
      fontFamilyFallback: _fontFallback,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: _lightSurface,
        onSurface: _lightTextPrimary,
        error: error,
        onError: Colors.white,
        outline: _lightDivider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _lightTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        shape: Border(
          bottom: BorderSide(color: _lightDivider, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightDivider,
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: _lightTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        headlineMedium: TextStyle(
          color: _lightTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        titleLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamilyFallback: _fontFallback,
        ),
        titleMedium: TextStyle(
          color: _lightTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: _fontFallback,
        ),
        bodyLarge: TextStyle(
          color: _lightTextPrimary,
          fontSize: 15,
          height: 1.45,
          fontFamilyFallback: _fontFallback,
        ),
        bodyMedium: TextStyle(
          color: _lightTextSecondary,
          fontSize: 14,
          height: 1.4,
          fontFamilyFallback: _fontFallback,
        ),
        bodySmall: TextStyle(
          color: _lightTextTertiary,
          fontSize: 12,
          fontFamilyFallback: _fontFallback,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: _lightDivider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          color: _lightTextTertiary,
          fontSize: 15,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
        showDragHandle: true,
        dragHandleColor: _lightDivider,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _lightTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: _darkBackground,
      fontFamilyFallback: _fontFallback,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: Colors.white,
        surface: _darkSurface,
        onSurface: _darkTextPrimary,
        error: error,
        onError: Colors.white,
        outline: _darkDivider,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _darkTextPrimary, size: 20),
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        shape: Border(
          bottom: BorderSide(color: _darkDivider, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 0.5,
        space: 0.5,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: _darkTextPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        headlineMedium: TextStyle(
          color: _darkTextPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          fontFamilyFallback: _fontFallback,
        ),
        titleLarge: TextStyle(
          color: _darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamilyFallback: _fontFallback,
        ),
        titleMedium: TextStyle(
          color: _darkTextPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: _fontFallback,
        ),
        bodyLarge: TextStyle(
          color: _darkTextPrimary,
          fontSize: 15,
          height: 1.45,
          fontFamilyFallback: _fontFallback,
        ),
        bodyMedium: TextStyle(
          color: _darkTextSecondary,
          fontSize: 14,
          height: 1.4,
          fontFamilyFallback: _fontFallback,
        ),
        bodySmall: TextStyle(
          color: _darkTextTertiary,
          fontSize: 12,
          fontFamilyFallback: _fontFallback,
        ),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.1,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamilyFallback: _fontFallback,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: _darkDivider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkInputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusXL),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          color: _darkTextTertiary,
          fontSize: 15,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          fontFamilyFallback: _fontFallback,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: _darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLarge)),
        ),
        showDragHandle: true,
        dragHandleColor: _darkDivider,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _darkTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }
}

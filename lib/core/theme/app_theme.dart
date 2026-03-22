import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP COLORS  —  exact values taken from the Stitch-generated screens
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // ── Backgrounds (dark) ────────────────────────────────────────────────────
  static const darkBg = Color(0xFF0A0E1A); // scaffold / deepest layer
  static const darkSurface = Color(0xFF141928); // cards, bottom sheets
  static const darkCard = Color(0xFF1A2035); // elevated tiles inside cards

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const primary = Color(0xFF7C6FF7); // purple — buttons, FAB, active
  static const primaryLight = Color(0xFF9B8FF9); // lighter purple — gradients
  static const gradientEnd =
      Color(0xFFB3A8FF); // far end of balance card gradient

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const income = Color(0xFF4CD97B); // green  — income amounts
  static const expense = Color(0xFFFF6B6B); // red    — expense amounts
  static const warning = Color(0xFFF59E0B); // amber  — budget near limit

  // ── Text ──────────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF); // main labels
  static const textSecondary = Color(0xFF8A94B0); // subtitles, icons
  static const textMuted = Color(0xFF4A5270); // hints, section headers

  // ── Category palette  (index == CategoryType.index in Phase 2) ────────────
  static const List<Color> categories = [
    Color(0xFFF97316), // 0  Food        orange
    Color(0xFF3B82F6), // 1  Transport   blue
    Color(0xFFEC4899), // 2  Shopping    pink
    Color(0xFF8B5CF6), // 3  Bills       violet
    Color(0xFF14B8A6), // 4  Health      teal
    Color(0xFFF59E0B), // 5  Education   amber
    Color(0xFF4CD97B), // 6  Income      green
    Color(0xFF64748B), // 7  Other       slate
  ];

  // ── Light-mode backgrounds ─────────────────────────────────────────────────
  static const lightBg = Color(0xFFF1F5F9);
  static const lightSurface = Color(0xFFF8FAFC);
}

// ─────────────────────────────────────────────────────────────────────────────
// APP THEME
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── DARK ──────────────────────────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final tt = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      textTheme: tt,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      cardColor: AppColors.darkCard,
      cardTheme: const CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14),
        labelStyle:
            GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle:
              GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.darkCard),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerColor: AppColors.darkCard,
      dividerTheme: const DividerThemeData(
          color: AppColors.darkCard, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        titleTextStyle: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary),
        contentTextStyle:
            GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.darkCard,
      ),
    );
  }

  // ── LIGHT ─────────────────────────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final tt = GoogleFonts.dmSansTextTheme(base.textTheme).apply(
      bodyColor: const Color(0xFF0A0E1A),
      displayColor: const Color(0xFF0A0E1A),
    );

    return base.copyWith(
      textTheme: tt,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSurface: const Color(0xFF0A0E1A),
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      cardColor: Colors.white,
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0A0E1A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4A5270)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle:
            GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),
      dividerColor: const Color(0xFFE2E8F0),
      dividerTheme: const DividerThemeData(
          color: Color(0xFFE2E8F0), thickness: 1, space: 1),
    );
  }
}

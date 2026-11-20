import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Font Helpers ──────────────────────────────────────────────────────────────
// Display / Headings / Brand  →  Space Grotesk  (geometric, premium, modern)
// Body / Labels / UI text     →  Inter           (gold-standard UI readability)

class AppFonts {
  // ── Space Grotesk (headings / brand / display) ─────────────────────────────
  static TextStyle grotesk({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppTheme.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  // ── Inter (body / labels / input / descriptions) ───────────────────────────
  static TextStyle inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppTheme.textPrimary,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
}

class AppTheme {
  // ─── Brand Palette ────────────────────────────────────────────────────────
  static const Color background  = Color(0xFF0A0A0C);
  static const Color surface     = Color(0xFF111114);
  static const Color surfaceHigh = Color(0xFF18181C);
  static const Color cardBg      = Color(0xFF1C1C21);
  static const Color cardBorder  = Color(0xFF2C2C34);

  static const Color primary     = Color(0xFFE8701A); // Studio Orange
  static const Color primaryGlow = Color(0xFFFF8C3A); // Lighter for glow
  static const Color primaryDim  = Color(0xFFA0501A); // Darker tint

  static const Color textPrimary   = Color(0xFFF2F2F5);
  static const Color textSecondary = Color(0xFF8A8A96);
  static const Color textMuted     = Color(0xFF4A4A56);

  static const Color success = Color(0xFF2ECC71);
  static const Color error   = Color(0xFFE74C3C);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, Color(0xFFB84F10)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A0D00), Color(0xFF0A0A0C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cardGlow = LinearGradient(
    colors: [
      primary.withValues(alpha: 0.18),
      const Color(0xFF9E2A2B).withValues(alpha: 0.10)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Decorations ──────────────────────────────────────────────────────────
  static BoxDecoration card({
    Color? color,
    double radius = 16.0,
    bool glowing = false,
    bool bordered = true,
  }) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: BorderRadius.circular(radius),
      border: bordered
          ? Border.all(
              color: glowing
                  ? primary.withValues(alpha: 0.35)
                  : cardBorder,
              width: glowing ? 1.2 : 0.8,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        if (glowing)
          BoxShadow(
            color: primary.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -2,
          ),
      ],
    );
  }

  // ─── Theme Data ───────────────────────────────────────────────────────────
  static ThemeData get themeData {
    // Base text theme from Inter for body text defaults
    final base = GoogleFonts.interTextTheme();

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryGlow,
        surface: surface,
        error: error,
      ),
      textTheme: base.copyWith(
        // ── Display (station name, song title hero)
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -1.2,
          height: 1.05,
        ),
        // ── Headlines
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
          height: 1.12,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.15,
        ),
        // ── Titles
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.1,
          height: 1.3,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.3,
        ),
        // ── Body
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.55,
          letterSpacing: -0.1,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.55,
          letterSpacing: -0.1,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
          letterSpacing: 0,
        ),
        // ── Labels
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.2,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 22),
      // ── Input fields ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: cardBorder, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 22);
          }
          return const IconThemeData(color: textSecondary, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w700, color: primary,
              letterSpacing: 0.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w500, color: textSecondary,
            letterSpacing: 0.2,
          );
        }),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? primary : textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.3)
              : cardBorder;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardBg,
        contentTextStyle: GoogleFonts.inter(
            color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

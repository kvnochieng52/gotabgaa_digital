import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand palette lifted from the web frontend (`globals.css`):
///   Red    #E63946
///   Orange #FF7A1A
///   Amber  #FFA31A
///   Ink    #0A0A0F
///   Cream  #FBF7F2 (light bg)
class AppColors {
  static const brandRed = Color(0xFFE63946);
  static const brandOrange = Color(0xFFFF7A1A);
  static const brandAmber = Color(0xFFFFA31A);

  static const ink = Color(0xFF0A0A0F);
  static const cream = Color(0xFFFBF7F2);

  // Dark surfaces (streaming/cinematic feel — used inside cards & hero)
  static const bgDark = Color(0xFF08080A);
  static const bgDarkElevated = Color(0xFF101014);

  // Text on light bg
  static const textLight = Color(0xFF0A0A0F);
  static const textLightDim = Color(0xB80F0F14);
  static const textLightMuted = Color(0x8C0F0F14);

  // Lines on light bg
  static const lineLight = Color(0x120F0F14);
  static const lineLightStrong = Color(0x1F0F0F14);

  /// Left-to-right brand gradient — 135° in CSS = topLeft → bottomRight in Flutter.
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandRed, brandOrange, brandAmber],
    stops: [0.0, 0.55, 1.0],
  );
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      // Body → Inter (readable), display → Poppins (bold hero)
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: AppColors.textLight),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: AppColors.textLight),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: AppColors.textLightDim),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        letterSpacing: -0.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightDim,
        letterSpacing: 0.2,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: -0.6,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textLight,
        letterSpacing: -0.8,
        height: 1.05,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: AppColors.textLight,
        letterSpacing: -1.0,
        height: 1.0,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textLightMuted,
        letterSpacing: 0.4,
      ),
    );

    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandOrange,
        brightness: Brightness.light,
        primary: AppColors.brandOrange,
        secondary: AppColors.brandRed,
        error: AppColors.brandRed,
        surface: Colors.white,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.lineLight, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.brandOrange,
        secondarySelectedColor: AppColors.brandOrange,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightDim,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        side: BorderSide(color: AppColors.lineLightStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.brandRed,
        unselectedItemColor: AppColors.textLightMuted,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 12,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lineLight,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

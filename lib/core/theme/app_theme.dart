// Theme System for Zikr Sunnah App
// Deep emerald dark theme, warm cream text, restrained gold accent
// Islamic geometric pattern support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_theme.g.dart';

// ============================================
// COLOR PALETTE
// ============================================
class AppColors {
  // Dark theme - Deep Emerald
  static const Color darkBackground = Color(0xFF0A1A16);        // Deep emerald near-black
  static const Color darkSurface = Color(0xFF12261E);            // Slightly lighter surface
  static const Color darkSurfaceVariant = Color(0xFF1A3329);     // Cards, containers
  static const Color darkOutline = Color(0xFF2D4A3D);            // Borders, dividers
  
  static const Color darkTextPrimary = Color(0xFFF5F0E8);        // Warm cream
  static const Color darkTextSecondary = Color(0xFFD4C8B8);      // Muted cream
  static const Color darkTextTertiary = Color(0xFF9BA89F);       // Subtle text
  
  static const Color darkAccent = Color(0xFFD4A843);             // Restrained gold
  static const Color darkAccentLight = Color(0xFFE8C87A);        // Lighter gold for hover
  static const Color darkAccentDark = Color(0xFFB89030);         // Darker gold for press
  
  static const Color darkSuccess = Color(0xFF4A7C5A);            // Muted green
  static const Color darkWarning = Color(0xFFC49A2C);            // Warm amber
  static const Color darkError = Color(0xFF8B4A4A);              // Muted red
  
  // Light theme - Warm Cream
  static const Color lightBackground = Color(0xFFFDF8F0);        // Warm cream
  static const Color lightSurface = Color(0xFFFFFFFF);           // White
  static const Color lightSurfaceVariant = Color(0xFFF0E8DB);    // Light cream
  static const Color lightOutline = Color(0xFFD4C8B8);           // Cream borders
  
  static const Color lightTextPrimary = Color(0xFF1A261E);       // Deep emerald
  static const Color lightTextSecondary = Color(0xFF3D4A3F);     // Dark emerald
  static const Color lightTextTertiary = Color(0xFF7A8A7F);      // Muted emerald
  
  static const Color lightAccent = Color(0xFFB88A2A);            // Gold
  static const Color lightAccentLight = Color(0xFFD4A843);       // Lighter gold
  static const Color lightAccentDark = Color(0xFF9A7320);        // Darker gold
  
  static const Color lightSuccess = Color(0xFF3D6B4A);
  static const Color lightWarning = Color(0xFFB8902A);
  static const Color lightError = Color(0xFF9C4A4A);
  
  // Common
  static const Color islamicGreen = Color(0xFF006D5B);
  static const Color islamicGold = Color(0xFFD4A843);
  
  // Pattern opacity
  static const double patternOpacityDark = 0.03;
  static const double patternOpacityLight = 0.05;
}

// ============================================
// TEXT STYLES
// ============================================
class AppTextStyles {
  static const String fontFamily = 'NotoSansArabic'; // Will use system fallback
  
  // Display styles
  static TextStyle displayLarge(Color textColor) => TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    color: textColor,
    height: 1.0,
    letterSpacing: -4,
  );
  
  static TextStyle displayMedium(Color textColor) => TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w300,
    color: textColor,
    height: 1.05,
    letterSpacing: -2,
  );
  
  static TextStyle displaySmall(Color textColor) => TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.1,
    letterSpacing: -1,
  );
  
  // Headline styles
  static TextStyle headlineLarge(Color textColor) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.2,
    letterSpacing: 0,
  );
  
  static TextStyle headlineMedium(Color textColor) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.25,
    letterSpacing: 0,
  );
  
  static TextStyle headlineSmall(Color textColor) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.3,
    letterSpacing: 0,
  );
  
  // Title styles
  static TextStyle titleLarge(Color textColor) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.3,
    letterSpacing: 0,
  );
  
  static TextStyle titleMedium(Color textColor) => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static TextStyle titleSmall(Color textColor) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  // Body styles
  static TextStyle bodyLarge(Color textColor) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.5,
    letterSpacing: 0.2,
  );
  
  static TextStyle bodyMedium(Color textColor) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.5,
    letterSpacing: 0.2,
  );
  
  static TextStyle bodySmall(Color textColor) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.5,
    letterSpacing: 0.3,
  );
  
  // Label styles
  static TextStyle labelLarge(Color textColor) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static TextStyle labelMedium(Color textColor) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  static TextStyle labelSmall(Color textColor) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textColor,
    height: 1.4,
    letterSpacing: 0.5,
  );
  
  // Arabic text styles (larger for readability)
  static TextStyle arabicLarge(Color textColor) => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.6,
    fontFamily: 'NotoSansArabic',
  );
  
  static TextStyle arabicMedium(Color textColor) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.6,
    fontFamily: 'NotoSansArabic',
  );
  
  static TextStyle arabicSmall(Color textColor) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: textColor,
    height: 1.6,
    fontFamily: 'NotoSansArabic',
  );
}

// ============================================
// THEME DATA
// ============================================
class AppTheme {
  static ThemeData darkTheme = _buildDarkTheme();
  static ThemeData lightTheme = _buildLightTheme();
  
  static ThemeData _buildDarkTheme() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.darkAccent,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.darkAccentLight,
      onSecondary: AppColors.darkBackground,
      tertiary: AppColors.darkSuccess,
      onTertiary: AppColors.darkBackground,
      error: AppColors.darkError,
      onError: AppColors.darkTextPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.lightSurface,
      onInverseSurface: AppColors.lightTextPrimary,
      inversePrimary: AppColors.lightAccent,
    );
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      
      // Typography
      textTheme: _buildTextTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary, AppColors.darkTextTertiary),
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge(AppColors.darkTextPrimary),
      ),
      
      // Cards
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceVariant,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.darkOutline, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge(AppColors.darkBackground),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed) 
              ? AppColors.darkAccentDark.withValues(alpha: 0.3)
              : states.contains(WidgetState.hovered)
                ? AppColors.darkAccentLight.withValues(alpha: 0.2)
                : null,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkAccent,
          side: BorderSide(color: AppColors.darkAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge(AppColors.darkAccent),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkAccent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.labelMedium(AppColors.darkAccent),
        ),
      ),
      
      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkError),
        ),
        labelStyle: AppTextStyles.bodyMedium(AppColors.darkTextSecondary),
        hintStyle: AppTextStyles.bodyMedium(AppColors.darkTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall(AppColors.darkAccent),
        unselectedLabelStyle: AppTextStyles.labelSmall(AppColors.darkTextTertiary),
      ),
      
      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkAccent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(WidgetState.selected)
            ? AppTextStyles.labelSmall(AppColors.darkAccent)
            : AppTextStyles.labelSmall(AppColors.darkTextTertiary),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => states.contains(WidgetState.selected)
            ? IconThemeData(color: AppColors.darkAccent, size: 26)
            : IconThemeData(color: AppColors.darkTextTertiary, size: 24),
        ),
        height: 72,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 0.5,
        space: 1,
      ),
      
      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.bodyLarge(AppColors.darkTextPrimary),
        subtitleTextStyle: AppTextStyles.bodyMedium(AppColors.darkTextSecondary),
        iconColor: AppColors.darkTextSecondary,
      ),
      
      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkOutline, width: 0.5),
        ),
        titleTextStyle: AppTextStyles.titleLarge(AppColors.darkTextPrimary),
        contentTextStyle: AppTextStyles.bodyMedium(AppColors.darkTextSecondary),
      ),
      
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: AppColors.darkSurface,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkAccent.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium(AppColors.darkTextPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium(AppColors.darkAccent),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.darkOutline),
        ),
      ),
      
      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
            ? AppColors.darkAccent
            : AppColors.darkTextTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
            ? AppColors.darkAccent.withValues(alpha: 0.5)
            : AppColors.darkOutline,
        ),
      ),
      
      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.darkAccent,
        inactiveTrackColor: AppColors.darkOutline,
        thumbColor: AppColors.darkAccent,
        overlayColor: AppColors.darkAccent.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.darkAccent,
        valueIndicatorTextStyle: AppTextStyles.labelSmall(AppColors.darkBackground),
      ),
      
      // Progress
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.darkAccent,
        linearTrackColor: AppColors.darkOutline,
        circularTrackColor: AppColors.darkOutline,
      ),
      
      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkOutline, width: 0.5),
        ),
        textStyle: AppTextStyles.bodySmall(AppColors.darkTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium(AppColors.darkTextPrimary),
        actionTextColor: AppColors.darkAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
  
  static ThemeData _buildLightTheme() {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightAccent,
      onPrimary: AppColors.lightBackground,
      secondary: AppColors.lightAccentLight,
      onSecondary: AppColors.lightBackground,
      tertiary: AppColors.lightSuccess,
      onTertiary: AppColors.lightBackground,
      error: AppColors.lightError,
      onError: AppColors.lightTextPrimary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutline,
      shadow: Colors.black26,
      scrim: Colors.black26,
      inverseSurface: AppColors.darkSurface,
      onInverseSurface: AppColors.darkTextPrimary,
      inversePrimary: AppColors.darkAccent,
    );
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightSurface,
      
      textTheme: _buildTextTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary, AppColors.lightTextTertiary),
      
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge(AppColors.lightTextPrimary),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.lightOutline, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightAccent,
          foregroundColor: AppColors.lightBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge(AppColors.lightBackground),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.pressed)
              ? AppColors.lightAccentDark.withValues(alpha: 0.3)
              : states.contains(WidgetState.hovered)
                ? AppColors.lightAccentLight.withValues(alpha: 0.2)
                : null,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightAccent,
          side: BorderSide(color: AppColors.lightAccent, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.labelLarge(AppColors.lightAccent),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightAccent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppTextStyles.labelMedium(AppColors.lightAccent),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.lightError),
        ),
        labelStyle: AppTextStyles.bodyMedium(AppColors.lightTextSecondary),
        hintStyle: AppTextStyles.bodyMedium(AppColors.lightTextTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightAccent,
        unselectedItemColor: AppColors.lightTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelSmall(AppColors.lightAccent),
        unselectedLabelStyle: AppTextStyles.labelSmall(AppColors.lightTextTertiary),
      ),
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightAccent.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) => states.contains(WidgetState.selected)
            ? AppTextStyles.labelSmall(AppColors.lightAccent)
            : AppTextStyles.labelSmall(AppColors.lightTextTertiary),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => states.contains(WidgetState.selected)
            ? IconThemeData(color: AppColors.lightAccent, size: 26)
            : IconThemeData(color: AppColors.lightTextTertiary, size: 24),
        ),
        height: 72,
      ),
      
      dividerTheme: DividerThemeData(
        color: AppColors.lightOutline,
        thickness: 0.5,
        space: 1,
      ),
      
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.bodyLarge(AppColors.lightTextPrimary),
        subtitleTextStyle: AppTextStyles.bodyMedium(AppColors.lightTextSecondary),
        iconColor: AppColors.lightTextSecondary,
      ),
      
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.lightOutline, width: 0.5),
        ),
        titleTextStyle: AppTextStyles.titleLarge(AppColors.lightTextPrimary),
        contentTextStyle: AppTextStyles.bodyMedium(AppColors.lightTextSecondary),
      ),
      
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: AppColors.lightSurface,
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.lightAccent.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium(AppColors.lightTextPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium(AppColors.lightAccent),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.lightOutline),
        ),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
            ? AppColors.lightAccent
            : AppColors.lightTextTertiary,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (states) => states.contains(WidgetState.selected)
            ? AppColors.lightAccent.withValues(alpha: 0.5)
            : AppColors.lightOutline,
        ),
      ),
      
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.lightAccent,
        inactiveTrackColor: AppColors.lightOutline,
        thumbColor: AppColors.lightAccent,
        overlayColor: AppColors.lightAccent.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.lightAccent,
        valueIndicatorTextStyle: AppTextStyles.labelSmall(AppColors.lightBackground),
      ),
      
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.lightAccent,
        linearTrackColor: AppColors.lightOutline,
        circularTrackColor: AppColors.lightOutline,
      ),
      
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightOutline, width: 0.5),
        ),
        textStyle: AppTextStyles.bodySmall(AppColors.lightTextPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium(AppColors.lightTextPrimary),
        actionTextColor: AppColors.lightAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
    );
  }
  
  static TextTheme _buildTextTheme(Color primary, Color secondary, Color tertiary) {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge(primary),
      displayMedium: AppTextStyles.displayMedium(primary),
      displaySmall: AppTextStyles.displaySmall(primary),
      headlineLarge: AppTextStyles.headlineLarge(primary),
      headlineMedium: AppTextStyles.headlineMedium(primary),
      headlineSmall: AppTextStyles.headlineSmall(primary),
      titleLarge: AppTextStyles.titleLarge(primary),
      titleMedium: AppTextStyles.titleMedium(primary),
      titleSmall: AppTextStyles.titleSmall(primary),
      bodyLarge: AppTextStyles.bodyLarge(primary),
      bodyMedium: AppTextStyles.bodyMedium(primary),
      bodySmall: AppTextStyles.bodySmall(tertiary),
      labelLarge: AppTextStyles.labelLarge(primary),
      labelMedium: AppTextStyles.labelMedium(primary),
      labelSmall: AppTextStyles.labelSmall(tertiary),
    );
  }
}

// ============================================
// PATTERN PAINTER
// ============================================
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double scale;
  
  IslamicPatternPainter({
    required this.color,
    required this.opacity,
    this.scale = 1.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 * scale;
    
    final spacing = 80.0 * scale;
    final offset = spacing / 2;
    
    // Draw geometric pattern - simplified 8-pointed star grid
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final cx = x + ((y ~/ spacing) % 2 == 0 ? 0 : offset);
        _drawStar(canvas, paint, Offset(cx, y), 15 * scale);
      }
    }
  }
  
  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    const int points = 8;
    final angleStep = 2 * 3.14159 / points;
    
    for (int i = 0; i < points; i++) {
      final angle = i * angleStep - 3.14159 / 2;
      final outerRadius = radius;
      final innerRadius = radius * 0.4;
      
      final outerX = center.dx + outerRadius * cos(angle);
      final outerY = center.dy + outerRadius * sin(angle);
      
      final innerAngle = angle + angleStep / 2;
      final innerX = center.dx + innerRadius * cos(innerAngle);
      final innerY = center.dy + innerRadius * sin(innerAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  double cos(double x) => cos(x);
  double sin(double x) => sin(x);
  
  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) {
    return oldDelegate.color != color || 
           oldDelegate.opacity != opacity || 
           oldDelegate.scale != scale;
  }
}

// ============================================
// THEME PROVIDERS
// ============================================
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
  
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

@riverpod
ThemeData appTheme(AppThemeRef ref) {
  final themeMode = ref.watch(themeModeNotifierProvider);
  final brightness = ref.watch(platformBrightnessProvider);
  
  final effectiveBrightness = switch (themeMode) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => brightness,
  };
  
  return effectiveBrightness == Brightness.dark 
    ? AppTheme.darkTheme 
    : AppTheme.lightTheme;
}

@riverpod
Brightness platformBrightness(PlatformBrightnessRef ref) {
  // This will be overridden by the app widget with MediaQuery
  return Brightness.light;
}
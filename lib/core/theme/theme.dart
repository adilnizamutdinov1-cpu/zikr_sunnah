// Тема приложения: глубокий изумруд, тёплый кремовый текст, сдержанное золото.
// Material 3, сетка 8pt, доступность для пожилых (крупный текст, высокий контраст).

import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Тёмная палитра (основная)
  static const Color darkBackground = Color(0xFF0A1A16); // глубокий изумруд
  static const Color darkSurface = Color(0xFF12261E);
  static const Color darkSurfaceVariant = Color(0xFF1A3329);
  static const Color darkTextPrimary = Color(0xFFF5F0E8); // тёплый кремовый
  static const Color darkTextSecondary = Color(0xFFD4C8B8);
  static const Color darkTextMuted = Color(0xFF8A9B91);

  // Светлая палитра
  static const Color lightBackground = Color(0xFFF7F3EA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDE6D6);
  static const Color lightTextPrimary = Color(0xFF1A2A23);
  static const Color lightTextSecondary = Color(0xFF3D5046);
  static const Color lightTextMuted = Color(0xFF7A8B82);

  // Акцент — сдержанное золото (для обеих тем)
  static const Color islamicGold = Color(0xFFD4A843);
  static const Color islamicGoldDim = Color(0xFF8E7230);
  static const Color islamicGoldSoft = Color(0x44D4A843); // полупрозрачное для волн

  // Палитра цветов зикров (спокойные, землистые тона)
  static const List<int> zikrPalette = [
    0xFFD4A843, // золото
    0xFF7AA38C, // приглушённый зелёный
    0xFF6E8FAE, // пыльно-синий
    0xFFB07A4A, // охра
    0xFF9C6B8E, // приглушённая слива
    0xFF5E8B7E, // тёмный изумруд
    0xFFC98A6B, // терракота
    0xFF7B7B6E, // оливково-серый
  ];
}

class AppTextStyles {
  AppTextStyles._();

  // Цифры счётчика — очень крупные
  static const TextStyle counterNumber = TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w300,
    letterSpacing: -2,
    height: 1.0,
  );

  // Арабский текст зикра
  static const TextStyle arabic = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  // Транскрипция
  static const TextStyle transliteration = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Перевод / подписи
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.darkSurface,
          primary: AppColors.islamicGold,
          secondary: AppColors.islamicGold,
          onPrimary: AppColors.darkBackground,
          onSurface: AppColors.darkTextPrimary,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.darkTextPrimary,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.islamicGold,
          unselectedItemColor: AppColors.darkTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.darkSurfaceVariant,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurfaceVariant,
          contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          surface: AppColors.lightSurface,
          primary: AppColors.islamicGoldDim,
          secondary: AppColors.islamicGoldDim,
          onPrimary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          foregroundColor: AppColors.lightTextPrimary,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.lightSurfaceVariant),
          ),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.islamicGoldDim,
          unselectedItemColor: AppColors.lightTextMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.lightSurfaceVariant,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightSurfaceVariant,
          contentTextStyle:
              const TextStyle(color: AppColors.lightTextPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
      );
}

/// Едва заметный исламский геометрический узор (8-лучевая звезда) на фоне.
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  const IslamicPatternPainter({
    this.color = AppColors.islamicGold,
    this.opacity = 0.04,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const step = 64.0;
    for (double x = -step; x < size.width + step; x += step) {
      for (double y = -step; y < size.height + step; y += step) {
        _drawEightStar(canvas, Offset(x, y), step * 0.42, paint);
      }
    }
  }

  void _drawEightStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
    // внутренний повёрнутый квадрат
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(math.pi / 8);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset.zero, width: radius * 1.1, height: radius * 1.1),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter old) =>
      color != old.color || opacity != old.opacity;
}

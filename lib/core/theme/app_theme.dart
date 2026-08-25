import 'package:flutter/material.dart';
import 'app_colors.dart';

/// الثيم المركزي للتطبيق؛ كل الصفحات تستخدمه بدل تعريف ثيم خاص بها.
abstract final class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true, // تفعيل مكونات Material 3 الحديثة.
      fontFamily: 'ThmanyahSerifDisplay', // استخدام خط ثمانية في التطبيق كله.
      scaffoldBackgroundColor: AppColors.panelNavy, // لون احتياطي خلف الصورة.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.solarBlue, // اللون الذي يبني منه Flutter بقية الدرجات.
        brightness: Brightness.dark, // نصوص فاتحة فوق الخلفية الداكنة والزجاج.
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(fontSize: 17, height: 1.5),
        bodyMedium: TextStyle(fontSize: 15, height: 1.45),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // يجعل الحقول أسهل قراءة فوق الخلفية.
        fillColor: Colors.white.withValues(alpha: 0.14), // سطح زجاجي خفيف.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), // حواف موحدة لكل الحقول.
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: AppColors.textLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textLight),
        hintStyle: TextStyle(color: AppColors.textLight.withValues(alpha: 0.68)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textLight,
          foregroundColor: AppColors.panelNavy,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}
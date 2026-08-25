import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// خلفية موحدة لكل الصفحات مع طبقة حماية تجعل النص مقروءًا.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child; // محتوى الصفحة الذي سيظهر فوق الخلفية.

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand, // ملء مساحة الشاشة دون حسابات يدوية.
      children: [
        Image.asset(
          'assets/images/shamsuna_background.webp', // مسار الصورة المحلية.
          fit: BoxFit.cover, // تغطية الشاشة مع الحفاظ على نسبة الصورة.
          alignment: Alignment.topCenter, // إبقاء السماء في الجزء العلوي.
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: AppColors.panelNavy),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.panelNavy.withValues(
                  alpha: 0.58,
                ), // تعتيم متوسط في الأعلى.
                AppColors.panelNavy.withValues(
                  alpha: 0.72,
                ), // تعتيم أقوى أسفل الشاشة.
              ],
            ),
          ),
        ),

        SafeArea(child: child), // احترام شريط الحالة وأزرار النظام.
      ],
    );
  }
}

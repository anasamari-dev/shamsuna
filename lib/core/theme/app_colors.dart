import 'package:flutter/material.dart';

/// ألوان الهوية المستخرجة بصريًا من السماء والألواح والهيكل الأزرق.
/// وضعها في مكان واحد يجعل تعديل الهوية آمنًا وسريعًا.
abstract final class AppColors {
  static const sky = Color(0xFFE7F0FB); // لون السماء الفاتح.
  static const cloud = Color(0xFFC9D9EB); // لون السحب البارد.
  static const solarBlue = Color(0xFF1769A8); // الأزرق المستوحى من الهيكل.
  static const panelNavy = Color(0xFF071D31); // خلفية زجاجية داكنة.
  static const textDark = Color(0xFF082238); // النص فوق الأسطح الفاتحة.
  static const textLight = Color(0xFFF7FBFF); // النص فوق الأسطح الداكنة.
  static const border = Color(0xB3FFFFFF); // حدود زجاجية شفافة.
  static const error = Color(0xFFC62828); // خطأ واضح وليس ورديًا.
  static const textMuted = Color(0xFFDCE8F2); // نص ثانوي هادئ فوق الخلفية.
}

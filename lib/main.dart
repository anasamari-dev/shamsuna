import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

/// يبدأ التطبيق بعد تهيئة Flutter وSupabase بالترتيب الصحيح.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تهيئة إطار Flutter قبل الخدمات.

  await Supabase.initialize(
    url:
        'https://kfrwgumppomhqnnswdeh.supabase.co', // رابط مشروع Supabase الجديد.
    publishableKey:
        'sb_publishable_jI24mhj0LVPZGG1sGimwYw_DzyFFny2', // المفتاح العام الآمن للتطبيق.
  );

  runApp(const ShamsunaApp()); // تشغيل التطبيق بعد اكتمال التهيئة.
}

/// الجذر العام للتطبيق.
class ShamsunaApp extends StatelessWidget {
  const ShamsunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // إخفاء شريط التطوير.
      title: 'شمسنا', // اسم التطبيق.
      theme: AppTheme.light(), // تطبيق الثيم الموحد.
      locale: const Locale('ar'), // العربية هي اللغة الوحيدة.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl, // تثبيت اتجاه RTL.
          child: child ?? const SizedBox.shrink(), // حماية من child فارغ.
        );
      },
      home: const AuthGate(), // الدخول عبر بوابة الجلسة.
    );
  }
}

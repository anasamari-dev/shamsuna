import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
import '../../../home/presentation/pages/home_page.dart';

/// يوجه المستخدم حسب وجود جلسة Supabase فعالة.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth; // الوصول إلى خدمة المصادقة.

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange, // مراقبة الدخول والخروج لحظيًا.
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingView(); // شاشة مؤقتة أثناء قراءة الجلسة.
        }

        final session =
            snapshot.data?.session ??
            auth.currentSession; // دعم الجلسة الحالية.
        return session == null
            ? const LoginPage()
            : const HomePage(); // اختيار الوجهة.
      },
    );
  }
}

/// شاشة تحميل بسيطة لا تعتمد على صفحة أخرى.
class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login_page.dart';
<<<<<<< HEAD
import 'reset_password_page.dart';

import '../../../home/presentation/pages/main_shell_page.dart';
=======
import '../../../home/presentation/pages/home_page.dart';
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

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

<<<<<<< HEAD
        final authState = snapshot.data;
        if (authState?.event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordPage();
        }

        final session =
            authState?.session ?? auth.currentSession; // دعم الجلسة الحالية.
        return session == null
            ? const LoginPage()
            : const MainShellPage(); // اختيار الوجهة.
=======
        final session =
            snapshot.data?.session ??
            auth.currentSession; // دعم الجلسة الحالية.
        return session == null
            ? const LoginPage()
            : const HomePage(); // اختيار الوجهة.
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
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

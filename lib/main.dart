<<<<<<< HEAD
import 'dart:async';

import 'package:app_links/app_links.dart';
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

<<<<<<< HEAD
/// مفتاح عام للوصول إلى الملاح بعد فتح رابط من البريد.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// يبدأ التطبيق بعد تهيئة Flutter وSupabase بالترتيب الصحيح.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kfrwgumppomhqnnswdeh.supabase.co',
    publishableKey: 'sb_publishable_jI24mhj0LVPZGG1sGimwYw_DzyFFny2',
  );

  runApp(const ShamsunaApp());
}

/// الجذر العام للتطبيق والمسؤول عن استقبال الروابط العميقة.
class ShamsunaApp extends StatefulWidget {
  const ShamsunaApp({super.key});

  @override
  State<ShamsunaApp> createState() => _ShamsunaAppState();
}

class _ShamsunaAppState extends State<ShamsunaApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  bool _confirmationHandled = false;

  @override
  void initState() {
    super.initState();
    _listenToDeepLinks();
  }

  Future<void> _listenToDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleDeepLink(initialUri);
      }

      _linkSubscription = _appLinks.uriLinkStream.listen(
        (uri) => _handleDeepLink(uri),
        onError: (_) {},
      );
    } catch (_) {
      // عدم وجود رابط عند التشغيل لا يمنع فتح التطبيق.
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final isEmailConfirmation =
        uri.scheme == 'shamsuna' && uri.host == 'email-confirmed';

    if (!isEmailConfirmation || _confirmationHandled) {
      return;
    }

    _confirmationHandled = true;
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await Supabase.instance.client.auth.signOut();
    // تتولى AuthGate عرض LoginPage تلقائيًا بعد وصول حدث تسجيل الخروج.
    // عدم تنفيذ push يدوي يمنع إنشاء صفحتي دخول فوق بعضهما وتعطيل الطلب التالي.
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'شمسنا',
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
=======
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
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
    );
  }
}

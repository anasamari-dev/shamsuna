import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_gate.dart';

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
    );
  }
}

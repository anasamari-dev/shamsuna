import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';

/// صفحة الدخول الرئيسية للمستخدم العربي.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // مفتاح للتحقق من الحقول.
  final _emailController = TextEditingController(); // حقل البريد.
  final _passwordController = TextEditingController(); // حقل كلمة المرور.
  bool _isLoading = false; // يمنع الضغط المتكرر أثناء الدخول.
  bool _hidePassword = true; // حالة إخفاء كلمة المرور.
  String? _errorMessage; // رسالة الخطأ العربية.

  @override
  void dispose() {
    _emailController.dispose(); // تحرير موارد حقل البريد.
    _passwordController.dispose(); // تحرير موارد كلمة المرور.
    super.dispose(); // إكمال تنظيف State.
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true; // إظهار حالة التحميل.
      _errorMessage = null; // إزالة الخطأ السابق.
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return; // منع استخدام context بعد إغلاق الصفحة.
      setState(() => _errorMessage = _arabicError(error.message));
    } finally {
      if (mounted) setState(() => _isLoading = false); // إنهاء التحميل بأمان.
    }
  }

  String _arabicError(String message) {
    final text = message
        .toLowerCase(); // تحويل رسالة Supabase إلى حروف صغيرة للمقارنة.

    if (text.contains('invalid login')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    if (text.contains('email not confirmed')) {
      return 'يرجى تأكيد البريد الإلكتروني أولًا.';
    }

    if (text.contains('too many')) {
      return 'محاولات كثيرة، حاول بعد قليل.';
    }

    return 'تعذر تسجيل الدخول حاليًا. حاول مرة أخرى.'; // قيمة افتراضية تضمن إرجاع String دائمًا.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _GlassLoginPanel(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                hidePassword: _hidePassword,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onTogglePassword: () =>
                    setState(() => _hidePassword = !_hidePassword),
                onLogin: _signIn,
                onCreateAccount: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// لوحة زجاجية مستقلة حتى تبقى صفحة الدخول قصيرة وقابلة للاختبار.
class _GlassLoginPanel extends StatelessWidget {
  const _GlassLoginPanel({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.hidePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onCreateAccount,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(
      context,
    ).textTheme; // استخدام أحجام الثيم الموحد.

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.wb_sunny_outlined,
            size: 52,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 14),
          Text(
            'شمسنا',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'حلولك الشمسية تبدأ من هنا',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) => value == null || !value.contains('@')
                ? 'أدخل بريدًا إلكترونيًا صحيحًا'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (value) => value == null || value.length < 6
                ? 'كلمة المرور ستة أحرف على الأقل'
                : null,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () {},
              child: const Text('نسيت كلمة المرور؟'),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: isLoading ? null : onLogin,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.login),
            label: Text(isLoading ? 'جارٍ تسجيل الدخول...' : 'تسجيل الدخول'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onCreateAccount,
            child: const Text('إنشاء حساب جديد'),
          ),
        ],
      ),
    );
  }
}

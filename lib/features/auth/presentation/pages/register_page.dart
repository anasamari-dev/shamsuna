import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_background.dart';

/// صفحة إنشاء حساب مستخدم جديد.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // مفتاح التحقق من النموذج.
  final _nameController = TextEditingController(); // حقل اسم المستخدم.
  final _emailController = TextEditingController(); // حقل البريد الإلكتروني.
  final _passwordController = TextEditingController(); // حقل كلمة المرور.
  final _confirmController = TextEditingController(); // حقل تأكيد كلمة المرور.
  bool _isLoading = false; // يمنع تكرار الإرسال.
  bool _hidePassword = true; // حالة إخفاء كلمة المرور.
  bool _hideConfirm = true; // حالة إخفاء التأكيد.
  String? _errorMessage; // رسالة الخطأ العربية.

  @override
  void dispose() {
    _nameController.dispose(); // تحرير مورد حقل الاسم.
    _emailController.dispose(); // تحرير مورد حقل البريد.
    _passwordController.dispose(); // تحرير مورد كلمة المرور.
    _confirmController.dispose(); // تحرير مورد التأكيد.
    super.dispose(); // إكمال تنظيف الصفحة.
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      // فحص الحقول قبل الطلب.
      return;
    }

    setState(() {
      _isLoading = true; // إظهار مؤشر التحميل.
      _errorMessage = null; // مسح الخطأ السابق.
    });

    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'display_name': _nameController.text.trim()},
        emailRedirectTo: 'shamsuna://email-confirmed',
      );

      if (!mounted) return; // منع استخدام الصفحة بعد إغلاقها.
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('تم إنشاء الحساب'),
          content: const Text('تحقق من بريدك الإلكتروني لتفعيل الحساب.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).pop(); // العودة إلى تسجيل الدخول.
    } on AuthException catch (error) {
      if (mounted) setState(() => _errorMessage = _arabicError(error.message));
    } finally {
      if (mounted) setState(() => _isLoading = false); // إيقاف التحميل بأمان.
    }
  }

  String _arabicError(String message) {
    final text = message.toLowerCase(); // تسهيل مطابقة رسالة Supabase.

    if (text.contains('already registered') ||
        text.contains('already exists')) {
      return 'هذا البريد الإلكتروني مسجل مسبقًا.';
    }

    if (text.contains('password')) {
      return 'كلمة المرور لا تستوفي شروط Supabase.';
    }

    return 'تعذر إنشاء الحساب حاليًا. حاول مرة أخرى.'; // رسالة عامة آمنة.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 92, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _RegisterForm(
                formKey: _formKey,
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                hidePassword: _hidePassword,
                hideConfirm: _hideConfirm,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onTogglePassword: () =>
                    setState(() => _hidePassword = !_hidePassword),
                onToggleConfirm: () =>
                    setState(() => _hideConfirm = !_hideConfirm),
                onRegister: _register,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// نموذج مستقل لتقليل حجم الصفحة وتسهيل إعادة الاختبار.
class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.hidePassword,
    required this.hideConfirm,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool hidePassword;
  final bool hideConfirm;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.person_add_alt_1, size: 48, color: Colors.white),
          const SizedBox(height: 14),
          const Text(
            'أنشئ حسابك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'الاسم',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) => value == null || value.trim().length < 2
                ? 'أدخل اسمًا صحيحًا'
                : null,
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          TextFormField(
            controller: confirmController,
            obscureText: hideConfirm,
            decoration: InputDecoration(
              labelText: 'تأكيد كلمة المرور',
              prefixIcon: const Icon(Icons.lock_reset_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  hideConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            validator: (value) => value != passwordController.text
                ? 'كلمتا المرور غير متطابقتين'
                : null,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFF5252)),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: isLoading ? null : onRegister,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add),
            label: Text(isLoading ? 'جارٍ إنشاء الحساب...' : 'إنشاء الحساب'),
          ),
        ],
      ),
    );
  }
}

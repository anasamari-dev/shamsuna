import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';

/// صفحة طلب رابط إعادة تعيين كلمة المرور.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
            _emailController.text.trim(),
            redirectTo: 'shamsuna://reset-password',
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _isError = false;
        _message = 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني.';
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = 'انتهت مهلة الاتصال. تحقق من الإنترنت وحاول مرة أخرى.';
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = _arabicError(error.message);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = 'تعذر الاتصال بخدمة الاستعادة. حاول مرة أخرى.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _arabicError(String message) {
    final text = message.toLowerCase();
    if (text.contains('rate limit') || text.contains('too many')) {
      return 'تم تجاوز عدد المحاولات، حاول بعد قليل.';
    }
    if (text.contains('invalid') || text.contains('email')) {
      return 'تحقق من البريد الإلكتروني وحاول مرة أخرى.';
    }
    return 'تعذر إرسال الرابط حاليًا. حاول مرة أخرى.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: _GlassPanel(
                  formKey: _formKey,
                  emailController: _emailController,
                  isLoading: _isLoading,
                  message: _message,
                  isError: _isError,
                  onSubmit: _sendResetLink,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.message,
    required this.isError,
    required this.onSubmit,
    required this.onBack,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? message;
  final bool isError;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_reset_rounded,
              size: 56,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 14),
            const Text(
              'استعادة كلمة المرور',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل بريدك الإلكتروني وسنرسل لك رابطًا آمنًا لإعادة التعيين.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
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
            if (message != null) ...[
              const SizedBox(height: 14),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isError ? AppColors.error : AppColors.solarBlue,
                ),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: isLoading ? null : onSubmit,
              icon: isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(isLoading ? 'جارٍ الإرسال...' : 'إرسال الرابط'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onBack,
              child: const Text('العودة إلى تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

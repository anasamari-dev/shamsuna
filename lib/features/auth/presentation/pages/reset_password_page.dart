import 'package:flutter/material.dart';
import 'package:shamsuna/features/auth/presentation/pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';

/// صفحة تعيين كلمة مرور جديدة بعد نجاح جلسة الاستعادة.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('تم تحديث كلمة المرور'),
          content: const Text('يمكنك الآن استخدام كلمة المرور الجديدة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('متابعة'),
            ),
          ],
        ),
      );

      await Supabase.instance.client.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذر تحديث كلمة المرور: ${error.message}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                  decoration: BoxDecoration(
                    color: AppColors.panelNavy.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.password_rounded,
                          size: 56,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'تعيين كلمة مرور جديدة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اختر كلمة مرور قوية من ستة أحرف أو أكثر.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور الجديدة',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _hidePassword = !_hidePassword,
                              ),
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'كلمة المرور ستة أحرف على الأقل'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _hideConfirm,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _hideConfirm = !_hideConfirm),
                              icon: Icon(
                                _hideConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value != _passwordController.text
                              ? 'كلمتا المرور غير متطابقتين'
                              : null,
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _updatePassword,
                          icon: _isLoading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isLoading
                                ? 'جارٍ التحديث...'
                                : 'تحديث كلمة المرور',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

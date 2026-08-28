import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/models/current_profile.dart';

/// قائمة الإعدادات الجانبية الخاصة بالصفحة الرئيسية فقط.
/// تستخدم endDrawer حتى تظهر من الجهة اليمنى في واجهة RTL.
class HomeSettingsDrawer extends StatelessWidget {
  const HomeSettingsDrawer({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
  });

  final CurrentProfile profile;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // لا تتجاوز القائمة 60% من عرض الشاشة مهما كان حجم الجهاز.
      width: MediaQuery.sizeOf(context).width * 0.75,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panelNavy.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(28),
            ),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.solarBlue,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          profile.isAdmin ? 'حساب مشرف' : 'حساب مستخدم',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'إغلاق',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.border),
              const SizedBox(height: 8),
              const _SectionTitle(title: 'إعدادات الحساب'),
              _DrawerItem(
                icon: Icons.badge_outlined,
                title: 'تغيير اسم المستخدم',
                subtitle: 'تعديل الاسم الظاهر داخل التطبيق',
                onTap: () => _showNameDialog(context),
              ),
              _DrawerItem(
                icon: Icons.lock_reset_outlined,
                title: 'تغيير كلمة المرور',
                subtitle: 'تعيين كلمة مرور جديدة للحساب الحالي',
                onTap: () => _showPasswordDialog(context),
              ),
              const SizedBox(height: 18),
              const _SectionTitle(title: 'عن التطبيق'),
              _DrawerItem(
                icon: Icons.info_outline_rounded,
                title: 'حول شمسنا',
                subtitle: 'معلومات مختصرة عن التطبيق والإصدار',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showNameDialog(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController(text: profile.displayName);
    final formKey = GlobalKey<FormState>();
    var isSaving = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.panelNavy,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text(
            'تغيير اسم المستخدم',
            style: TextStyle(color: AppColors.textLight),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.length < 2) return 'اكتب اسمًا من حرفين على الأقل';
                if (name.length > 60) return 'الاسم طويل جدًا';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      // نزيل التركيز أولًا، ثم ننتظر دورة واجهة قصيرة قبل إغلاق الحوار.
                      // هذا يمنع تعارض Focus/Inherited dependencies عند ضغط «إلغاء».
                      FocusManager.instance.primaryFocus?.unfocus();
                      await Future<void>.delayed(
                        const Duration(milliseconds: 80),
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);
                      try {
                        final currentUser =
                            Supabase.instance.client.auth.currentUser;
                        if (currentUser == null ||
                            currentUser.id != profile.userId) {
                          throw Exception('لا تملك صلاحية تعديل هذا الحساب');
                        }

                        final updatedRows = await Supabase.instance.client
                            .from('profiles')
                            .update({'display_name': controller.text.trim()})
                            .eq('user_id', currentUser.id)
                            .select('user_id');
                        if (updatedRows.isEmpty) {
                          throw Exception(
                            'لم يتم تحديث الاسم. تحقق من وجود صفك في profiles وسياسة RLS.',
                          );
                        }
                        if (dialogContext.mounted) {
                          // نعيد true فقط؛ تحديث الصفحة يحدث بعد اكتمال إغلاق الحوار.
                          Navigator.of(dialogContext).pop(true);
                        }
                      } catch (error) {
                        setDialogState(() => isSaving = false);
                        messenger.showSnackBar(
                          SnackBar(content: Text('تعذر تحديث الاسم: $error')),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
    // نؤخر التخلص من المتحكم حتى تنتهي حركة إغلاق الحوار بالكامل.
    // التخلص الفوري يسبب خطأ: TextEditingController was used after being disposed.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    controller.dispose();

    if (saved == true && context.mounted) {
      onProfileUpdated();
      messenger.showSnackBar(
        const SnackBar(content: Text('تم تحديث اسم المستخدم')),
      );
    }
  }

  Future<void> _showPasswordDialog(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    var hidePassword = true;
    var hideConfirm = true;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.panelNavy,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Text(
            'تغيير كلمة المرور',
            style: TextStyle(color: AppColors.textLight),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setDialogState(() => hidePassword = !hidePassword),
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value == null || value.length < 6
                      ? 'كلمة المرور ستة أحرف على الأقل'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  obscureText: hideConfirm,
                  decoration: InputDecoration(
                    labelText: 'تأكيد كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setDialogState(() => hideConfirm = !hideConfirm),
                      icon: Icon(
                        hideConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) => value != passwordController.text
                      ? 'كلمتا المرور غير متطابقتين'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      // نزيل التركيز أولًا، ثم ننتظر دورة واجهة قصيرة قبل إغلاق الحوار.
                      // هذا يمنع تعارض Focus/Inherited dependencies عند ضغط «إلغاء».
                      FocusManager.instance.primaryFocus?.unfocus();
                      await Future<void>.delayed(
                        const Duration(milliseconds: 80),
                      );
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);
                      try {
                        final response = await Supabase.instance.client.auth
                            .updateUser(
                              UserAttributes(password: passwordController.text),
                            );
                        if (response.user == null) {
                          throw Exception('لم يؤكد Supabase تحديث كلمة المرور');
                        }
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('تم تغيير كلمة المرور بنجاح'),
                          ),
                        );
                      } on AuthException catch (error) {
                        setDialogState(() => isSaving = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'تعذر تغيير كلمة المرور: ${error.message}',
                            ),
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تحديث'),
            ),
          ],
        ),
      ),
    );
    // ننتظر انتهاء حركة الإغلاق قبل التخلص من الحقول.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    passwordController.dispose();
    confirmController.dispose();
  }

  Future<void> _showAboutDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panelNavy,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.solar_power_outlined),
            SizedBox(width: 10),
            Text('حول شمسنا', style: TextStyle(color: AppColors.textLight)),
          ],
        ),
        content: const Text(
          'شمسنا تطبيق مساعد لتصميم المنظومات الشمسية، وإدارة الأحمال والتقارير، وعرض النتائج بطريقة مبسطة للمستخدم.\n\nالإصدار: 1.0.0\n\nتم تطويره لخدمة احتياجات الطاقة الشمسية المحلية.',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColors.textMuted,
            height: 1.7,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.solarBlue,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      leading: Icon(icon, color: AppColors.textLight),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textLight,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

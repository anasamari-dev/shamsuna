import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import 'admin_suggestions_page.dart';
import 'admin_catalog_page.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

/// لوحة مستقلة للمشرف، وستربط لاحقًا بإدارة الاقتراحات والكتالوج.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: const Text('لوحة المشرف'),
                centerTitle: true,
                actions: const [NotificationBell(isAdmin: true)],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _AdminBanner(),
                      const SizedBox(height: 18),
                      _AdminAction(
                        icon: Icons.devices_other_rounded,
                        title: 'اقتراحات الأجهزة',
                        subtitle: 'مراجعة الاقتراحات وقبولها أو رفضها',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminSuggestionsPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AdminAction(
                        icon: Icons.inventory_2_outlined,
                        title: 'إدارة الكتالوج',
                        subtitle: 'إدارة الفئات والشركات والأجهزة',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminCatalogPage(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AdminAction(
                        icon: Icons.assessment_outlined,
                        title: 'جميع التقارير',
                        subtitle: 'عرض تقارير المستخدمين للمراجعة',
                        onTap: () => _comingSoon(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم ربط هذه الأداة في الخطوة التالية')),
    );
  }
}

class _AdminBanner extends StatelessWidget {
  const _AdminBanner();

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Row(
        children: [
          const Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.textLight,
            size: 46,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'وضع المشرف',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'هذه الأدوات متاحة للحسابات الـ Admin',
                  style: TextStyle(color: AppColors.textMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({
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
    return _GlassBox(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.textLight, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textMuted,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _GlassBox extends StatelessWidget {
  const _GlassBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

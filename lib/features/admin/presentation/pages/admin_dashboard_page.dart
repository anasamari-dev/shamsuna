import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/shamsuna_bottom_bar.dart';
import '../../../calculation/presentation/pages/report_devices_page.dart';
import '../../../calculation/presentation/pages/report_setup_page.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../reports/presentation/pages/compare_reports_page.dart';
import '../../../reports/presentation/pages/my_reports_page.dart';
import '../../../suggestions/presentation/pages/suggest_device_page.dart';
import 'admin_catalog_page.dart';
import 'admin_reports_page.dart';
import 'admin_suggestions_page.dart';

/// لوحة مستقلة للمشرف مع شريط التنقل السفلي المشترك.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  void _openCreateReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportSetupPage(
          onContinue: (draft) => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReportDevicesPage(draft: draft)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              CustomScrollView(
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
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 128),
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
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AdminReportsPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 10,
                child: ShamsunaBottomBar(
                  currentIndex: 2,
                  onCreateReport: () => _openCreateReport(context),
                  onMyReports: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyReportsPage()),
                  ),
                  onHome: () => Navigator.of(context).pop(),
                  onCompare: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CompareReportsPage(),
                    ),
                  ),
                  onSuggestDevice: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SuggestDevicePage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminBanner extends StatelessWidget {
  const _AdminBanner();

  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.textLight,
            size: 46,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

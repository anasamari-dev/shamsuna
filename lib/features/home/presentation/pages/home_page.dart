import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
<<<<<<< HEAD
import '../../../../core/widgets/shamsuna_bottom_bar.dart';

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../auth/data/models/current_profile.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../../calculation/presentation/pages/report_devices_page.dart';
import '../../../calculation/presentation/pages/report_setup_page.dart';
import '../../../reports/presentation/pages/compare_reports_page.dart';
import '../../../reports/presentation/pages/my_reports_page.dart';
import '../../../suggestions/presentation/pages/suggest_device_page.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
<<<<<<< HEAD
import '../widgets/home_settings_drawer.dart';

/// لوحة المستخدم الرئيسية مع تمييز واجهة المشرف حسب role.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.showBottomBar = true,
    this.onTabSelected,
  });

  final bool showBottomBar;
  final ValueChanged<int>? onTabSelected;
=======

/// لوحة المستخدم الرئيسية مع تمييز واجهة المشرف حسب role.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileRepository _profiles = ProfileRepository();
  late Future<CurrentProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profiles.fetchCurrentProfile();
  }

  Future<void> _signOut() => Supabase.instance.client.auth.signOut();

<<<<<<< HEAD
  void _refreshProfile() {
    if (!mounted) return;
    setState(() {
      _profileFuture = _profiles.fetchCurrentProfile();
    });
  }

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
<<<<<<< HEAD
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: FutureBuilder<CurrentProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.textLight),
              );
            }

            if (snapshot.hasError) {
              return _HomeError(
                message: '${snapshot.error}',
                onRetry: () {
                  setState(() {
                    _profileFuture = _profiles.fetchCurrentProfile();
                  });
                },
              );
            }

            final profile = snapshot.data;
            if (profile == null) {
              return const _HomeError(message: 'تعذر تحميل بيانات المستخدم');
            }

            return _HomeContent(
              profile: profile,
              onSignOut: _signOut,
              onProfileUpdated: _refreshProfile,
              showBottomBar: widget.showBottomBar,
              onTabSelected: widget.onTabSelected,
            );
          },
=======
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<CurrentProfile>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.textLight),
                );
              }
              if (snapshot.hasError) {
                return _HomeError(
                  message: '${snapshot.error}',
                  onRetry: () => setState(
                    () => _profileFuture = _profiles.fetchCurrentProfile(),
                  ),
                );
              }
              final profile = snapshot.data;
              if (profile == null) {
                return const _HomeError(message: 'تعذر تحميل بيانات المستخدم');
              }
              return _HomeContent(profile: profile, onSignOut: _signOut);
            },
          ),
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
<<<<<<< HEAD
  const _HomeContent({
    required this.profile,
    required this.onSignOut,
    required this.onProfileUpdated,
    required this.showBottomBar,
    this.onTabSelected,
  });

  final CurrentProfile profile;
  final VoidCallback onSignOut;
  final VoidCallback onProfileUpdated;
  final bool showBottomBar;
  final ValueChanged<int>? onTabSelected;

  void _selectTab(BuildContext context, int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    onTabSelected?.call(index);
  }

  void _openCreateReport(BuildContext context) {
    if (onTabSelected != null) {
      _selectTab(context, 0);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportSetupPage(
          onContinue: (draft) => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportDevicesPage(draft: draft),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      // drawer يستخدم جهة البداية، وهي يمين المستخدم عند تفعيل RTL.
      drawer: HomeSettingsDrawer(
        profile: profile,
        onProfileUpdated: onProfileUpdated,
      ),
      bottomNavigationBar: showBottomBar
          ? Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: ShamsunaBottomBar(
                currentIndex: 2,
                onCreateReport: () => _openCreateReport(context),
                onMyReports: () => onTabSelected != null
                    ? _selectTab(context, 1)
                    : Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MyReportsPage(),
                        ),
                      ),
                onHome: () => _selectTab(context, 2),
                onCompare: () => onTabSelected != null
                    ? _selectTab(context, 3)
                    : Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CompareReportsPage(),
                        ),
                      ),
                onSuggestDevice: () => onTabSelected != null
                    ? _selectTab(context, 4)
                    : Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SuggestDevicePage(),
                        ),
                      ),
              ),
            )
          : null,
      body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              title: const Text('شمسنا'),
              actions: [
                NotificationBell(isAdmin: profile.isAdmin),
                if (profile.isAdmin)
                  IconButton(
                    tooltip: 'لوحة المشرف',
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardPage(),
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: 'تسجيل الخروج',
                  onPressed: onSignOut,
                  icon: const Icon(Icons.logout_rounded),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 132),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'مرحبًا بك في شمسنا',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مرحبًا ${profile.displayName}، ابدأ بتصميم منظومتك الشمسية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (profile.isAdmin) const _AdminModeChip(),
                    if (profile.isAdmin) const SizedBox(height: 24),
                    const Text(
                      'ماذا تريد أن تفعل؟',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DashboardGrid(
                      onCreateReport: () => _openCreateReport(context),
                      onArchive: () => onTabSelected != null
                          ? _selectTab(context, 1)
                          : Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const MyReportsPage(),
                              ),
                            ),
                      onCompare: () => onTabSelected != null
                          ? _selectTab(context, 3)
                          : Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CompareReportsPage(),
                              ),
                            ),
                      onSuggestDevice: () => onTabSelected != null
                          ? _selectTab(context, 4)
                          : Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SuggestDevicePage(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
=======
  const _HomeContent({required this.profile, required this.onSignOut});

  final CurrentProfile profile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: const Text('شمسنا'),
          actions: [
            NotificationBell(isAdmin: profile.isAdmin),
            if (profile.isAdmin)
              IconButton(
                tooltip: 'لوحة المشرف',
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
                ),
              ),
            IconButton(
              tooltip: 'تسجيل الخروج',
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 32),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'مرحبًا بك في شمسنا',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'مرحبًا ${profile.displayName}، ابدأ بتصميم منظومتك الشمسية',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                if (profile.isAdmin) const _AdminModeChip(),
                if (profile.isAdmin) const SizedBox(height: 24),
                const Text(
                  'ماذا تريد أن تفعل؟',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 14),
                _DashboardGrid(
                  onCreateReport: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ReportSetupPage(
                        onContinue: (draft) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReportDevicesPage(draft: draft),
                          ),
                        ),
                      ),
                    ),
                  ),
                  onArchive: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyReportsPage()),
                  ),
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
              ],
            ),
          ),
        ),
      ],
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
    );
  }
}

class _AdminModeChip extends StatelessWidget {
  const _AdminModeChip();

  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.textLight),
          SizedBox(width: 10),
          Text(
            'تم تسجيل الدخول بوضع المشرف',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid({
    required this.onCreateReport,
    required this.onArchive,
    required this.onCompare,
    required this.onSuggestDevice,
  });

  final VoidCallback onCreateReport;
  final VoidCallback onArchive;
  final VoidCallback onCompare;
  final VoidCallback onSuggestDevice;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.95,
      children: [
        _DashboardCard(
          icon: Icons.add_chart_rounded,
          title: 'إنشاء تقرير',
          subtitle: 'احسب احتياج منزلك',
          onTap: onCreateReport,
        ),
        _DashboardCard(
          icon: Icons.folder_copy_outlined,
          title: 'تقاريري',
          subtitle: 'اعرض تقاريرك السابقة',
          onTap: onArchive,
        ),
        _DashboardCard(
          icon: Icons.compare_arrows_rounded,
          title: 'مقارنة',
          subtitle: 'قارن بين تقريرين',
          onTap: onCompare,
        ),
        _DashboardCard(
          icon: Icons.devices_other_rounded,
          title: 'اقتراح جهاز',
          subtitle: 'أرسل جهازًا للمراجعة',
          onTap: onSuggestDevice,
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
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
    return Card(
      color: AppColors.panelNavy.withValues(alpha: 0.72),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34, color: AppColors.textLight),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _GlassBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.textLight,
                size: 44,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

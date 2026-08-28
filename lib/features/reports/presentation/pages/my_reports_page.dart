import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/shamsuna_bottom_bar.dart';

import '../../../calculation/presentation/pages/calculation_result_page.dart';
import '../../../calculation/presentation/pages/report_devices_page.dart';
import '../../../calculation/presentation/pages/report_setup_page.dart';
import '../../../suggestions/presentation/pages/suggest_device_page.dart';

import '../../data/models/user_report.dart';
import 'edit_report_page.dart';
import '../../data/repositories/reports_repository.dart';
import 'compare_reports_page.dart';

/// صفحة التقارير المحفوظة للمستخدم الحالي.
class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key, this.showBottomBar = true});

  final bool showBottomBar;

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final ReportsRepository _repository = ReportsRepository();
  late Future<List<UserReport>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reportsFuture = _repository.fetchMyReports();
  }

  void _openCreateReport() {
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
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: widget.showBottomBar
          ? Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: ShamsunaBottomBar(
                currentIndex: 1,
                onCreateReport: _openCreateReport,
                onMyReports: () {},
                onHome: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                onCompare: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CompareReportsPage()),
                ),
                onSuggestDevice: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SuggestDevicePage()),
                ),
              ),
            )
          : null,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                title: const Text('تقاريري'),
                centerTitle: true,
                actions: [
                  IconButton(
                    tooltip: 'مقارنة التقارير',
                    icon: const Icon(Icons.compare_arrows_rounded),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CompareReportsPage(),
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: _ReportsIntro(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                sliver: FutureBuilder<List<UserReport>>(
                  future: _reportsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.textLight,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ReportsMessage(
                          icon: Icons.cloud_off_rounded,
                          title: 'تعذر تحميل التقارير',
                          message: snapshot.error.toString(),
                          actionLabel: 'إعادة المحاولة',
                          onAction: () => setState(_loadReports),
                        ),
                      );
                    }

                    final reports = snapshot.data ?? const <UserReport>[];
                    if (reports.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ReportsMessage(
                          icon: Icons.folder_open_rounded,
                          title: 'لا توجد تقارير بعد',
                          message: 'أنشئ تقريرك الأول لتظهر نتائجه هنا.',
                        ),
                      );
                    }

                    return SliverList.separated(
                      itemCount: reports.length,
                      itemBuilder: (_, index) => _ReportCard(
                        report: reports[index],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CalculationResultPage(
                              reportId: reports[index].id,
                            ),
                          ),
                        ),
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EditReportPage(reportId: reports[index].id),
                          ),
                        ),
                      ),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsIntro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Row(
        children: [
          Icon(
            Icons.folder_copy_outlined,
            color: AppColors.textLight,
            size: 38,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'استعرض حساباتك السابقة وافتح نتيجة أي تقرير في أي وقت.',
              style: TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.onTap,
    required this.onEdit,
  });

  final UserReport report;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  String _date() {
    final local = report.createdAt.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  String _status() {
    switch (report.status.toLowerCase()) {
      case 'completed':
      case 'calculated':
      case 'active':
        return 'مكتمل';
      case 'draft':
        return 'مسودة';
      case 'archived':
        return 'مؤرشف';
      default:
        return report.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'فتح التقرير ${report.title}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: _GlassBox(
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.panelNavy.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'تقرير رقم ${report.id}  •  ${_date()}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  _StatusBadge(label: _status()),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: onEdit,
                        tooltip: 'تعديل التقرير',
                        icon: const Icon(Icons.edit_outlined),
                        color: AppColors.textLight,
                        iconSize: 18,
                      ),
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textMuted,
                        size: 15,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.border.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 11),
        ),
      ),
    );
  }
}

class _ReportsMessage extends StatelessWidget {
  const _ReportsMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _GlassBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.textLight, size: 52),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
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

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/repositories/admin_reports_repository.dart';

/// صفحة المشرف لعرض تقارير جميع المستخدمين.
class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final _repository = AdminReportsRepository();
  final _searchController = TextEditingController();
  late Future<List<AdminReportSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchAll();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _reload() async {
    final future = _repository.fetchAll();
    if (!mounted) return;
    setState(() {
      _future = future;
    });
    await future;
  }

  List<AdminReportSummary> _filter(List<AdminReportSummary> reports) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return reports;
    return reports
        .where(
          (report) =>
              report.title.toLowerCase().contains(query) ||
              report.displayName.toLowerCase().contains(query) ||
              '${report.reportId}'.contains(query),
        )
        .toList(growable: false);
  }

  Future<void> _showDetails(AdminReportSummary report) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ReportDetailsSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _reload,
            color: AppColors.solarBlue,
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
                  centerTitle: true,
                  title: const Text('جميع التقارير'),
                  actions: [
                    IconButton(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'تحديث التقارير',
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  sliver: SliverToBoxAdapter(
                    child: _GlassSearchField(controller: _searchController),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: FutureBuilder<List<AdminReportSummary>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 80),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: _Message(
                            text: 'تعذر تحميل التقارير: ${snapshot.error}',
                            onRetry: _reload,
                          ),
                        );
                      }

                      final reports = _filter(snapshot.data ?? const []);
                      if (reports.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: _Message(text: 'لا توجد تقارير مطابقة حاليًا'),
                        );
                      }

                      return SliverList.separated(
                        itemCount: reports.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return _AdminReportCard(
                            report: report,
                            onTap: () => _showDetails(report),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSearchField extends StatelessWidget {
  const _GlassSearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textLight),
      decoration: InputDecoration(
        labelText: 'بحث في التقارير',
        hintText: 'اسم التقرير أو المستخدم أو رقم التقرير',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.clear_rounded),
              ),
      ),
    );
  }
}

class _AdminReportCard extends StatelessWidget {
  const _AdminReportCard({required this.report, required this.onTap});

  final AdminReportSummary report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.panelNavy.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assessment_outlined,
                size: 38,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 12),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'المستخدم: ${report.displayName}',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'التقرير #${report.reportId}  •  ${_date(report.createdAt)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                report.hasResult
                    ? Icons.check_circle_outline_rounded
                    : Icons.hourglass_empty_rounded,
                color: report.hasResult
                    ? AppColors.solarBlue
                    : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _date(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }
}

class _ReportDetailsSheet extends StatelessWidget {
  const _ReportDetailsSheet({required this.report});

  final AdminReportSummary report;

  @override
  Widget build(BuildContext context) {
    final result = report.result;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.panelNavy.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                report.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _DetailLine(label: 'المستخدم', value: report.displayName),
              _DetailLine(label: 'رقم التقرير', value: '${report.reportId}'),
              _DetailLine(label: 'الحالة', value: _status(report.status)),
              _DetailLine(
                label: 'تاريخ الإنشاء',
                value: _formatDate(report.createdAt),
              ),
              const Divider(color: AppColors.border, height: 28),
              if (result == null)
                const Text(
                  'لم تكتمل نتيجة الحساب لهذا التقرير.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                )
              else ...[
                const Text(
                  'نتيجة الحساب',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _DetailLine(
                  label: 'إجمالي الطاقة',
                  value: '${_number(result['total_energy_wh'])} واط⋅ساعة',
                ),
                _DetailLine(
                  label: 'الحمل الأقصى',
                  value: '${_number(result['peak_load_w'])} واط',
                ),
                _DetailLine(
                  label: 'الألواح المقترحة',
                  value: '${_number(result['recommended_panel_wp'])} واط',
                ),
                _DetailLine(
                  label: 'البطارية المقترحة',
                  value:
                      '${result['battery_display'] ?? _number(result['recommended_battery_ah'])}',
                ),
                _DetailLine(
                  label: 'العاكس المقترح',
                  value: '${_number(result['recommended_inverter_w'])} واط',
                ),
                _DetailLine(
                  label: 'منظم الشحن',
                  value:
                      '${_number(result['recommended_charge_controller_a'])} أمبير ${result['charge_controller_type'] ?? ''}',
                ),
              ],
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _status(String value) {
    switch (value) {
      case 'completed':
        return 'مكتمل';
      case 'archived':
        return 'مؤرشف';
      default:
        return value;
    }
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day}/${local.month}/${local.year}';
  }

  static String _number(dynamic value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null) return 'غير متوفر';
    return number == number.truncateToDouble()
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    );
  }
}

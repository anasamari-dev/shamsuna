import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/user_report.dart';
import '../../data/repositories/comparison_repository.dart';
import 'report_comparison_result_page.dart';

/// صفحة اختيار تقريرين محفوظين للمقارنة.
class CompareReportsPage extends StatefulWidget {
  const CompareReportsPage({super.key});

  @override
  State<CompareReportsPage> createState() => _CompareReportsPageState();
}

class _CompareReportsPageState extends State<CompareReportsPage> {
  final ComparisonRepository _repository = ComparisonRepository();
  late Future<List<UserReport>> _reportsFuture;
  UserReport? _first;
  UserReport? _second;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _repository.fetchSelectableReports();
  }

  Future<void> _compare() async {
    final first = _first;
    final second = _second;
    if (first == null || second == null || first.id == second.id) return;

    setState(() => _loading = true);
    try {
      final data = await _repository.fetchComparison(first, second);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportComparisonResultPage(data: data),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر إعداد المقارنة: $error')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<List<UserReport>>(
            future: _reportsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.textLight),
                );
              }
              if (snapshot.hasError) {
                return _Message(
                  title: 'تعذر تحميل التقارير',
                  message: '${snapshot.error}',
                  onRetry: () => setState(
                    () => _reportsFuture = _repository.fetchSelectableReports(),
                  ),
                );
              }

              final reports = snapshot.data ?? const <UserReport>[];
              if (reports.length < 2) {
                return const _Message(
                  title: 'تحتاج إلى تقريرين على الأقل',
                  message: 'أنشئ تقريرين مكتملين أولًا حتى تتمكن من المقارنة.',
                );
              }

              return _SelectionContent(
                reports: reports,
                first: _first,
                second: _second,
                loading: _loading,
                onFirstChanged: (value) => setState(() => _first = value),
                onSecondChanged: (value) => setState(() => _second = value),
                onCompare: _compare,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelectionContent extends StatelessWidget {
  const _SelectionContent({
    required this.reports,
    required this.first,
    required this.second,
    required this.loading,
    required this.onFirstChanged,
    required this.onSecondChanged,
    required this.onCompare,
  });

  final List<UserReport> reports;
  final UserReport? first;
  final UserReport? second;
  final bool loading;
  final ValueChanged<UserReport?> onFirstChanged;
  final ValueChanged<UserReport?> onSecondChanged;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final canCompare =
        first != null && second != null && first!.id != second!.id;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          title: Text('مقارنة التقارير'),
          centerTitle: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _IntroBox(),
                const SizedBox(height: 20),
                _ReportDropdown(
                  label: 'التقرير الأول',
                  value: first,
                  reports: reports,
                  onChanged: onFirstChanged,
                ),
                const SizedBox(height: 14),
                _ReportDropdown(
                  label: 'التقرير الثاني',
                  value: second,
                  reports: reports,
                  onChanged: onSecondChanged,
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: canCompare && !loading ? onCompare : null,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compare_arrows_rounded),
                  label: Text(
                    loading ? 'جارٍ إعداد المقارنة...' : 'عرض المقارنة',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportDropdown extends StatelessWidget {
  const _ReportDropdown({
    required this.label,
    required this.value,
    required this.reports,
    required this.onChanged,
  });

  final String label;
  final UserReport? value;
  final List<UserReport> reports;
  final ValueChanged<UserReport?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: DropdownButtonFormField<UserReport>(
        initialValue: value,
        isExpanded: true,
        dropdownColor: AppColors.panelNavy,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        items: reports
            .map(
              (report) => DropdownMenuItem<UserReport>(
                value: report,
                child: Text(report.title, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    );
  }
}

class _IntroBox extends StatelessWidget {
  const _IntroBox();

  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Row(
        children: [
          Icon(Icons.compare_rounded, color: AppColors.textLight, size: 42),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'اختر تقريرين مكتملين لمقارنة الأحمال والطاقة ومكونات المنظومة.',
              style: TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.message, this.onRetry});

  final String title;
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
                Icons.compare_rounded,
                color: AppColors.textLight,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
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

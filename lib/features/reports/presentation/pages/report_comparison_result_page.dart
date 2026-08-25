import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/report_comparison.dart';

/// تعرض نتيجة مقارنة تقريرين محفوظين.
class ReportComparisonResultPage extends StatelessWidget {
  const ReportComparisonResultPage({super.key, required this.data});

  final List<ReportComparison> data;

  @override
  Widget build(BuildContext context) {
    final first = data[0];
    final second = data[1];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ReportNames(first: first, second: second),
                      const SizedBox(height: 16),
                      _ComparisonSection(
                        title: 'الأحمال والطاقة',
                        metrics: [
                          _metric(
                            'القدرة القصوى',
                            'peak_load_w',
                            'واط',
                            first,
                            second,
                          ),
                          _metric(
                            'الطاقة النهارية',
                            'day_energy_wh',
                            'واط ساعة',
                            first,
                            second,
                          ),
                          _metric(
                            'الطاقة الليلية',
                            'night_energy_wh',
                            'واط ساعة',
                            first,
                            second,
                          ),
                          _metric(
                            'الطاقة اليومية',
                            'total_energy_wh',
                            'واط ساعة',
                            first,
                            second,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ComparisonSection(
                        title: 'مكونات المنظومة',
                        metrics: [
                          _metric(
                            'الألواح الشمسية',
                            'recommended_panel_wp',
                            'واط',
                            first,
                            second,
                          ),
                          _metric(
                            'البطارية',
                            'recommended_battery_ah',
                            'أمبير ساعة',
                            first,
                            second,
                          ),
                          _metric(
                            'العاكس',
                            'recommended_inverter_w',
                            'واط',
                            first,
                            second,
                          ),
                          _metric(
                            'منظم الشحن',
                            'recommended_charge_controller_a',
                            'أمبير',
                            first,
                            second,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _TextComparison(
                        title: 'تفاصيل البطارية',
                        firstValue:
                            '${first.result['battery_display'] ?? 'غير محدد'}',
                        secondValue:
                            '${second.result['battery_display'] ?? 'غير محدد'}',
                        firstTitle: first.report.title,
                        secondTitle: second.report.title,
                      ),
                      const SizedBox(height: 16),
                      _TextComparison(
                        title: 'تشكيلة الألواح',
                        firstValue: _panelText(first.result),
                        secondValue: _panelText(second.result),
                        firstTitle: first.report.title,
                        secondTitle: second.report.title,
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

  ComparisonMetric _metric(
    String title,
    String key,
    String unit,
    ReportComparison first,
    ReportComparison second,
  ) {
    return ComparisonMetric(
      title: title,
      firstValue: _number(first.result[key]),
      secondValue: _number(second.result[key]),
      unit: unit,
    );
  }

  String _number(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    return number == number.truncateToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  String _panelText(Map<String, dynamic> result) {
    final raw = result['panel_configuration'];
    if (raw is! List || raw.isEmpty) {
      return '${_number(result['recommended_panel_wp'])} واط';
    }
    return raw
        .map((item) {
          final row = Map<String, dynamic>.from(item as Map);
          return '${_number(row['quantity'])} × ${_number(row['wattage_wp'])} واط';
        })
        .join('، ');
  }
}

class _ReportNames extends StatelessWidget {
  const _ReportNames({required this.first, required this.second});

  final ReportComparison first;
  final ReportComparison second;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Row(
        children: [
          Expanded(
            child: _NameColumn(
              label: 'التقرير الأول',
              title: first.report.title,
            ),
          ),
          Container(width: 1, height: 48, color: AppColors.border),
          Expanded(
            child: _NameColumn(
              label: 'التقرير الثاني',
              title: second.report.title,
            ),
          ),
        ],
      ),
    );
  }
}

class _NameColumn extends StatelessWidget {
  const _NameColumn({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({required this.title, required this.metrics});

  final String title;
  final List<ComparisonMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...metrics.map((metric) => _MetricRow(metric: metric)),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});

  final ComparisonMetric metric;

  @override
  Widget build(BuildContext context) {
    final same = metric.firstValue == metric.secondValue;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Value(
              value: metric.firstValue,
              unit: metric.unit,
              emphasized: !same,
            ),
          ),
          SizedBox(
            width: 86,
            child: Text(
              metric.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: _Value(
              value: metric.secondValue,
              unit: metric.unit,
              emphasized: !same,
            ),
          ),
        ],
      ),
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({
    required this.value,
    required this.unit,
    required this.emphasized,
  });

  final String value;
  final String unit;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        if (unit.isNotEmpty)
          Text(
            unit,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
      ],
    );
  }
}

class _TextComparison extends StatelessWidget {
  const _TextComparison({
    required this.title,
    required this.firstValue,
    required this.secondValue,
    required this.firstTitle,
    required this.secondTitle,
  });

  final String title;
  final String firstValue;
  final String secondValue;
  final String firstTitle;
  final String secondTitle;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TextValue(title: firstTitle, value: firstValue),
              ),
              Expanded(
                child: _TextValue(title: secondTitle, value: secondValue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextValue extends StatelessWidget {
  const _TextValue({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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

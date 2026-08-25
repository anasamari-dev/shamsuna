import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/services/report_export_service.dart';

/// صفحة عرض نتيجة الحساب المحفوظة في Supabase.
class CalculationResultPage extends StatefulWidget {
  const CalculationResultPage({super.key, required this.reportId});

  final int reportId;

  @override
  State<CalculationResultPage> createState() => _CalculationResultPageState();
}

class _CalculationResultPageState extends State<CalculationResultPage> {
  final ReportRepository _repository = ReportRepository();
  late Future<Map<String, dynamic>> _resultFuture;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  void _loadResult() {
    _resultFuture = _repository.fetchResult(reportId: widget.reportId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _resultFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.textLight),
                );
              }

              if (snapshot.hasError) {
                return _ResultError(
                  message: snapshot.error.toString(),
                  onRetry: () => setState(_loadResult),
                );
              }

              final result = snapshot.data;
              if (result == null) {
                return const _ResultError(message: 'لم يتم العثور على النتيجة');
              }

              return _ResultContent(reportId: widget.reportId, result: result);
            },
          ),
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.reportId, required this.result});

  final int reportId;
  final Map<String, dynamic> result;

  double _number(String key) {
    final value = result[key];
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  String _value(String key) => formatResultNumber(_number(key));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExportMenu(context, reportId, result),
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text('تصدير'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: const Text('نتيجة الحساب'),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 16),
                child: Center(
                  child: Text(
                    'تقرير $reportId',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _ResultHero(),
                  const SizedBox(height: 18),
                  _ResultSection(
                    title: 'الأحمال والطاقة',
                    children: [
                      _ResultTile(
                        icon: Icons.bolt_rounded,
                        title: 'القدرة القصوى',
                        value: '${_value('peak_load_w')} واط',
                      ),
                      _ResultTile(
                        icon: Icons.wb_sunny_outlined,
                        title: 'الطاقة النهارية',
                        value: '${_value('day_energy_wh')} واط⋅ساعة',
                      ),
                      _ResultTile(
                        icon: Icons.nightlight_outlined,
                        title: 'الطاقة الليلية',
                        value: '${_value('night_energy_wh')} واط⋅ساعة',
                      ),
                      _ResultTile(
                        icon: Icons.energy_savings_leaf_outlined,
                        title: 'الطاقة اليومية',
                        value: '${_value('total_energy_wh')} واط⋅ساعة',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ResultSection(
                    title: 'مكونات المنظومة المقترحة',
                    children: [
                      _PanelResultTile(result: result),
                      _ResultTile(
                        icon: Icons.battery_full_rounded,
                        title: 'البطارية',
                        value:
                            '${result['battery_display'] ?? '${_value('recommended_battery_ah')} أمبير⋅ساعة'}',
                      ),
                      _ResultTile(
                        icon: Icons.electrical_services_rounded,
                        title: 'العاكس',
                        value: '${_value('recommended_inverter_w')} واط',
                      ),
                      _ResultTile(
                        icon: Icons.power_rounded,
                        title: 'منظم الشحن',
                        value:
                            '${result['charge_controller_type'] ?? 'MPPT'} ${_value('recommended_charge_controller_a')} أمبير',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _EngineInfo(
                    version: '${result['engine_version'] ?? 'غير محدد'}',
                    calculatedAt: '${result['calculated_at'] ?? 'غير محدد'}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showExportMenu(
  BuildContext context,
  int reportId,
  Map<String, dynamic> result,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.panelNavy,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'اختر صيغة التصدير',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.textLight,
            ),
            title: const Text(
              'تصدير PDF',
              style: TextStyle(color: AppColors.textLight),
            ),
            subtitle: const Text(
              'تقرير عربي منسق للطباعة والمشاركة',
              style: TextStyle(color: AppColors.textMuted),
            ),
            onTap: () async {
              Navigator.pop(sheetContext);
              await _exportPdf(context, reportId, result);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.table_view_outlined,
              color: AppColors.textLight,
            ),
            title: const Text(
              'تصدير Excel',
              style: TextStyle(color: AppColors.textLight),
            ),
            subtitle: const Text(
              'بيانات قابلة للتحرير والتحليل',
              style: TextStyle(color: AppColors.textMuted),
            ),
            onTap: () async {
              Navigator.pop(sheetContext);
              await _exportExcel(context, reportId, result);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Future<void> _exportPdf(
  BuildContext context,
  int reportId,
  Map<String, dynamic> result,
) async {
  final messenger = _showExportLoading(context, 'جارٍ إنشاء ملف PDF...');
  try {
    await ReportExportService().exportPdf(reportId: reportId, result: result);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إنشاء ملف PDF: $error')));
    }
  } finally {
    messenger.close();
  }
}

Future<void> _exportExcel(
  BuildContext context,
  int reportId,
  Map<String, dynamic> result,
) async {
  final messenger = _showExportLoading(context, 'جارٍ إنشاء ملف Excel...');
  try {
    await ReportExportService().exportExcel(reportId: reportId, result: result);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إنشاء ملف Excel: $error')));
    }
  } finally {
    messenger.close();
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showExportLoading(
  BuildContext context,
  String message,
) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  scaffoldMessenger.hideCurrentSnackBar();
  return scaffoldMessenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: const Duration(minutes: 2),
      content: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(width: 12),
          Text(message),
        ],
      ),
    ),
  );
}

class _PanelResultTile extends StatelessWidget {
  const _PanelResultTile({required this.result});

  final Map<String, dynamic> result;

  String _format(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    return formatResultNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    final rawConfiguration = result['panel_configuration'];
    final configuration = rawConfiguration is List
        ? rawConfiguration
        : const [];
    final total = _format(result['recommended_panel_wp']);

    final description = configuration
        .map((item) {
          final row = Map<String, dynamic>.from(item as Map);
          return '${_format(row['quantity'])} × ${_format(row['wattage_wp'])} واط';
        })
        .join('\n');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.solar_power_rounded,
            color: AppColors.textLight,
            size: 28,
          ),
          const SizedBox(height: 7),
          const Text(
            'الألواح الشمسية',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            description.isEmpty ? '$total واط' : description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'الإجمالي: $total واط',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero();

  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.textLight,
            size: 58,
          ),
          SizedBox(height: 10),
          Text(
            'تم حساب منظومتك بنجاح',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'النتائج تقديرية وفق بيانات الأحمال والافتراضات المعتمدة',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.sizeOf(context).width >= 600 ? 4 : 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: children,
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textLight, size: 28),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 4),
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

class _EngineInfo extends StatelessWidget {
  const _EngineInfo({required this.version, required this.calculatedAt});

  final String version;
  final String calculatedAt;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات الحساب',
            style: TextStyle(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'إصدار المحرك: $version',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            'وقت الحساب: $calculatedAt',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ResultError extends StatelessWidget {
  const _ResultError({required this.message, this.onRetry});

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
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textLight),
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

String formatResultNumber(num value) {
  final number = value.toDouble();
  return number == number.truncateToDouble()
      ? number.toInt().toString()
      : number.toString();
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../models/report_device_detail_draft.dart';
import '../models/report_draft.dart';
import 'device_selection_page.dart';
import 'report_load_entry_page.dart';
import '../../data/repositories/report_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'calculation_result_page.dart';

/// يعرض الرقم دون .0 إذا كان عددًا صحيحًا، ويحافظ على الكسور المهمة.
String formatUserNumber(num value) {
  final number = value.toDouble();

  return number == number.truncateToDouble()
      ? number.toInt().toString()
      : number.toString();
}

/// يدير قائمة الأجهزة المختارة قبل الحفظ النهائي للتقرير.
class ReportDevicesPage extends StatefulWidget {
  const ReportDevicesPage({
    super.key,
    required this.draft,
    this.showBottomBar = true,
  });

  final bool showBottomBar;

  final ReportDraft draft;

  @override
  State<ReportDevicesPage> createState() => _ReportDevicesPageState();
}

class _ReportDevicesPageState extends State<ReportDevicesPage> {
  final List<ReportDeviceDetailDraft> _details = [];
  final ReportRepository _reportRepository = ReportRepository();
  bool _isSaving = false;

  Future<void> _editDevice(int index) async {
    final current = _details[index];

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportLoadEntryPage(
          draft: widget.draft,
          device: current.device,
          initialDetail: current,
          onSaved: (updatedDetail) {
            setState(() {
              _details[index] = updatedDetail;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _chooseDevice() async {
    // نستخدم مفتاحًا للتحكم في صفحة الاختيار وإعادتها إلى الفئات بعد الحفظ.
    final selectionKey = GlobalKey<DeviceSelectionPageState>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceSelectionPage(
          key: selectionKey,
          draft: widget.draft,
          onViewReport: () {
            // يغلق صفحة الاختيار ويعيد المستخدم إلى تقرير الأحمال عند الطلب.
            Navigator.of(context).pop();
          },
          onDeviceSelected: (device) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportLoadEntryPage(
                  draft: widget.draft,
                  device: device,
                  onSaved: (detail) {
                    // نحفظ الجهاز داخل قائمة التقرير الحالية.
                    setState(() => _details.add(detail));

                    // نغلق صفحة إدخال الحمل فقط، ونبقى داخل صفحة الاختيار.
                    Navigator.of(context).pop();
                    selectionKey.currentState?.resetToCategories();

                    // نعرض تنبيهًا قصيرًا دون فتح تقرير الأحمال تلقائيًا.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تمت إضافة الجهاز إلى التقرير'),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );

    // يعيد بناء ملخص الأحمال عند العودة إلى صفحة التقرير.
    if (mounted) setState(() {});
  }

  void _removeDevice(int index) {
    setState(() => _details.removeAt(index));
  }

  Future<void> _finish() async {
    if (_details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف جهازًا واحدًا على الأقل')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final reportId = await _reportRepository.createReport(
        draft: widget.draft,
        details: _details,
      );
      final calculation = await _reportRepository.calculateReport(
        reportId: reportId,
      );

      if (!mounted) return;

      final result = calculation['result'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'نجح المحرك: ${result['total_energy_wh']} واط⋅ساعة، '
            'ألواح ${result['recommended_panel_wp']} واط، '
            'بطارية ${result['recommended_battery_ah']} أمبير⋅ساعة',
          ),
        ),
      );

      if (!mounted) return;
      if (!mounted) return;

      if (calculation['success'] != true) {
        throw Exception('لم ينجح الحساب');
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CalculationResultPage(reportId: reportId),
        ),
      );
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ التقرير: $error')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
                scrolledUnderElevation: 0,
                title: const Text('أحمال التقرير'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ReportSummary(draft: widget.draft),
                      const SizedBox(height: 12),
                      _LoadTotals(details: _details),

                      const SizedBox(height: 16),
                      if (_details.isEmpty)
                        const _EmptyDevicesMessage()
                      else
                        ..._details.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _SelectedDeviceCard(
                              detail: entry.value,
                              onEdit: () => _editDevice(entry.key),
                              onRemove: () => _removeDevice(entry.key),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _chooseDevice,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة جهاز آخر'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _isSaving ? null : _finish,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_outlined),
                        label: Text(
                          _isSaving ? 'جارٍ حفظ التقرير...' : 'حفظ التقرير',
                        ),
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
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.draft});

  final ReportDraft draft;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'بيانات التقرير',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(draft.title, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            '${draft.systemVoltage} فولت',
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SelectedDeviceCard extends StatelessWidget {
  const _SelectedDeviceCard({
    required this.detail,
    required this.onEdit,
    required this.onRemove,
  });

  final ReportDeviceDetailDraft detail;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final device = detail.device;

    return _GlassBox(
      child: Row(
        children: [
          const Icon(
            Icons.devices_other_rounded,
            color: AppColors.textLight,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.shortName,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية: ${formatUserNumber(detail.quantity)} | '
                  'نهارًا: ${formatUserNumber(detail.dayHours)} س | '
                  'ليلًا: ${formatUserNumber(detail.nightHours)} س',

                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                tooltip: 'تعديل الكمية والساعات',
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.textLight,
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'حذف الجهاز',
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDevicesMessage extends StatelessWidget {
  const _EmptyDevicesMessage();

  @override
  Widget build(BuildContext context) {
    return const _GlassBox(
      child: Text(
        'لم تتم إضافة أجهزة بعد\nابدأ باختيار جهاز من الكتالوج',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.textMuted, height: 1.5),
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

/// ملخص فوري للأحمال المدخلة في التقرير.
class _LoadTotals extends StatelessWidget {
  const _LoadTotals({required this.details});

  final List<ReportDeviceDetailDraft> details;

  double get peakPower {
    return details.fold(
      0,
      (total, item) => total + item.device.wattageW * item.quantity,
    );
  }

  double get dayEnergy {
    return details.fold(
      0,
      (total, item) =>
          total + item.device.wattageW * item.quantity * item.dayHours,
    );
  }

  double get nightEnergy {
    return details.fold(
      0,
      (total, item) =>
          total + item.device.wattageW * item.quantity * item.nightHours,
    );
  }

  double get totalEnergy => dayEnergy + nightEnergy;

  @override
  Widget build(BuildContext context) {
    return _GlassBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ملخص الأحمال',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TotalItem(
                  label: 'القدرة القصوى',
                  value: peakPower,
                  unit: 'واط',
                  icon: Icons.bolt_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TotalItem(
                  label: 'الطاقة اليومية',
                  value: totalEnergy,
                  unit: 'واط⋅ساعة',
                  icon: Icons.energy_savings_leaf_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _TotalItem(
                  label: 'نهارًا',
                  value: dayEnergy,
                  unit: 'واط⋅ساعة',
                  icon: Icons.wb_sunny_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TotalItem(
                  label: 'ليلًا',
                  value: nightEnergy,
                  unit: 'واط⋅ساعة',
                  icon: Icons.nightlight_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final double value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textLight, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            '${formatUserNumber(value)} $unit',
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

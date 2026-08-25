import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/catalog_device.dart';
import '../models/report_device_detail_draft.dart';
import '../models/report_draft.dart';

/// صفحة إدخال بيانات حمل الجهاز المختار.
class ReportLoadEntryPage extends StatefulWidget {
  const ReportLoadEntryPage({
    super.key,
    required this.draft,
    required this.device,
    this.initialDetail,
    required this.onSaved,
  });

  final ReportDraft draft;
  final CatalogDevice device;
  final ReportDeviceDetailDraft? initialDetail;
  final ValueChanged<ReportDeviceDetailDraft> onSaved;

  @override
  State<ReportLoadEntryPage> createState() => _ReportLoadEntryPageState();
}

class _ReportLoadEntryPageState extends State<ReportLoadEntryPage> {
  static const double _pshHours = 5;
  static const double _nightWindowHours = 24 - _pshHours;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _dayHoursController = TextEditingController();
  final _nightHoursController = TextEditingController();
  @override
  void initState() {
    super.initState();

    final detail = widget.initialDetail;
    if (detail == null) return;

    _quantityController.text = _formatNumber(detail.quantity);
    _dayHoursController.text = _formatNumber(detail.dayHours);
    _nightHoursController.text = _formatNumber(detail.nightHours);
  }

  String _formatNumber(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dayHoursController.dispose();
    _nightHoursController.dispose();
    super.dispose();
  }

  double _numberOf(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  String? _validatePositive(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number <= 0) return 'أدخل قيمة أكبر من صفر';
    return null;
  }

  String? _validateDayHours(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0 || number > _pshHours) {
      return 'أدخل عددًا بين 0 و$_pshHours ساعات';
    }
    return null;
  }

  String? _validateNightHours(String? value) {
    final number = double.tryParse(value?.trim() ?? '');
    if (number == null || number < 0 || number > _nightWindowHours) {
      return 'أدخل عددًا بين 0 و$_nightWindowHours ساعة';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final dayHours = _numberOf(_dayHoursController);
    final nightHours = _numberOf(_nightHoursController);

    if (dayHours + nightHours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب إدخال ساعات تشغيل نهارية أو ليلية')),
      );
      return;
    }

    widget.onSaved(
      ReportDeviceDetailDraft(
        device: widget.device,
        quantity: _numberOf(_quantityController),
        dayHours: dayHours,
        nightHours: nightHours,
      ),
    );
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
                title: const Text('إدخال حمل الجهاز'),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                sliver: SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DeviceSummary(device: widget.device),
                        const SizedBox(height: 16),
                        _GlassSection(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'بيانات التشغيل',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _quantityController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'الكمية',
                                  hintText: 'مثال: 1',
                                  prefixIcon: Icon(Icons.numbers_rounded),
                                ),
                                validator: _validatePositive,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _dayHoursController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'ساعات التشغيل نهارًا',
                                  hintText: 'من 0 إلى 5 ساعات',
                                  suffixText: 'ساعة',
                                  prefixIcon: Icon(Icons.wb_sunny_outlined),
                                ),
                                validator: _validateDayHours,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _nightHoursController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'ساعات التشغيل ليلًا',
                                  hintText: 'من 0 إلى 19 ساعة',
                                  suffixText: 'ساعة',
                                  prefixIcon: Icon(Icons.nightlight_outlined),
                                ),
                                validator: _validateNightHours,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            widget.initialDetail == null
                                ? 'إضافة الجهاز إلى التقرير'
                                : 'حفظ تعديل الجهاز',
                          ),
                        ),
                      ],
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

/// ملخص الجهاز القادم من الكتالوج.
class _DeviceSummary extends StatelessWidget {
  const _DeviceSummary({required this.device});

  final CatalogDevice device;

  @override
  Widget build(BuildContext context) {
    return _GlassSection(
      child: Row(
        children: [
          const Icon(
            Icons.devices_other_rounded,
            size: 42,
            color: AppColors.textLight,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  device.description,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 5),
                Text(
                  '${device.wattageW.toStringAsFixed(0)} واط كحد أقصى',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// حاوية زجاجية موحدة للصفحة.
class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.child});

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

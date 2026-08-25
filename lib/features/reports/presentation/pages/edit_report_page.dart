import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../calculation/data/models/battery_type.dart';
import '../../../calculation/data/models/system_voltage.dart';
import '../../../calculation/presentation/models/report_device_detail_draft.dart';
import '../../../calculation/presentation/models/report_draft.dart';
import '../../../calculation/presentation/pages/calculation_result_page.dart';
import '../../../calculation/presentation/pages/device_selection_page.dart';
import '../../../calculation/presentation/pages/report_load_entry_page.dart';
import '../../data/repositories/reports_repository.dart';

/// صفحة تعديل تقرير محفوظ وإعادة حسابه.
class EditReportPage extends StatefulWidget {
  const EditReportPage({super.key, required this.reportId});

  final int reportId;

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final ReportsRepository _repository = ReportsRepository();
  late Future<_EditData> _dataFuture;
  final _titleController = TextEditingController();
  ReportDraft? _draft;
  List<ReportDeviceDetailDraft> _details = [];
  List<SystemVoltage> _voltages = [];
  List<BatteryType> _batteries = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_EditData> _loadData() async {
    final values = await Future.wait<dynamic>([
      _repository.fetchDraft(widget.reportId),
      _repository.fetchDetails(widget.reportId),
      _repository.fetchVoltages(),
    ]);
    final draft = values[0] as ReportDraft;
    final batteries = await _repository.fetchBatteriesForVoltage(
      draft.voltageId,
    );
    return _EditData(
      draft: draft,
      details: values[1] as List<ReportDeviceDetailDraft>,
      voltages: values[2] as List<SystemVoltage>,
      batteries: batteries,
    );
  }

  void _applyData(_EditData data) {
    if (!_loading) return;
    _draft = data.draft;
    _titleController.text = data.draft.title;
    _details = [...data.details];
    _voltages = data.voltages;
    _batteries = data.batteries;
    _loading = false;
  }

  Future<void> _changeVoltage(int? id) async {
    if (id == null) return;
    final voltage = _voltages.firstWhere((item) => item.id == id);
    setState(() {
      _draft = _draft!.copyWith(
        voltageId: voltage.id,
        systemVoltage: voltage.value,
        batteryId: 0,
      );
      _batteries = [];
    });
    final batteries = await _repository.fetchBatteriesForVoltage(id);
    if (!mounted) return;
    setState(() => _batteries = batteries);
  }

  void _changeBattery(int? id) {
    if (id == null) return;
    setState(() => _draft = _draft!.copyWith(batteryId: id));
  }

  Future<void> _addDevice() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceSelectionPage(
          draft: _draft!,
          onDeviceSelected: (device) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ReportLoadEntryPage(
                  draft: _draft!,
                  device: device,
                  onSaved: (detail) {
                    setState(() => _details.add(detail));
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editDevice(int index) async {
    final current = _details[index];
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReportLoadEntryPage(
          draft: _draft!,
          device: current.device,
          initialDetail: current,
          onSaved: (detail) {
            setState(() => _details[index] = detail);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _message('أدخل اسم التقرير');
      return;
    }
    if (_draft == null || _draft!.batteryId == 0) {
      _message('اختر نوع البطارية');
      return;
    }
    if (_details.isEmpty) {
      _message('يجب أن يحتوي التقرير على جهاز واحد على الأقل');
      return;
    }

    setState(() => _saving = true);
    try {
      final updatedDraft = _draft!.copyWith(title: title);
      await _repository.updateReport(
        reportId: widget.reportId,
        draft: updatedDraft,
        details: _details,
      );
      final calculation = await _repository.recalculateReport(widget.reportId);
      if (!mounted) return;
      if (calculation['success'] != true) {
        throw Exception('لم تنجح إعادة الحساب');
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CalculationResultPage(reportId: widget.reportId),
        ),
      );
    } catch (error) {
      if (mounted) _message('تعذر حفظ التعديلات: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EditData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: AppBackground(
              child: Center(
                child: Text('تعذر تحميل التقرير: ${snapshot.error}'),
              ),
            ),
          );
        }
        _applyData(snapshot.data!);
        return _buildEditor();
      },
    );
  }

  Widget _buildEditor() {
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
                scrolledUnderElevation: 0,
                title: Text('تعديل التقرير'),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _GlassBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'بيانات التقرير',
                              style: _SectionTitle.style,
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'اسم التقرير',
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue: _draft!.voltageId,
                              decoration: const InputDecoration(
                                labelText: 'جهد النظام',
                                prefixIcon: Icon(Icons.bolt_outlined),
                              ),
                              items: _voltages
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text('${item.value} فولت'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _changeVoltage,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              initialValue:
                                  _batteries.any(
                                    (item) => item.id == _draft!.batteryId,
                                  )
                                  ? _draft!.batteryId
                                  : null,
                              decoration: const InputDecoration(
                                labelText: 'نوع البطارية',
                                prefixIcon: Icon(Icons.battery_full_outlined),
                              ),
                              items: _batteries
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(
                                        '${item.name} — DOD ${item.dodPercent.toStringAsFixed(0)}%',
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _changeBattery,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      _GlassBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'الأحمال المضافة',
                              style: _SectionTitle.style,
                            ),
                            const SizedBox(height: 12),
                            if (_details.isEmpty)
                              const Text(
                                'لا توجد أحمال',
                                style: TextStyle(color: AppColors.textMuted),
                              )
                            else
                              ..._details.asMap().entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _DetailRow(
                                    detail: entry.value,
                                    onEdit: () => _editDevice(entry.key),
                                    onDelete: () => setState(
                                      () => _details.removeAt(entry.key),
                                    ),
                                  ),
                                ),
                              ),
                            OutlinedButton.icon(
                              onPressed: _addDevice,
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('إضافة جهاز'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: _saving
                            ? const SizedBox(
                                width: 19,
                                height: 19,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                        label: Text(
                          _saving
                              ? 'جارٍ إعادة الحساب...'
                              : 'حفظ وإعادة الحساب',
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

class _EditData {
  const _EditData({
    required this.draft,
    required this.details,
    required this.voltages,
    required this.batteries,
  });
  final ReportDraft draft;
  final List<ReportDeviceDetailDraft> details;
  final List<SystemVoltage> voltages;
  final List<BatteryType> batteries;
}

class _SectionTitle {
  static const style = TextStyle(
    color: AppColors.textLight,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.detail,
    required this.onEdit,
    required this.onDelete,
  });
  final ReportDeviceDetailDraft detail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _number(double value) => value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.devices_other_rounded, color: AppColors.textLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.device.shortName,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية ${_number(detail.quantity)} • نهارًا ${_number(detail.dayHours)}س • ليلًا ${_number(detail.nightHours)}س',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textLight,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppColors.error,
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

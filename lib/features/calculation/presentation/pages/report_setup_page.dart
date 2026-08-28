import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/shamsuna_bottom_bar.dart';
import '../../../reports/presentation/pages/compare_reports_page.dart';
import '../../../reports/presentation/pages/my_reports_page.dart';
import '../../../suggestions/presentation/pages/suggest_device_page.dart';

import '../../data/models/battery_type.dart';
import '../../data/models/system_voltage.dart';
import '../../data/repositories/battery_repository.dart';
import '../models/report_draft.dart';

/// صفحة إعداد التقرير بالاعتماد على بيانات Supabase.
class ReportSetupPage extends StatefulWidget {
  const ReportSetupPage({
    super.key,
    required this.onContinue,
    this.showBottomBar = true,
  });

  final ValueChanged<ReportDraft> onContinue;
  final bool showBottomBar; // يرسل التقرير للخطوة التالية.

  @override
  State<ReportSetupPage> createState() => _ReportSetupPageState();
}

class _ReportSetupPageState extends State<ReportSetupPage> {
  final _formKey = GlobalKey<FormState>(); // التحقق من الحقول.
  final _titleController = TextEditingController(); // اسم التقرير.
  final _repository = BatteryRepository(); // مصدر البيانات من Supabase.

  late final Future<List<SystemVoltage>>
  _voltagesFuture; // تحميل الجهود مرة واحدة.
  Future<List<BatteryType>>? _batteriesFuture; // لا يبدأ قبل اختيار الجهد.
  int? _voltageId; // معرّف الجهد المختار.
  int? _voltageValue; // قيمة الجهد للـReportDraft.
  int? _batteryId; // معرّف البطارية المختارة.

  @override
  void initState() {
    super.initState();
    _voltagesFuture = _repository.fetchVoltages(); // قراءة الجهود من Supabase.
  }

  @override
  void dispose() {
    _titleController.dispose(); // تحرير حقل الاسم.
    super.dispose();
  }

  void _selectVoltage(SystemVoltage? voltage) {
    if (voltage == null) return; // تجاهل القيمة الفارغة.

    setState(() {
      _voltageId = voltage.id; // حفظ معرّف الجهد.
      _voltageValue = voltage.value; // حفظ قيمة الجهد.
      _batteryId = null; // إلغاء البطارية القديمة عند تغيير الجهد.
      _batteriesFuture = _repository.fetchBatteriesForVoltage(
        voltage.id,
      ); // تحميل التوافق.
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return; // فحص المدخلات.

    widget.onContinue(
      ReportDraft(
        title: _titleController.text.trim(),
        batteryId: _batteryId!,
        voltageId: _voltageId!,
        systemVoltage: _voltageValue!,
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
                currentIndex: 0,
                onCreateReport: () {},
                onMyReports: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyReportsPage()),
                ),
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
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              title: const Text('إنشاء تقرير'),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.panelNavy.withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.solar_power_rounded,
                          size: 46,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'بيانات التقرير',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.textLight),
                        ),
                        const SizedBox(height: 22),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'اسم التقرير',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'أدخل اسم التقرير'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<List<SystemVoltage>>(
                          future: _voltagesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'جهد النظام',
                                  prefixIcon: Icon(Icons.bolt_outlined),
                                ),
                                child: LinearProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return const InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'جهد النظام',
                                  prefixIcon: Icon(Icons.error_outline),
                                ),
                                child: Text('تعذر تحميل جهود النظام'),
                              );
                            }

                            final voltages =
                                snapshot.data ?? const <SystemVoltage>[];
                            return DropdownButtonFormField<int>(
                              initialValue: _voltageId,
                              decoration: const InputDecoration(
                                labelText: 'جهد النظام',
                                prefixIcon: Icon(Icons.bolt_outlined),
                              ),
                              dropdownColor: AppColors.panelNavy,
                              items: voltages.map((voltage) {
                                return DropdownMenuItem<int>(
                                  value: voltage.id,
                                  child: Text('${voltage.value} فولت'),
                                );
                              }).toList(),
                              onChanged: (id) {
                                final selected = voltages
                                    .where((item) => item.id == id)
                                    .firstOrNull;
                                _selectVoltage(selected);
                              },
                              validator: (value) =>
                                  value == null ? 'اختر جهد النظام' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        FutureBuilder<List<BatteryType>>(
                          future: _batteriesFuture,
                          builder: (context, snapshot) {
                            if (_voltageId == null) {
                              return const InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'نوع البطارية',
                                  prefixIcon: Icon(Icons.battery_full_outlined),
                                ),
                                child: Text('اختر جهد النظام أولًا'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'نوع البطارية',
                                  prefixIcon: Icon(Icons.battery_full_outlined),
                                ),
                                child: LinearProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'نوع البطارية',
                                  prefixIcon: Icon(Icons.error_outline),
                                ),
                                child: Text(
                                  'تعذر تحميل البطاريات: ${snapshot.error}',
                                ),
                              );
                            }

                            final batteries =
                                snapshot.data ?? const <BatteryType>[];
                            return DropdownButtonFormField<int>(
                              initialValue: _batteryId,
                              decoration: const InputDecoration(
                                labelText: 'نوع البطارية',
                                prefixIcon: Icon(Icons.battery_full_outlined),
                              ),
                              dropdownColor: AppColors.panelNavy,
                              items: batteries.map((battery) {
                                return DropdownMenuItem<int>(
                                  value: battery.id,
                                  child: Text(
                                    '${battery.name} — DOD ${battery.dodPercent.toStringAsFixed(0)}%',
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _batteryId = value),
                              validator: (value) =>
                                  value == null ? 'اختر نوع البطارية' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('متابعة لاختيار الأجهزة'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

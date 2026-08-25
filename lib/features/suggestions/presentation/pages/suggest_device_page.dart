import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/shamsuna_bottom_bar.dart';
import '../../../calculation/presentation/pages/report_setup_page.dart';
import '../../../reports/presentation/pages/compare_reports_page.dart';
import '../../../reports/presentation/pages/my_reports_page.dart';

import '../../../calculation/data/models/device_category.dart';
import '../../../calculation/data/repositories/device_repository.dart';
import '../../data/models/device_suggestion.dart';
import '../../data/repositories/suggestions_repository.dart';

/// صفحة إرسال جهاز جديد للمراجعة من المستخدم.
class SuggestDevicePage extends StatefulWidget {
  const SuggestDevicePage({super.key, this.showBottomBar = true});

  final bool showBottomBar;

  @override
  State<SuggestDevicePage> createState() => _SuggestDevicePageState();
}

class _SuggestDevicePageState extends State<SuggestDevicePage> {
  final _formKey = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _model = TextEditingController();
  final _wattage = TextEditingController();
  final _categories = DeviceRepository();
  final _suggestions = SuggestionsRepository();

  late Future<List<DeviceCategory>> _categoriesFuture;
  int? _categoryId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categories.fetchCategories();
  }

  @override
  void dispose() {
    _company.dispose();
    _model.dispose();
    _wattage.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await _suggestions.submit(
        DeviceSuggestion(
          categoryId: _categoryId!,
          companyName: _company.text,
          modelName: _model.text,
          wattageW: double.parse(_wattage.text.trim()),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال اقتراح الجهاز للمراجعة')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر إرسال الاقتراح: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ShamsunaBottomBar(
          currentIndex: 4,
          onCreateReport: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportSetupPage(onContinue: (_) {}),
            ),
          ),
          onMyReports: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MyReportsPage())),
          onHome: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          onCompare: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CompareReportsPage())),
          onSuggestDevice: () {},
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                title: Text('اقتراح جهاز'),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: _GlassPanel(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.devices_other_rounded,
                            color: AppColors.textLight,
                            size: 54,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'أضف جهازًا إلى الكتالوج',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ستتم مراجعة الاقتراح من المشرف قبل اعتماده.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder<List<DeviceCategory>>(
                            future: _categoriesFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.textLight,
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  'تعذر تحميل الفئات: ${snapshot.error}',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                );
                              }
                              final categories =
                                  snapshot.data ?? const <DeviceCategory>[];
                              return DropdownButtonFormField<int>(
                                initialValue: _categoryId,
                                dropdownColor: AppColors.panelNavy,
                                decoration: _decoration(
                                  'الفئة',
                                  Icons.category_outlined,
                                ),
                                items: categories
                                    .map(
                                      (category) => DropdownMenuItem<int>(
                                        value: category.id,
                                        child: Text(category.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: _saving
                                    ? null
                                    : (value) =>
                                          setState(() => _categoryId = value),
                                validator: (value) =>
                                    value == null ? 'اختر الفئة' : null,
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _company,
                            'اسم الشركة (اختياري)',
                            Icons.business_outlined,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _model,
                            'اسم الموديل',
                            Icons.devices_outlined,
                            required: true,
                          ),
                          const SizedBox(height: 14),
                          _field(
                            _wattage,
                            'القدرة القصوى بالواط',
                            Icons.bolt_outlined,
                            required: true,
                            number: true,
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              _saving ? 'جارٍ الإرسال...' : 'إرسال للمراجعة',
                            ),
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
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_saving,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: AppColors.textLight),
      decoration: _decoration(label, icon),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'هذا الحقل مطلوب';
        }
        if (number && (double.tryParse(value?.trim() ?? '') ?? 0) <= 0) {
          return 'أدخل قدرة صحيحة أكبر من صفر';
        }
        return null;
      },
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textMuted),
      labelStyle: const TextStyle(color: AppColors.textMuted),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

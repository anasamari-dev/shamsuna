import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/admin_device_suggestion.dart';
import '../../data/repositories/admin_suggestions_repository.dart';

/// شاشة المشرف لاستلام الاقتراحات وإكمال بياناتها قبل الاعتماد.
class AdminSuggestionsPage extends StatefulWidget {
  const AdminSuggestionsPage({super.key});

  @override
  State<AdminSuggestionsPage> createState() => _AdminSuggestionsPageState();
}

class _AdminSuggestionsPageState extends State<AdminSuggestionsPage> {
  final _repository = AdminSuggestionsRepository();
  late Future<List<AdminDeviceSuggestion>> _future;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchPending();
  }

  Future<void> _reload() async {
  final pendingFuture = _repository.fetchPending();

  if (!mounted) {
    return;
  }

  setState(() {
    _future = pendingFuture;
  });
}


  Future<void> _openReview(AdminDeviceSuggestion item, bool approve) async {
    final result = await showDialog<_ReviewData>(
      context: context,
      builder: (_) => _ReviewDialog(item: item, approve: approve),
    );
    if (result == null || !mounted) {
      return;
    }

    setState(() => _busyId = item.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approve ? 'جارٍ اعتماد الجهاز...' : 'جارٍ رفض الاقتراح...',
        ),
        duration: const Duration(seconds: 15),
      ),
    );

    try {
      await _repository
          .review(
            suggestionId: item.id,
            approve: approve,
            companyName: result.companyName,
            modelName: result.modelName,
            shortName: result.shortName,
            description: result.description,
            wattageW: result.wattageW,
            note: result.note,
          )
          .timeout(const Duration(seconds: 20));
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'تم اعتماد الجهاز وإضافته للكتالوج' : 'تم رفض الاقتراح',
          ),
        ),
      );
      _reload();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تنفيذ العملية: $error')));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  title: const Text('اقتراحات الأجهزة'),
                  centerTitle: true,
                  actions: [
                    IconButton(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: FutureBuilder<List<AdminDeviceSuggestion>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.textLight,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: _Message(
                            text: 'تعذر تحميل الاقتراحات: ${snapshot.error}',
                            onRetry: _reload,
                          ),
                        );
                      }
                      final items =
                          snapshot.data ?? const <AdminDeviceSuggestion>[];
                      if (items.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: _Message(text: 'لا توجد اقتراحات معلقة'),
                        );
                      }
                      return SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _SuggestionCard(
                            item: item,
                            busy: _busyId == item.id,
                            onApprove: () => _openReview(item, true),
                            onReject: () => _openReview(item, false),
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

class _ReviewData {
  const _ReviewData({
    required this.companyName,
    required this.modelName,
    required this.shortName,
    required this.description,
    required this.wattageW,
    required this.note,
  });

  final String companyName;
  final String modelName;
  final String shortName;
  final String description;
  final double wattageW;
  final String note;
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.item, required this.approve});

  final AdminDeviceSuggestion item;
  final bool approve;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _model;
  late final TextEditingController _shortName;
  late final TextEditingController _description;
  late final TextEditingController _wattage;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _company = TextEditingController(text: widget.item.companyName ?? '');
    _model = TextEditingController(text: widget.item.modelName);
    _shortName = TextEditingController(text: widget.item.modelName);
    _description = TextEditingController(
      text: 'جهاز ${widget.item.categoryName}',
    );
    _wattage = TextEditingController(text: _number(widget.item.wattageW));
  }

  @override
  void dispose() {
    _company.dispose();
    _model.dispose();
    _shortName.dispose();
    _description.dispose();
    _wattage.dispose();
    _note.dispose();
    super.dispose();
  }

  String _number(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _ReviewData(
        companyName: _company.text,
        modelName: _model.text,
        shortName: _shortName.text,
        description: _description.text,
        wattageW: double.parse(_wattage.text.trim()),
        note: _note.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.approve ? 'إكمال واعتماد الجهاز' : 'رفض الاقتراح'),
      content: SizedBox(
        width: 430,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.approve) ...[
                  _input(_company, 'اسم الشركة (اختياري)'),
                  _input(_model, 'اسم الموديل', required: true),
                  _input(_shortName, 'الاسم المختصر', required: true),
                  _input(_description, 'الوصف', required: true, maxLines: 2),
                  _input(
                    _wattage,
                    'القدرة بالواط',
                    required: true,
                    number: true,
                  ),
                ],
                _input(
                  _note,
                  widget.approve
                      ? 'ملاحظة للمستخدم (اختياري)'
                      : 'سبب الرفض (اختياري)',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.approve ? 'حفظ واعتماد' : 'تأكيد الرفض'),
        ),
      ],
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          if (number && (double.tryParse(value?.trim() ?? '') ?? 0) <= 0) {
            return 'أدخل رقمًا صحيحًا';
          }
          return null;
        },
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.item,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final AdminDeviceSuggestion item;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            item.modelName,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الفئة: ${item.categoryName}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          Text(
            'الشركة: ${item.companyName?.trim().isNotEmpty == true ? item.companyName : 'غير محددة'}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          Text(
            'القدرة: ${item.wattageW} واط',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          Text(
            'المرسل: ${item.senderName}',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onReject,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : onApprove,
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('اعتماد'),
                ),
              ),
            ],
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

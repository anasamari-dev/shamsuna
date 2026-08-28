import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/repositories/catalog_admin_repository.dart';

/// صفحة إدارة الكتالوج، ولا تُفتح إلا من لوحة المشرف.
class AdminCatalogPage extends StatefulWidget {
  const AdminCatalogPage({super.key});

  @override
  State<AdminCatalogPage> createState() => _AdminCatalogPageState();
}

class _AdminCatalogPageState extends State<AdminCatalogPage>
    with SingleTickerProviderStateMixin {
  final _repository = CatalogAdminRepository();
  late final TabController _tabs;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  int? _categoryId;
  int? _companyId;
  List<Map<String, dynamic>> _companies = const [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _categoriesFuture = _repository.fetchCategories();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _reloadCategories() {
    final future = _repository.fetchCategories();
    setState(() {
      _categoriesFuture = future;
    });
  }

  Future<void> _selectCategory(int? id) async {
    setState(() {
      _categoryId = id;
      _companyId = null;
      _companies = const [];
    });
    if (id == null) return;
    final companies = await _repository.fetchCompanies(id);
    if (!mounted || id != _categoryId) return;
    setState(() => _companies = companies);
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? item}) async {
    final result = await showDialog<_CategoryForm>(
      context: context,
      builder: (_) => _CategoryDialog(item: item),
    );
    if (result == null) return;
    try {
      if (item == null) {
        await _repository.createCategory(
          nameAr: result.name,
          iconKey: result.iconKey,
        );
      } else {
        await _repository.updateCategory(
          categoryId: (item['category_id'] as num).toInt(),
          nameAr: result.name,
          iconKey: result.iconKey,
          isActive: result.isActive,
        );
      }
      if (mounted) _reloadCategories();
    } catch (error) {
      if (mounted) _error('تعذر حفظ الفئة: $error');
    }
  }

  void _error(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  title: const Text('إدارة الكتالوج'),
                  centerTitle: true,
                ),
                TabBar(
                  controller: _tabs,
                  labelColor: AppColors.textLight,
                  unselectedLabelColor: AppColors.textMuted,
                  indicatorColor: AppColors.textLight,
                  tabs: const [
                    Tab(text: 'الفئات'),
                    Tab(text: 'الشركات'),
                    Tab(text: 'الأجهزة'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _CategoriesTab(
                        future: _categoriesFuture,
                        onRefresh: _reloadCategories,
                        onEdit: _showCategoryDialog,
                        onAdd: () => _showCategoryDialog(),
                      ),
                      _CompaniesTab(
                        categoriesFuture: _categoriesFuture,
                        selectedCategoryId: _categoryId,
                        onCategoryChanged: _selectCategory,
                        companies: _companies,
                        repository: _repository,
                        onError: _error,
                      ),
                      _DevicesTab(
                        categoriesFuture: _categoriesFuture,
                        selectedCategoryId: _categoryId,
                        selectedCompanyId: _companyId,
                        companies: _companies,
                        onCategoryChanged: _selectCategory,
                        onCompanyChanged: (id) =>
                            setState(() => _companyId = id),
                        repository: _repository,
                        onError: _error,
                      ),
                    ],
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

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({
    required this.future,
    required this.onRefresh,
    required this.onEdit,
    required this.onAdd,
  });

  final Future<List<Map<String, dynamic>>> future;
  final VoidCallback onRefresh;
  final Future<void> Function({Map<String, dynamic>? item}) onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _AdminListScaffold(
      future: future,
      onRefresh: onRefresh,
      onAdd: onAdd,
      addLabel: 'إضافة فئة',
      itemBuilder: (item) => ListTile(
        leading: const Icon(
          Icons.category_outlined,
          color: AppColors.textLight,
        ),
        title: Text(
          '${item['name_ar']}',
          style: const TextStyle(color: AppColors.textLight),
        ),
        subtitle: Text(
          item['is_active'] == true ? 'مفعلة' : 'معطلة',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: AppColors.textLight),
          onPressed: () => onEdit(item: item),
        ),
      ),
    );
  }
}

class _CompaniesTab extends StatelessWidget {
  const _CompaniesTab({
    required this.categoriesFuture,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.companies,
    required this.repository,
    required this.onError,
  });

  final Future<List<Map<String, dynamic>>> categoriesFuture;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;
  final List<Map<String, dynamic>> companies;
  final CatalogAdminRepository repository;
  final ValueChanged<String> onError;

  @override
  Widget build(BuildContext context) {
    return _SelectionTab(
      categoriesFuture: categoriesFuture,
      selectedCategoryId: selectedCategoryId,
      onCategoryChanged: onCategoryChanged,
      child: selectedCategoryId == null
          ? const _EmptyText(text: 'اختر فئة لعرض الشركات')
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: companies.length + 1,
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == companies.length) {
                  return OutlinedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<_CompanyForm>(
                        context: context,
                        builder: (_) => const _CompanyDialog(),
                      );
                      if (result == null) return;
                      try {
                        await repository.createCompany(
                          categoryId: selectedCategoryId!,
                          name: result.name,
                          iconUrl: result.iconUrl,
                        );
                        onCategoryChanged(selectedCategoryId);
                      } catch (error) {
                        onError('تعذر حفظ الشركة: $error');
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة شركة'),
                  );
                }
                final item = companies[index];
<<<<<<< HEAD
                final companyId = (item['company_id'] as num).toInt();
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
                return _GlassTile(
                  child: ListTile(
                    leading: _CompanyIcon(url: item['icon_url'] as String?),
                    title: Text(
                      '${item['name']}',
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                    subtitle: Text(
                      item['is_active'] == true ? 'مفعلة' : 'معطلة',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
<<<<<<< HEAD
                    trailing: IconButton(
                      tooltip: 'تعديل الشركة',
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.textLight,
                      ),
                      onPressed: () async {
                        final result = await showDialog<_CompanyForm>(
                          context: context,
                          builder: (_) => _CompanyDialog(
                            initialName: '${item['name']}',
                            initialIconUrl: item['icon_url'] as String?,
                            isEditing: true,
                          ),
                        );
                        if (result == null) return;
                        try {
                          await repository.updateCompany(
                            companyId: companyId,
                            name: result.name,
                            iconUrl: result.iconUrl,
                            isActive: item['is_active'] == true,
                          );
                          onCategoryChanged(selectedCategoryId);
                        } catch (error) {
                          onError('تعذر تحديث الشركة: $error');
                        }
                      },
                    ),
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
                  ),
                );
              },
            ),
    );
  }
}

class _DevicesTab extends StatelessWidget {
  const _DevicesTab({
    required this.categoriesFuture,
    required this.selectedCategoryId,
    required this.selectedCompanyId,
    required this.companies,
    required this.onCategoryChanged,
    required this.onCompanyChanged,
    required this.repository,
    required this.onError,
  });

  final Future<List<Map<String, dynamic>>> categoriesFuture;
  final int? selectedCategoryId;
  final int? selectedCompanyId;
  final List<Map<String, dynamic>> companies;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<int?> onCompanyChanged;
  final CatalogAdminRepository repository;
  final ValueChanged<String> onError;

  Future<void> _addDevice(BuildContext context) async {
    if (selectedCategoryId == null || selectedCompanyId == null) return;
    final company = companies.firstWhere(
      (item) => (item['company_id'] as num).toInt() == selectedCompanyId,
    );
    final result = await showDialog<_DeviceForm>(
      context: context,
      builder: (_) => _DeviceDialog(companyName: '${company['name']}'),
    );
    if (result == null) return;
    try {
      await repository.createDevice(
        categoryId: selectedCategoryId!,
        companyId: selectedCompanyId!,
        companyName: '${company['name']}',
        modelName: result.modelName,
        shortName: result.shortName,
        description: result.description,
        wattageW: result.wattageW,
        specifications: result.specifications,
      );
      onCompanyChanged(selectedCompanyId);
    } catch (error) {
      onError('تعذر إضافة الجهاز: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SelectionTab(
      categoriesFuture: categoriesFuture,
      selectedCategoryId: selectedCategoryId,
      onCategoryChanged: onCategoryChanged,
      extra: DropdownButtonFormField<int>(
        initialValue: selectedCompanyId,
        dropdownColor: AppColors.panelNavy,
        style: const TextStyle(color: AppColors.textLight),
        decoration: const InputDecoration(labelText: 'الشركة'),
        items: companies
            .map(
              (item) => DropdownMenuItem<int>(
                value: (item['company_id'] as num).toInt(),
                child: Text('${item['name']}'),
              ),
            )
            .toList(),
        onChanged: onCompanyChanged,
      ),
      child: Column(
        children: [
          if (selectedCategoryId != null && selectedCompanyId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () => _addDevice(context),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('إضافة جهاز'),
                ),
              ),
            ),
          Expanded(
            child: selectedCategoryId == null || selectedCompanyId == null
                ? const _EmptyText(text: 'اختر الفئة والشركة لعرض الأجهزة')
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: repository.fetchDevices(
                      categoryId: selectedCategoryId!,
                      companyId: selectedCompanyId!,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final devices = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: devices.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = devices[index];
                          return _GlassTile(
                            child: ListTile(
                              title: Text(
                                '${item['short_name']}',
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                              ),
                              subtitle: Text(
                                '${item['description']}\n${item['wattage_w']} واط',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: Switch(
                                value: item['is_active'] == true,
                                onChanged: (active) async {
                                  try {
                                    await repository.setDeviceActive(
                                      deviceId: (item['device_id'] as num)
                                          .toInt(),
                                      isActive: active,
                                    );
                                  } catch (error) {
                                    onError('تعذر تغيير حالة الجهاز: $error');
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectionTab extends StatelessWidget {
  const _SelectionTab({
    required this.categoriesFuture,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.child,
    this.extra,
  });

  final Future<List<Map<String, dynamic>>> categoriesFuture;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;
  final Widget child;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: categoriesFuture,
            builder: (context, snapshot) {
              final categories =
                  snapshot.data ?? const <Map<String, dynamic>>[];
              return Column(
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedCategoryId,
                    dropdownColor: AppColors.panelNavy,
                    style: const TextStyle(color: AppColors.textLight),
                    decoration: const InputDecoration(labelText: 'الفئة'),
                    items: categories
                        .map(
                          (item) => DropdownMenuItem<int>(
                            value: (item['category_id'] as num).toInt(),
                            child: Text('${item['name_ar']}'),
                          ),
                        )
                        .toList(),
                    onChanged: onCategoryChanged,
                  ),
                  if (extra != null) ...[const SizedBox(height: 10), extra!],
                ],
              );
            },
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _AdminListScaffold extends StatelessWidget {
  const _AdminListScaffold({
    required this.future,
    required this.onRefresh,
    required this.onAdd,
    required this.addLabel,
    required this.itemBuilder,
  });

  final Future<List<Map<String, dynamic>>> future;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;
  final String addLabel;
  final Widget Function(Map<String, dynamic>) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(addLabel),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => onRefresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _GlassTile(child: itemBuilder(snapshot.data![index])),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlassTile extends StatelessWidget {
  const _GlassTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panelNavy.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _CompanyIcon extends StatelessWidget {
  const _CompanyIcon({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return const Icon(Icons.business_outlined, color: AppColors.textLight);
    }
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: NetworkImage(url!),
      onBackgroundImageError: (_, _) {},
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(color: AppColors.textMuted)),
    );
  }
}

class _CategoryForm {
  const _CategoryForm({
    required this.name,
    required this.iconKey,
    required this.isActive,
  });
  final String name;
  final String iconKey;
  final bool isActive;
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.item});
  final Map<String, dynamic>? item;
  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController _name;
  late final TextEditingController _icon;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: '${item?['name_ar'] ?? ''}');
    _icon = TextEditingController(text: '${item?['icon_key'] ?? 'devices'}');
    _active = item?['is_active'] != false;
  }

  @override
  void dispose() {
    _name.dispose();
    _icon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.panelNavy.withValues(alpha: 0.94),
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
      side: const BorderSide(color: AppColors.border),
    ),
    title: Text(widget.item == null ? 'إضافة فئة' : 'تعديل الفئة'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'اسم الفئة'),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _icon,
          decoration: const InputDecoration(labelText: 'مفتاح الأيقونة'),
        ),
        if (widget.item != null)
          SwitchListTile(
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            title: const Text('مفعلة'),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          _CategoryForm(
            name: _name.text,
            iconKey: _icon.text,
            isActive: _active,
          ),
        ),
        child: const Text('حفظ'),
      ),
    ],
  );
}

class _CompanyForm {
  const _CompanyForm({required this.name, required this.iconUrl});
  final String name;
  final String? iconUrl;
}

class _CompanyDialog extends StatefulWidget {
<<<<<<< HEAD
  const _CompanyDialog({
    this.initialName = '',
    this.initialIconUrl,
    this.isEditing = false,
  });

  final String initialName;
  final String? initialIconUrl;
  final bool isEditing;

=======
  const _CompanyDialog();
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  @override
  State<_CompanyDialog> createState() => _CompanyDialogState();
}

class _CompanyDialogState extends State<_CompanyDialog> {
<<<<<<< HEAD
  late final TextEditingController _name;
  late final TextEditingController _icon;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _icon = TextEditingController(text: widget.initialIconUrl ?? '');
  }
=======
  final _name = TextEditingController();
  final _icon = TextEditingController();
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

  @override
  void dispose() {
    _name.dispose();
    _icon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: AppColors.panelNavy.withValues(alpha: 0.94),
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
    contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(26),
      side: const BorderSide(color: AppColors.border),
    ),
<<<<<<< HEAD
    title: Text(widget.isEditing ? 'تعديل الشركة' : 'إضافة شركة'),
=======
    title: const Text('إضافة شركة'),
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'اسم الشركة'),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _icon,
          decoration: const InputDecoration(labelText: 'رابط الأيقونة'),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('إلغاء'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(
          context,
          _CompanyForm(name: _name.text, iconUrl: _icon.text),
        ),
        child: const Text('حفظ'),
      ),
    ],
  );
}

class _DeviceForm {
  const _DeviceForm({
    required this.modelName,
    required this.shortName,
    required this.description,
    required this.wattageW,
    required this.specifications,
  });

  final String modelName;
  final String shortName;
  final String description;
  final double wattageW;
  final Map<String, dynamic> specifications;
}

class _DeviceDialog extends StatefulWidget {
  const _DeviceDialog({required this.companyName});

  final String companyName;

  @override
  State<_DeviceDialog> createState() => _DeviceDialogState();
}

class _DeviceDialogState extends State<_DeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _model = TextEditingController();
  final _short = TextEditingController();
  final _description = TextEditingController();
  final _wattage = TextEditingController();
  final _specifications = TextEditingController(text: '{}');

  @override
  void dispose() {
    _model.dispose();
    _short.dispose();
    _description.dispose();
    _wattage.dispose();
    _specifications.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Map<String, dynamic> specifications;
    try {
      final decoded = jsonDecode(_specifications.text.trim());
      if (decoded is! Map) throw const FormatException();
      specifications = Map<String, dynamic>.from(decoded);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المواصفات يجب أن تكون بصيغة JSON صحيحة')),
      );
      return;
    }

    Navigator.pop(
      context,
      _DeviceForm(
        modelName: _model.text.trim(),
        shortName: _short.text.trim(),
        description: _description.text.trim(),
        wattageW: double.parse(_wattage.text.trim()),
        specifications: specifications,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.panelNavy.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Text('إضافة جهاز — ${widget.companyName}'),
      content: SizedBox(
        width: 430,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(_model, 'اسم الموديل'),
                _field(_short, 'الاسم المختصر'),
                _field(_description, 'الوصف', maxLines: 2),
                _field(_wattage, 'الاستهلاك الأقصى بالواط', number: true),
                _field(
                  _specifications,
                  'المواصفات بصيغة JSON',
                  maxLines: 3,
                  required: false,
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
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('إضافة للكتالوج'),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool number = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: const TextStyle(color: AppColors.textLight),
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          if (number && (double.tryParse(value?.trim() ?? '') ?? 0) <= 0) {
            return 'أدخل رقمًا أكبر من صفر';
          }
          return null;
        },
      ),
    );
  }
}

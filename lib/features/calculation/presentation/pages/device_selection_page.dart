import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/report_draft.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/catalog_company.dart';
import '../../data/models/catalog_device.dart';
<<<<<<< HEAD
import '../../data/models/custom_device.dart';
import '../../data/models/device_category.dart';
import '../../data/repositories/custom_device_repository.dart';
=======
import '../../data/models/device_category.dart';
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
import '../../data/repositories/device_repository.dart';

/// شاشة اختيار الجهاز: فئات ثم شركات ثم أجهزة.
/// شاشة اختيار الجهاز: فئات ثم شركات ثم أجهزة.
class DeviceSelectionPage extends StatefulWidget {
  const DeviceSelectionPage({
    super.key,
    required this.draft,
    required this.onDeviceSelected,
<<<<<<< HEAD
    this.onViewReport,
    this.selectionKey,
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  });

  final ReportDraft draft; // بيانات التقرير القادمة من صفحة الإعداد.
  final ValueChanged<CatalogDevice> onDeviceSelected; // الجهاز المختار.
<<<<<<< HEAD
  final VoidCallback? onViewReport; // يفتح صفحة أحمال التقرير.
  final GlobalKey<DeviceSelectionPageState>? selectionKey; // يعيد الفئات.

  @override
  State<DeviceSelectionPage> createState() => DeviceSelectionPageState();
=======

  @override
  State<DeviceSelectionPage> createState() => _DeviceSelectionPageState();
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
}

enum _CatalogStage { categories, companies, devices }

<<<<<<< HEAD
class DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final _repository = DeviceRepository(); // مصدر الكتالوج من Supabase.
  final _customRepository =
      CustomDeviceRepository(); // مصدر أجهزة المستخدم الخاصة.
=======
class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final _repository = DeviceRepository(); // مصدر الكتالوج من Supabase.
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

  late final Future<List<DeviceCategory>> _categoriesFuture;
  Future<List<CatalogCompany>>? _companiesFuture;
  Future<List<CatalogDevice>>? _devicesFuture;
<<<<<<< HEAD
  Future<List<CustomDevice>>? _customDevicesFuture;
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

  _CatalogStage _stage = _CatalogStage.categories;
  DeviceCategory? _selectedCategory;
  CatalogCompany? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repository
        .fetchCategories(); // تحميل الفئات مرة واحدة.
  }

<<<<<<< HEAD
  /// يعيد المستخدم إلى الفئات دون إزالة الأجهزة المحفوظة في التقرير.
  void resetToCategories() {
    if (!mounted) {
      return;
    }
    setState(() {
      _stage = _CatalogStage.categories;
      _selectedCategory = null;
      _selectedCompany = null;
      _companiesFuture = null;
      _devicesFuture = null;
      _customDevicesFuture = null;
    });
  }

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  void _openCompanies(DeviceCategory category) {
    setState(() {
      _selectedCategory = category;
      _companiesFuture = _repository.fetchCompanies(category.id);
      _stage = _CatalogStage.companies;
    });
  }

  void _openDevices(CatalogCompany company) {
    final category = _selectedCategory;
<<<<<<< HEAD
    if (category == null) {
      return;
    }
    setState(() {
      _selectedCompany = company;
      _devicesFuture = company.id == -1
          ? null
          : _repository.fetchDevices(
              categoryId: category.id,
              companyId: company.id,
            );
      _customDevicesFuture = company.id == -1
          ? _customRepository.fetchByCategory(category.id)
          : null;
=======
    if (category == null) return;

    setState(() {
      _selectedCompany = company;
      _devicesFuture = _repository.fetchDevices(
        categoryId: category.id,
        companyId: company.id,
      );
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
      _stage = _CatalogStage.devices;
    });
  }

  void _goBack() {
    if (_stage == _CatalogStage.devices) {
      setState(() {
        _stage = _CatalogStage.companies;
        _devicesFuture = null;
        _selectedCompany = null;
      });
      return;
    }

    if (_stage == _CatalogStage.companies) {
      setState(() {
        _stage = _CatalogStage.categories;
        _selectedCategory = null;
        _companiesFuture = null;
      });
      return;
    }
    if (_stage == _CatalogStage.devices) {
      setState(() {
        _stage = _CatalogStage.companies;
        _selectedCompany = null;
        _devicesFuture = null;
      });
      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: _stage == _CatalogStage.categories,
      onPopInvokedWithResult: (didPop, result) {
<<<<<<< HEAD
        if (!didPop) {
          _goBack();
        }
=======
        if (!didPop) _goBack();
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                _Header(
                  stage: _stage,
                  categoryName: _selectedCategory?.name,
                  companyName: _selectedCompany?.name,
                  onBack: _goBack,
                ),

                Expanded(child: _buildStage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case _CatalogStage.categories:
<<<<<<< HEAD
        return Column(
          children: [
            _ReportButton(onPressed: widget.onViewReport),
            Expanded(
              child: _AsyncGrid<DeviceCategory>(
                future: _categoriesFuture,
                emptyText: 'لا توجد فئات متاحة حاليًا',
                itemBuilder: (category) => _IconTile(
                  icon: _categoryIcon(category.iconKey),
                  title: category.name,
                  onTap: () => _openCompanies(category),
                ),
              ),
            ),
          ],
        );
      case _CatalogStage.companies:
        return FutureBuilder<List<CatalogCompany>>(
          future: _companiesFuture!,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const _MessageState(message: 'تعذر تحميل الشركات');
            }
            final companies = snapshot.data ?? <CatalogCompany>[];
            final customCompany = CatalogCompany(
              id: -1,
              name: 'أجهزتي الخاصة',
              iconUrl: null,
            );
            return _AsyncCompanyGrid(
              companies: <CatalogCompany>[customCompany, ...companies],
              onTap: _openDevices,
            );
          },
        );
      case _CatalogStage.devices:
        if (_selectedCompany?.id == -1) {
          return _CustomDeviceSearchPanel(
            future: _customDevicesFuture!,
            categoryId: _selectedCategory!.id,
            onDeviceSelected: (device) {
              widget.onDeviceSelected(_customAsCatalogDevice(device));
            },
          );
        }
        return _DeviceSearchPanel(
          future: _devicesFuture!,
          onDeviceSelected: widget.onDeviceSelected,
=======
        return _AsyncGrid<DeviceCategory>(
          future: _categoriesFuture,
          emptyText: 'لا توجد فئات متاحة حاليًا',
          itemBuilder: (category) => _IconTile(
            icon: _categoryIcon(category.iconKey),
            title: category.name,
            onTap: () => _openCompanies(category),
          ),
        );
      case _CatalogStage.companies:
        return _AsyncGrid<CatalogCompany>(
          future: _companiesFuture!,
          emptyText: 'لا توجد شركات لهذا التصنيف',
          itemBuilder: (company) => _CompanyTile(
            company: company,
            onTap: () => _openDevices(company),
          ),
        );
      case _CatalogStage.devices:
        return _AsyncList<CatalogDevice>(
          future: _devicesFuture!,
          emptyText: 'لا توجد أجهزة لهذه الشركة',
          itemBuilder: (device) => _DeviceTile(
            device: device,
            onTap: () => widget.onDeviceSelected(device),
          ),
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
        );
    }
  }

<<<<<<< HEAD
  CatalogDevice _customAsCatalogDevice(CustomDevice device) {
    return CatalogDevice(
      id: -device.id,
      categoryId: device.categoryId,
      companyId: 0,
      modelName: device.modelName?.trim().isNotEmpty == true
          ? device.modelName!
          : device.name,
      shortName: device.name,
      description: device.description?.trim().isNotEmpty == true
          ? device.description!
          : device.companyName ?? 'جهاز خاص بالمستخدم',
      wattageW: device.wattageW,
      specifications: <String, dynamic>{
        ...device.specifications,
        '_custom_device_id': device.id,
        '_is_custom_device': true,
        '_custom_company_name': device.companyName,
      },
    );
  }

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
  IconData _categoryIcon(String key) {
    const icons = <String, IconData>{
      'tv': Icons.tv_rounded,
      'refrigerator': Icons.kitchen_rounded,
      'lightbulb': Icons.lightbulb_rounded,
      'computer': Icons.computer_rounded,
      'washing_machine': Icons.local_laundry_service_rounded,
      'fan': Icons.toys_rounded,
      'kitchen': Icons.blender_rounded,
      'phone_charger': Icons.phone_android_rounded,
      'laptop_charger': Icons.laptop_rounded,
      'water_pump': Icons.water_rounded,
    };
    return icons[key] ?? Icons.devices_other_rounded;
  }
}

<<<<<<< HEAD
class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('عرض تقرير الأحمال'),
        ),
      ),
    );
  }
}

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
class _Header extends StatelessWidget {
  const _Header({
    required this.stage,
    required this.categoryName,
    required this.companyName,
    required this.onBack,
  });

  final _CatalogStage stage;
  final String? categoryName;
  final String? companyName;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final title = switch (stage) {
      _CatalogStage.categories => 'اختيار الفئة',
      _CatalogStage.companies => 'اختيار الشركة',
      _CatalogStage.devices => 'اختيار الجهاز',
    };

    final subtitle = switch (stage) {
      _CatalogStage.categories => null,
      _CatalogStage.companies =>
        categoryName == null ? null : 'الفئة: $categoryName',
      _CatalogStage.devices =>
        companyName == null ? null : 'الشركة: $companyName',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward_rounded),
            color: AppColors.textLight,
            tooltip: 'رجوع',
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class _AsyncCompanyGrid extends StatelessWidget {
  const _AsyncCompanyGrid({required this.companies, required this.onTap});

  final List<CatalogCompany> companies;
  final ValueChanged<CatalogCompany> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.86,
      ),
      itemCount: companies.length,
      itemBuilder: (context, index) => _CompanyTile(
        company: companies[index],
        onTap: () => onTap(companies[index]),
      ),
    );
  }
}

class _CustomDeviceSearchPanel extends StatefulWidget {
  const _CustomDeviceSearchPanel({
    required this.future,
    required this.categoryId,
    required this.onDeviceSelected,
  });

  final Future<List<CustomDevice>> future;
  final int categoryId;
  final ValueChanged<CustomDevice> onDeviceSelected;

  @override
  State<_CustomDeviceSearchPanel> createState() =>
      _CustomDeviceSearchPanelState();
}

class _CustomDeviceSearchPanelState extends State<_CustomDeviceSearchPanel> {
  final _repository = CustomDeviceRepository();
  List<CustomDevice> _createdDevices = <CustomDevice>[];
  late final TextEditingController _modelController;
  late final TextEditingController _minWattController;
  late final TextEditingController _maxWattController;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController()..addListener(_refresh);
    _minWattController = TextEditingController()..addListener(_refresh);
    _maxWattController = TextEditingController()..addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  double? _number(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  List<CustomDevice> _filter(List<CustomDevice> devices) {
    final query = _modelController.text.trim().toLowerCase();
    final minWatt = _number(_minWattController.text);
    final maxWatt = _number(_maxWattController.text);
    return devices
        .where((device) {
          final searchable =
              '${device.name} ${device.modelName ?? ''} '
                      '${device.companyName ?? ''} ${device.description ?? ''}'
                  .toLowerCase();
          return (query.isEmpty || searchable.contains(query)) &&
              (minWatt == null || device.wattageW >= minWatt) &&
              (maxWatt == null || device.wattageW <= maxWatt);
        })
        .toList(growable: false);
  }

  Future<void> _addCustomDevice() async {
    // يملك الحوار متحكمات الحقول ويتخلص منها داخل دورة حياته الخاصة.
    final draft = await showDialog<CustomDevice>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) =>
          _CustomDeviceFormDialog(categoryId: widget.categoryId),
    );

    if (draft == null || !mounted) {
      return;
    }

    try {
      // حفظ الجهاز بعد اكتمال إغلاق الحوار يمنع استخدام المتحكم بعد التخلص منه.
      final saved = await _repository.create(device: draft);
      if (mounted) {
        setState(() => _createdDevices = [..._createdDevices, saved]);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر حفظ الجهاز: $error')));
      }
    }
  }

  @override
  void dispose() {
    _modelController
      ..removeListener(_refresh)
      ..dispose();
    _minWattController
      ..removeListener(_refresh)
      ..dispose();
    _maxWattController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  CatalogDevice _asCatalogDevice(CustomDevice device) {
    return CatalogDevice(
      id: -device.id,
      categoryId: device.categoryId,
      companyId: 0,
      modelName: device.modelName?.trim().isNotEmpty == true
          ? device.modelName!
          : device.name,
      shortName: device.name,
      description: device.description?.trim().isNotEmpty == true
          ? device.description!
          : device.companyName ?? 'جهاز خاص بالمستخدم',
      wattageW: device.wattageW,
      specifications: <String, dynamic>{
        ...device.specifications,
        '_custom_device_id': device.id,
        '_is_custom_device': true,
        '_custom_company_name': device.companyName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomDevice>>(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _MessageState(message: 'تعذر تحميل أجهزتك الخاصة');
        }
        final devices = _filter([
          ...(snapshot.data ?? <CustomDevice>[]),
          ..._createdDevices,
        ]);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addCustomDevice,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('إضافة جهاز خاص'),
                ),
              ),
            ),
            _DeviceSearchFields(
              modelController: _modelController,
              minWattController: _minWattController,
              maxWattController: _maxWattController,
            ),
            Expanded(
              child: devices.isEmpty
                  ? const _MessageState(message: 'لا توجد أجهزة خاصة مطابقة')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                      itemCount: devices.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return _DeviceTile(
                          device: _asCatalogDevice(device),
                          onTap: () => widget.onDeviceSelected(device),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
class _AsyncGrid<T> extends StatelessWidget {
  const _AsyncGrid({
    required this.future,
    required this.itemBuilder,
    required this.emptyText,
  });

  final Future<List<T>> future;
  final Widget Function(T item) itemBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _MessageState(message: 'تعذر تحميل البيانات من Supabase');
        }

        final items = snapshot.data ?? <T>[];
<<<<<<< HEAD
        if (items.isEmpty) {
          return _MessageState(message: emptyText);
        }
=======
        if (items.isEmpty) return _MessageState(message: emptyText);
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.86,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(items[index]),
        );
      },
    );
  }
}

<<<<<<< HEAD
class _DeviceSearchPanel extends StatefulWidget {
  const _DeviceSearchPanel({
    required this.future,
    required this.onDeviceSelected,
  });

  final Future<List<CatalogDevice>> future;
  final ValueChanged<CatalogDevice> onDeviceSelected;

  @override
  State<_DeviceSearchPanel> createState() => _DeviceSearchPanelState();
}

class _DeviceSearchPanelState extends State<_DeviceSearchPanel> {
  late final TextEditingController _modelController;
  late final TextEditingController _minWattController;
  late final TextEditingController _maxWattController;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController();
    _minWattController = TextEditingController();
    _maxWattController = TextEditingController();
    _modelController.addListener(_refresh);
    _minWattController.addListener(_refresh);
    _maxWattController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  double? _parseNumber(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  List<CatalogDevice> _filter(List<CatalogDevice> devices) {
    final query = _modelController.text.trim().toLowerCase();
    final minWatt = _parseNumber(_minWattController.text);
    final maxWatt = _parseNumber(_maxWattController.text);

    return devices
        .where((device) {
          final searchable =
              '${device.modelName} ${device.shortName} '
                      '${device.description}'
                  .toLowerCase();
          final matchesModel = query.isEmpty || searchable.contains(query);
          final matchesMin = minWatt == null || device.wattageW >= minWatt;
          final matchesMax = maxWatt == null || device.wattageW <= maxWatt;
          return matchesModel && matchesMin && matchesMax;
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    _modelController
      ..removeListener(_refresh)
      ..dispose();
    _minWattController
      ..removeListener(_refresh)
      ..dispose();
    _maxWattController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CatalogDevice>>(
      future: widget.future,
=======
class _AsyncList<T> extends StatelessWidget {
  const _AsyncList({
    required this.future,
    required this.itemBuilder,
    required this.emptyText,
  });

  final Future<List<T>> future;
  final Widget Function(T item) itemBuilder;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _MessageState(message: 'تعذر تحميل الأجهزة من Supabase');
        }
<<<<<<< HEAD

        final devices = _filter(snapshot.data ?? <CatalogDevice>[]);
        return Column(
          children: [
            _DeviceSearchFields(
              modelController: _modelController,
              minWattController: _minWattController,
              maxWattController: _maxWattController,
            ),
            Expanded(
              child: devices.isEmpty
                  ? const _MessageState(
                      message: 'لا توجد أجهزة مطابقة لمعايير البحث',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                      physics: const BouncingScrollPhysics(),
                      itemCount: devices.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => _DeviceTile(
                        device: devices[index],
                        onTap: () => widget.onDeviceSelected(devices[index]),
                      ),
                    ),
            ),
          ],
=======
        final items = snapshot.data ?? <T>[];
        if (items.isEmpty) return _MessageState(message: emptyText);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => itemBuilder(items[index]),
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
        );
      },
    );
  }
}

<<<<<<< HEAD
class _DeviceSearchFields extends StatelessWidget {
  const _DeviceSearchFields({
    required this.modelController,
    required this.minWattController,
    required this.maxWattController,
  });

  final TextEditingController modelController;
  final TextEditingController minWattController;
  final TextEditingController maxWattController;

  InputDecoration _decoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: modelController.text.isNotEmpty && label == 'بحث بالموديل'
          ? IconButton(
              onPressed: modelController.clear,
              icon: const Icon(Icons.clear_rounded),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: Column(
        children: [
          TextField(
            controller: modelController,
            textInputAction: TextInputAction.search,
            decoration: _decoration(
              label: 'بحث بالموديل',
              icon: Icons.search_rounded,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minWattController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _decoration(
                    label: 'من واط',
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: maxWattController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _decoration(
                    label: 'إلى واط',
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomDeviceFormDialog extends StatefulWidget {
  const _CustomDeviceFormDialog({required this.categoryId});

  final int categoryId;

  @override
  State<_CustomDeviceFormDialog> createState() =>
      _CustomDeviceFormDialogState();
}

class _CustomDeviceFormDialogState extends State<_CustomDeviceFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _modelController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _wattageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _companyController = TextEditingController();
    _modelController = TextEditingController();
    _descriptionController = TextEditingController();
    _wattageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _wattageController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final wattage = double.tryParse(
      _wattageController.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty || wattage == null || wattage <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أدخل اسمًا وقدرة صحيحة')));
      return;
    }

    final now = DateTime.now();
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(
      CustomDevice(
        id: 0,
        ownerId: '',
        categoryId: widget.categoryId,
        name: name,
        companyName: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        modelName: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        wattageW: wattage,
        specifications: const <String, dynamic>{},
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(labelText: label, prefixIcon: Icon(icon));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
            decoration: BoxDecoration(
              color: const Color(0xF20A2238),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xBFE4F2FF), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Color(0x553F5261),
                  labelStyle: TextStyle(color: Color(0xFFEAF5FF)),
                  hintStyle: TextStyle(color: Color(0xBFEAF5FF)),
                  prefixIconColor: Color(0xFFEAF5FF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(
                      color: Color(0xD9EAF5FF),
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: Color(0xFF94C9FF), width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.devices_other_rounded,
                      color: Color(0xFFB8DBFF),
                      size: 42,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'إضافة جهاز خاص',
                      style: TextStyle(
                        color: Color(0xFFF2F8FF),
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'اسم الجهاز',
                        Icons.devices_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _companyController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'الشركة (اختياري)',
                        Icons.business_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _modelController,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        'الموديل (اختياري)',
                        Icons.qr_code_2_rounded,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      decoration: _decoration(
                        'الوصف (اختياري)',
                        Icons.notes_rounded,
                      ).copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _wattageController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                        'الاستهلاك الأقصى بالواط',
                        Icons.bolt_rounded,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: Color(0xFFEAF5FF)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF94C9FF),
                            foregroundColor: const Color(0xFF082039),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 13,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded, size: 19),
                          label: const Text('حفظ'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: _glassDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: AppColors.textLight),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyTile extends StatelessWidget {
  const _CompanyTile({required this.company, required this.onTap});

  final CatalogCompany company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: _glassDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار واحد فقط داخل البطاقة.
            SizedBox(
              width: 54,
              height: 54,
              child: _CompanyLogo(url: company.iconUrl),
            ),
            const SizedBox(height: 8),
            Text(
              company.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({required this.device, required this.onTap});

  final CatalogDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _glassDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.devices_other_rounded,
              size: 34,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    device.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الاستهلاك الأقصى: ${device.wattageW.toStringAsFixed(0)} واط',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textLight, fontSize: 17),
        ),
      ),
    );
  }
}

BoxDecoration _glassDecoration() {
  return BoxDecoration(
    color: AppColors.panelNavy.withValues(alpha: 0.76),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: AppColors.border),
  );
}

/// يعرض شعار الشركة من الذاكرة المؤقتة لتقليل وقت التحميل عند العودة للشاشة.
//// تحميل شعار الشركة مرة واحدة مع تخزين مؤقت ومهلة زمنية.
class _CompanyLogo extends StatefulWidget {
  const _CompanyLogo({required this.url});

  final String? url;

  @override
  State<_CompanyLogo> createState() => _CompanyLogoState();
}

class _CompanyLogoState extends State<_CompanyLogo> {
  late final Future<File>? _logoFuture;

  @override
  void initState() {
    super.initState();

    final url = widget.url?.trim();

    _logoFuture = url == null || url.isEmpty
        ? null
        : DefaultCacheManager()
              .getSingleFile(url)
              .timeout(const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    final future = _logoFuture;
<<<<<<< HEAD
    if (future == null) {
      return _fallback();
    }
=======
    if (future == null) return _fallback();
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4

    return FutureBuilder<File>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textLight,
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return _fallback();
        }

        return SvgPicture.file(
          snapshot.data!,
          width: 54,
          height: 54,
          fit: BoxFit.contain,
        );
      },
    );
  }

  Widget _fallback() {
    return const Icon(
      Icons.business_rounded,
      size: 38,
      color: AppColors.textLight,
    );
  }
}

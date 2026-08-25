import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/report_draft.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/catalog_company.dart';
import '../../data/models/catalog_device.dart';
import '../../data/models/device_category.dart';
import '../../data/repositories/device_repository.dart';

/// شاشة اختيار الجهاز: فئات ثم شركات ثم أجهزة.
/// شاشة اختيار الجهاز: فئات ثم شركات ثم أجهزة.
class DeviceSelectionPage extends StatefulWidget {
  const DeviceSelectionPage({
    super.key,
    required this.draft,
    required this.onDeviceSelected,
  });

  final ReportDraft draft; // بيانات التقرير القادمة من صفحة الإعداد.
  final ValueChanged<CatalogDevice> onDeviceSelected; // الجهاز المختار.

  @override
  State<DeviceSelectionPage> createState() => _DeviceSelectionPageState();
}

enum _CatalogStage { categories, companies, devices }

class _DeviceSelectionPageState extends State<DeviceSelectionPage> {
  final _repository = DeviceRepository(); // مصدر الكتالوج من Supabase.

  late final Future<List<DeviceCategory>> _categoriesFuture;
  Future<List<CatalogCompany>>? _companiesFuture;
  Future<List<CatalogDevice>>? _devicesFuture;

  _CatalogStage _stage = _CatalogStage.categories;
  DeviceCategory? _selectedCategory;
  CatalogCompany? _selectedCompany;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _repository
        .fetchCategories(); // تحميل الفئات مرة واحدة.
  }

  void _openCompanies(DeviceCategory category) {
    setState(() {
      _selectedCategory = category;
      _companiesFuture = _repository.fetchCompanies(category.id);
      _stage = _CatalogStage.companies;
    });
  }

  void _openDevices(CatalogCompany company) {
    final category = _selectedCategory;
    if (category == null) return;

    setState(() {
      _selectedCompany = company;
      _devicesFuture = _repository.fetchDevices(
        categoryId: category.id,
        companyId: company.id,
      );
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
        if (!didPop) _goBack();
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
        );
    }
  }

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
        if (items.isEmpty) return _MessageState(message: emptyText);

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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const _MessageState(message: 'تعذر تحميل الأجهزة من Supabase');
        }
        final items = snapshot.data ?? <T>[];
        if (items.isEmpty) return _MessageState(message: emptyText);

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => itemBuilder(items[index]),
        );
      },
    );
  }
}

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
    if (future == null) return _fallback();

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
